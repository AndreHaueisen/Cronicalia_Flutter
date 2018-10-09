import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
      UploadTaskSnapshot coverTaskSnapshot = await _uploadBookCoverImage(encodedEmail, book);
      book.remoteCoverUri =
          coverTaskSnapshot.downloadUrl == null ? throw ("Cover upload failed") : coverTaskSnapshot.downloadUrl.toString();

      progressStream?.notifySuccess();

      UploadTaskSnapshot pdfTaskSnapshot = await _uploadEpubFile(encodedEmail, book);
      book.remoteFullBookUri =
          pdfTaskSnapshot.downloadUrl == null ? throw ("Epub upload failed") : pdfTaskSnapshot.downloadUrl.toString();

      progressStream?.notifySuccess();

      await dataRepository.createNewBook(encodedEmail, book);
    } catch (error) {
      print(error);
    }
  }

  Future<UploadTaskSnapshot> _uploadBookCoverImage(String encodedEmail, BookEpub book) {
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

      return uploadTask.future;
    } else {
      return null;
    }
  }

  Future<UploadTaskSnapshot> _uploadEpubFile(String encodedEmail, BookEpub book) {
    final File file = File(book.localFullBookUri);
    final metadata = new StorageMetadata(contentType: Constants.CONTENT_TYPE_EPUB);

    if (file.existsSync()) {
      final StorageUploadTask uploadTask = storageReference
          .child(resolveStorageLanguageLocation(book.language))
          .child(encodedEmail)
          .child(book.generateStorageFolder())
          .child(file.path.split("/").last)
          .putFile(file, metadata);

      return uploadTask.future;
    } else {
      return null;
    }
  }

  Future<void> updateBookFile(
      {BookEpub originalBook, BookEpub editedBook, EpubDataRepository dataRepository, ProgressStream progressStream}) async {
    try {
      progressStream.filesTotalNumber = 2;

      UploadTaskSnapshot coverTaskSnapshot = await _uploadBookCoverImage(editedBook.authorEmailId, editedBook);
      editedBook.remoteCoverUri =
          coverTaskSnapshot.downloadUrl == null ? throw ("Cover upload failed") : coverTaskSnapshot.downloadUrl.toString();

      progressStream.notifySuccess();

      if (editedBook.localFullBookUri != null) {
        UploadTaskSnapshot fileTaskSnapshot = await _uploadEpubFile(editedBook.authorEmailId, editedBook);
        editedBook.remoteFullBookUri =
            fileTaskSnapshot.downloadUrl == null ? throw ("Epub update failed") : fileTaskSnapshot.downloadUrl.toString();

        progressStream.notifySuccess();

        await dataRepository.updateBookData(editedBook);

        _deleteUnusedFiles(originalBook: originalBook, modifiedBook: editedBook);
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
