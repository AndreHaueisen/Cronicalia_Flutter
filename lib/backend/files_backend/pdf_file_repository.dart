import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/backend/data_backend/pdf_data_repository.dart';
import 'package:cronicalia_flutter/backend/files_backend/file_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/models/progress_stream.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

class PdfFileRepository extends FileRepository {
  PdfFileRepository(StorageReference storageReference) : super(storageReference: storageReference);

  Future<String> updateBookCoverImage(
      String encodedEmail, BookPdf book, String newLocalPath, PdfDataRepository dataRepository) async {
    try {
      StorageTaskSnapshot taskSnapshot = (await _uploadBookCoverImage(encodedEmail, book, newLocalPath));
      String newRemotePath =
          (taskSnapshot != null) ? await taskSnapshot.ref.getDownloadURL() : throw ("Cover upload failed");
      await dataRepository.updateBookCoverPictureReferences(encodedEmail, book, newLocalPath, newRemotePath);
      return newRemotePath;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<void> updateBookFiles(
      {@required BookPdf originalBook,
      @required BookPdf modifiedBook,
      PdfDataRepository dataRepository,
      ProgressStream progressStream}) async {
    if (modifiedBook.isSingleLaunch) {
      progressStream.filesTotalNumber = 1;
      await _updateSingleFileBook(
          originalBook: originalBook,
          editedBook: modifiedBook,
          dataRepository: dataRepository,
          progressStream: progressStream);
    } else {
      await _updateMultiFileBook(
          originalBook: originalBook,
          modifiedBook: modifiedBook,
          dataRepository: dataRepository,
          progressStream: progressStream);
    }
  }

  Future<void> _updateSingleFileBook(
      {@required BookPdf originalBook,
      @required BookPdf editedBook,
      PdfDataRepository dataRepository,
      ProgressStream progressStream}) async {
    try {
      if (editedBook.localFullBookUri != null) {
        StorageTaskSnapshot fileTaskSnapshot =
            await _uploadPDFFile(editedBook.authorEmailId, editedBook, editedBook.localFullBookUri);

        String downloadUri = await fileTaskSnapshot.ref.getDownloadURL();
        editedBook.remoteFullBookUri = downloadUri == null
            ? throw ("PDF update failed")
            : downloadUri;

        progressStream?.notifySuccess();

        await dataRepository.updateSingleFileBookFile(editedBook.authorEmailId, editedBook);

        _deleteUnusedFiles(originalBook: originalBook, modifiedBook: editedBook);

        return;
      }
    } catch (error) {
      print(error);
      progressStream?.notifyError();
    }
  }

  Future<void> _updateMultiFileBook(
      {@required BookPdf originalBook,
      @required BookPdf modifiedBook,
      PdfDataRepository dataRepository,
      ProgressStream progressStream}) async {
    StreamController<Future<StorageTaskSnapshot>> streamController = StreamController();
    try {
      int taskCounter = 0;
      int completedTaskCounter = 0;
      modifiedBook.chapterUris.asMap().forEach(
        (int index, chapterUri) {
          if (!Utility.isFileRemote(chapterUri)) {
            //save file
            streamController
                .add(_uploadPDFFile(modifiedBook.authorEmailId, modifiedBook, modifiedBook.chapterUris[index]));
            taskCounter++;
          }
        },
      );

      if (taskCounter > 0) {
        progressStream.filesTotalNumber = taskCounter;

        streamController.stream.listen((Future<StorageTaskSnapshot> pdfTaskSnapshotFuture) async {
          StorageTaskSnapshot pdfTaskSnapshot = await pdfTaskSnapshotFuture;

          String downloadUri = await pdfTaskSnapshot.ref.getDownloadURL();
          String newRemoteUri = downloadUri == null
              ? throw ("Pdf update failed")
              : downloadUri;

          int newRemoteUriPosition = modifiedBook.chapterUris.indexWhere((uri) {
            return Utility.resolveFileNameFromLocalFolder(uri) == Utility.resolveFileNameFromUrl(newRemoteUri);
          });

          modifiedBook.chapterUris[newRemoteUriPosition] = newRemoteUri;

          progressStream?.notifySuccess();
          completedTaskCounter++;

          if (completedTaskCounter == taskCounter) {
            await dataRepository.updateMultiFileBookFiles(modifiedBook.authorEmailId, modifiedBook);
            streamController.close();
          }

          print("Uploaded file $newRemoteUriPosition");
        }, onError: (_) {
          throw ("Incomplete book files upload failed");
        }, onDone: () {
          _deleteUnusedFiles(originalBook: originalBook, modifiedBook: modifiedBook);
          print("On done called");
        }, cancelOnError: true);

        await streamController.done;
        return;
      } else {
        progressStream.filesTotalNumber = 1;
        _deleteUnusedFiles(originalBook: originalBook, modifiedBook: modifiedBook);
        streamController.close();
        return await dataRepository.updateMultiFileBookFiles(modifiedBook.authorEmailId, modifiedBook).then((_) {
          progressStream.notifySuccess();
        });
      }
    } catch (error) {
      print(error);
      if (!streamController.isClosed) streamController.close();
      progressStream.notifyError();
    }
  }

  void _deleteUnusedFiles({@required BookPdf originalBook, @required BookPdf modifiedBook}) {
    if (modifiedBook.isSingleLaunch) {
      String oldFileName = Utility.resolveFileNameFromUrl(originalBook.remoteFullBookUri);
      String newFileName = Utility.resolveFileNameFromUrl(modifiedBook.remoteFullBookUri);

      //if the file names are equal, file has been overitten. There is no need to delete
      if (oldFileName != newFileName) {
        storageReference
            .child(resolveStorageLanguageLocation(originalBook.language))
            .child(originalBook.authorEmailId)
            .child(originalBook.generateStorageFolder())
            .child(oldFileName)
            .delete()
            .then((_) {
          print("File $oldFileName deleted");
        });
      }
    } else {
      Map<String, bool> uriPresenceMap = Map<String, bool>();

      //tells if the uri is present in the modifiedBook
      originalBook.chapterUris.forEach((originalChapterUri) {
        uriPresenceMap.putIfAbsent(originalChapterUri, () {
          if (modifiedBook.chapterUris.contains(originalChapterUri)) {
            return true;
          } else {
            return false;
          }
        });
      });

      uriPresenceMap.forEach((String originalChapterUri, bool wasUriPresentInModifiedBook) {
        //if the Uri was not present, check if there is a file with the same name. If there is not,
        //the file is safe for deletion. If there is, the file was already overwriden and should not
        //be deleted.
        if (!wasUriPresentInModifiedBook) {
          String oldFileName = Utility.resolveFileNameFromUrl(originalChapterUri);

          //if the the is a file in modifiedBook with the same name as `oldFileName`, do not delete
          if (!modifiedBook.chapterUris.map((modifiedChapterUri) {
            return oldFileName == Utility.resolveFileNameFromUrl(modifiedChapterUri);
          }).contains(true)) {
            storageReference
                .child(resolveStorageLanguageLocation(originalBook.language))
                .child(originalBook.authorEmailId)
                .child(originalBook.generateStorageFolder())
                .child(oldFileName)
                .delete()
                .then((_) {});

            print("File $oldFileName deleted");
          }
        }
      });
    }
  }

  Future<void> createNewSingleFilePdfBook(String encodedEmail, BookPdf book, PdfDataRepository dataRepository,
      {ProgressStream progressStream}) async {
    try {
      StorageTaskSnapshot coverTaskSnapshot = await _uploadBookCoverImage(encodedEmail, book, book.localCoverUri);
      String downloadUriCover = await coverTaskSnapshot.ref.getDownloadURL();
      book.remoteCoverUri = downloadUriCover == null
          ? throw ("Cover upload failed")
          : downloadUriCover;

      progressStream?.notifySuccess();

      StorageTaskSnapshot pdfTaskSnapshot = await _uploadPDFFile(encodedEmail, book, book.localFullBookUri);
      String downloadUriFullBook = await pdfTaskSnapshot.ref.getDownloadURL();
      book.remoteFullBookUri = downloadUriFullBook == null
          ? throw ("Pdf upload failed")
          : downloadUriFullBook;

      progressStream?.notifySuccess();

      await dataRepository.createNewBook(encodedEmail, book);

      return;
    } catch (error) {
      print(error);
    }
  }

  Future<void> createNewMultiFilePdfBook(
      String encodedEmail, BookPdf book, List<String> pdfLocalPaths, PdfDataRepository dataRepository,
      {ProgressStream progressStream}) async {
    StreamController<Future<StorageTaskSnapshot>> streamController = StreamController();
    try {
      StorageTaskSnapshot coverTaskSnapshot = await _uploadBookCoverImage(encodedEmail, book, book.localCoverUri);
      String downloadUriCover = await coverTaskSnapshot.ref.getDownloadURL();
      book.remoteCoverUri = downloadUriCover == null
          ? throw ("Cover upload failed")
          : downloadUriCover;

      progressStream?.notifySuccess();
      int counter = 0;

      pdfLocalPaths.forEach((String localPath) {
        streamController.add(_uploadPDFFile(encodedEmail, book, localPath));
      });

      streamController.stream.listen((Future<StorageTaskSnapshot> pdfTaskSnapshotFuture) async {
        StorageTaskSnapshot pdfTaskSnapshot = await pdfTaskSnapshotFuture;
        String downloadUriChapter = await pdfTaskSnapshot.ref.getDownloadURL();
        book.chapterUris.add(downloadUriChapter == null
            ? throw ("Pdf #$counter upload failed")
            : downloadUriChapter);

        progressStream?.notifySuccess();
        if (counter == (pdfLocalPaths.length - 1)) {
          streamController.close();
        }
        counter++;
        print("Uploaded file $counter");
      }, onError: (_) {
        throw ("Incomplete book files upload failed");
      }, onDone: () {
        dataRepository.createNewBook(encodedEmail, book);
        print("On done called");
      }, cancelOnError: true);

      await streamController.done;

      return;
    } catch (error) {
      print(error);
      if (!streamController.isClosed) streamController.close();
      progressStream.notifyError();
    }
  }

  Future<StorageTaskSnapshot> _uploadBookCoverImage(String encodedEmail, BookPdf book, String filePath) {
    final File file = File(filePath);
    final metadata = new StorageMetadata(
        contentType: Constants.CONTENT_TYPE_IMAGE,
        customMetadata: {Constants.METADATA_TITLE_IMAGE_TYPE: Constants.METADATA_PROPERTY_IMAGE_TYPE_COVER});

    if (file.existsSync()) {
      final StorageUploadTask uploadTask = storageReference
          .child(resolveStorageLanguageLocation(book.language))
          .child(encodedEmail)
          .child(book.generateStorageFolder())
          .child(Constants.FILE_NAME_SUFFIX_COVER_PICTURE)
          .putFile(file, metadata);

      return uploadTask.onComplete;
    } else {
      return null;
    }
  }

  Future<StorageTaskSnapshot> _uploadPDFFile(String encodedEmail, BookPdf book, String filePath) {
    final File file = File(filePath);
    final metadata = new StorageMetadata(contentType: Constants.CONTENT_TYPE_PDF);

    if (file.existsSync()) {
      final StorageUploadTask uploadTask = storageReference
          .child(resolveStorageLanguageLocation(book.language))
          .child(encodedEmail)
          .child(book.generateStorageFolder())
          .child(file.path.split("/").last)
          .putFile(file, metadata);

      return uploadTask.onComplete;
    } else {
      return null;
    }
  }
}
