import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/backend/data_backend/epub_data_repository.dart';
import 'package:cronicalia_flutter/backend/files_backend/file_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/models/progress_stream.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

class EpubFileRepository extends FileRepository {
  EpubFileRepository(StorageReference storageReference) : super(storageReference: storageReference);

  Future<void> createNewEpubBook(String encodedEmail, BookEpub book, EpubDataRepository dataRepository,
      {ProgressStream progressStream}) async {
    try {
      StorageTaskSnapshot coverTaskSnapshot = await _uploadBookCoverImage(encodedEmail, book);
      String downloadUriCover = await coverTaskSnapshot.ref.getDownloadURL();
      book.remoteCoverUri = downloadUriCover == null ? throw ("Cover upload failed") : downloadUriCover;

      progressStream?.notifySuccess();

      StorageTaskSnapshot pdfTaskSnapshot = await _uploadEpubFile(encodedEmail, book);
      String downloadUriPdf = await pdfTaskSnapshot.ref.getDownloadURL();
      book.remoteFullBookUri = downloadUriPdf == null ? throw ("Epub upload failed") : downloadUriPdf;

      progressStream?.notifySuccess();

      await dataRepository.createNewBook(encodedEmail, book);

      return;
    } catch (error) {
      print(error);
    }
  }

  Future<StorageTaskSnapshot> _uploadBookCoverImage(String encodedEmail, BookEpub book) {
    final metadata = new StorageMetadata(
        contentType: Constants.CONTENT_TYPE_IMAGE,
        customMetadata: {Constants.METADATA_TITLE_IMAGE_TYPE: Constants.METADATA_PROPERTY_IMAGE_TYPE_COVER});

    if (book.coverData != null) {
      final StorageUploadTask uploadTask = storageReference
          .child(super.resolveStorageLanguageLocation(book.language))
          .child(encodedEmail)
          .child(book.generateStorageFolder())
          .child(Constants.FILE_NAME_SUFFIX_COVER_PICTURE)
          .putData(book.coverData, metadata);

      return uploadTask.onComplete;
    } else {
      return null;
    }
  }

  Future<StorageTaskSnapshot> _uploadEpubFile(String encodedEmail, BookEpub book) {
    final File file = File(book.localFullBookUri);
    final metadata = new StorageMetadata(contentType: Constants.CONTENT_TYPE_EPUB);

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

  Future<void> updateBookFile(
      {BookEpub originalBook,
      BookEpub editedBook,
      EpubDataRepository dataRepository,
      ProgressStream progressStream}) async {
    try {
      progressStream.filesTotalNumber = 2;

      StorageTaskSnapshot coverTaskSnapshot = await _uploadBookCoverImage(editedBook.authorEmailId, editedBook);
      String downloadUriCover = await coverTaskSnapshot.ref.getDownloadURL();
      editedBook.remoteCoverUri =
          downloadUriCover == null ? throw ("Cover upload failed") : downloadUriCover;

      progressStream.notifySuccess();

      if (editedBook.localFullBookUri != null) {
        StorageTaskSnapshot fileTaskSnapshot = await _uploadEpubFile(editedBook.authorEmailId, editedBook);
        String downloadUriFile = await fileTaskSnapshot.ref.getDownloadURL();
        editedBook.remoteFullBookUri =
            downloadUriFile == null ? throw ("Epub update failed") : downloadUriFile;

        progressStream.notifySuccess();

        await dataRepository.updateBookData(editedBook);

        _deleteUnusedFiles(originalBook: originalBook, modifiedBook: editedBook);

        return;
      }
    } catch (error) {
      print(error);
      progressStream?.notifyError();
    }
  }

  void _deleteUnusedFiles({@required BookEpub originalBook, @required BookEpub modifiedBook}) {
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
  }
}
