import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/backend/data_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

const CONTENT_TYPE_IMAGE = "image/jpg";
const CONTENT_TYPE_PDF = "application/pdf";

class FileRepository {
  final StorageReference _storageReference;

  FileRepository(this._storageReference);

  Future<String> updateUserProfileImage(String encodedEmail, String newLocalPath, DataRepository dataRepository) async {
    try {
      final File file = File(newLocalPath);
      final metadata = new StorageMetadata(
          contentType: CONTENT_TYPE_IMAGE,
          customMetadata: {Constants.METADATA_TITLE_IMAGE_TYPE: Constants.METADATA_PROPERTY_IMAGE_TYPE_PROFILE});

      if (file.existsSync()) {
        final StorageUploadTask uploadTask =
            _storageReference.child(Constants.STORAGE_USERS).child(encodedEmail).child(file.path.split('/').last).putFile(file, metadata);

        String newRemotePath = (await uploadTask.future).downloadUrl.toString();
        await dataRepository.updateUserProfilePictureReferences(encodedEmail, newLocalPath, newRemotePath);

        return newRemotePath;
      } else {
        throw ("Update user profile pic failed. Image file does not exists");
      }
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<String> updateUserBackgroundImage(String encodedEmail, String newLocalPath, DataRepository dataRepository) async {
    try {
      final File file = File(newLocalPath);
      final metadata = new StorageMetadata(
          contentType: CONTENT_TYPE_IMAGE,
          customMetadata: {Constants.METADATA_TITLE_IMAGE_TYPE: Constants.METADATA_PROPERTY_IMAGE_TYPE_BACKGROUND});

      if (file.existsSync()) {
        final StorageUploadTask uploadTask =
            _storageReference.child(Constants.STORAGE_USERS).child(encodedEmail).child(file.path.split('/').last).putFile(file, metadata);

        String newRemotePath = (await uploadTask.future).downloadUrl.toString();
        await dataRepository.updateUserBackgroundPictureReferences(encodedEmail, newLocalPath, newRemotePath);

        return newRemotePath;
      } else {
        throw ("Update user background failed. Image file does not exists");
      }
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<String> updateBookPosterImage(String encodedEmail, Book book, String newLocalPath, DataRepository dataRepository) async {
    try {
      String newRemotePath = (await _uploadBookPosterImage(encodedEmail, book, newLocalPath)).downloadUrl.toString();
      await dataRepository.updateBookPosterPictureReferences(encodedEmail, book, newLocalPath, newRemotePath);
      return newRemotePath;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<String> updateBookCoverImage(String encodedEmail, Book book, String newLocalPath, DataRepository dataRepository) async {
    try {
      String newRemotePath = (await _uploadBookCoverImage(encodedEmail, book, newLocalPath)).downloadUrl.toString();
      await dataRepository.updateBookPosterPictureReferences(encodedEmail, book, newLocalPath, newRemotePath);
      return newRemotePath;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<void> createNewCompleteBook(String encodedEmail, Book book, DataRepository dataRepository) async {
    try {
      UploadTaskSnapshot posterTaskSnapshot = await _uploadBookPosterImage(encodedEmail, book, book.localPosterUri);
      book.remotePosterUri =
          posterTaskSnapshot.downloadUrl == null ? throw ("Poster upload failed") : posterTaskSnapshot.downloadUrl.toString();

      UploadTaskSnapshot coverTaskSnapshot = await _uploadBookCoverImage(encodedEmail, book, book.localCoverUri);
      book.remoteCoverUri =
          coverTaskSnapshot.downloadUrl == null ? throw ("Cover upload failed") : coverTaskSnapshot.downloadUrl.toString();

      UploadTaskSnapshot pdfTaskSnapshot = await _uploadPdfFile(encodedEmail, book, book.localFullBookUri);
      book.remoteFullBookUri = pdfTaskSnapshot.downloadUrl == null ? throw ("Pdf upload failed") : pdfTaskSnapshot.downloadUrl.toString();

      await dataRepository.createNewBook(encodedEmail, book);
      return;
    } catch (error) {
      print(error);
    }
  }

  Future<UploadTaskSnapshot> _uploadBookPosterImage(String encodedEmail, Book book, String filePath) {
    final File file = File(filePath);
    final metadata = new StorageMetadata(
        contentType: CONTENT_TYPE_IMAGE,
        customMetadata: {Constants.METADATA_TITLE_IMAGE_TYPE: Constants.METADATA_PROPERTY_IMAGE_TYPE_POSTER});

    if (file.existsSync()) {
      final StorageUploadTask uploadTask = _storageReference
          .child(_resolveStorageLanguageLocation(book.language))
          .child(encodedEmail)
          .child(book.generateStorageFolder())
          .child(file.path.split("/").last)
          .putFile(file, metadata);

      return uploadTask.future;
    } else {
      return null;
    }
  }

  Future<UploadTaskSnapshot> _uploadBookCoverImage(String encodedEmail, Book book, String filePath) {
    final File file = File(filePath);
    final metadata = new StorageMetadata(
        contentType: CONTENT_TYPE_IMAGE,
        customMetadata: {Constants.METADATA_TITLE_IMAGE_TYPE: Constants.METADATA_PROPERTY_IMAGE_TYPE_COVER});

    if (file.existsSync()) {
      final StorageUploadTask uploadTask = _storageReference
          .child(_resolveStorageLanguageLocation(book.language))
          .child(encodedEmail)
          .child(book.generateStorageFolder())
          .child(file.path.split("/").last)
          .putFile(file, metadata);

      return uploadTask.future;
    } else {
      return null;
    }
  }

  Future<UploadTaskSnapshot> _uploadPdfFile(String encodedEmail, Book book, String filePath) {
    final File file = File(filePath);
    final metadata = new StorageMetadata(contentType: CONTENT_TYPE_PDF);

    if (file.existsSync()) {
      final StorageUploadTask uploadTask = _storageReference
          .child(_resolveStorageLanguageLocation(book.language))
          .child(encodedEmail)
          .child(book.generateStorageFolder())
          .child(file.path.split("/").last)
          .putFile(file, metadata);

      return uploadTask.future;
    } else {
      return null;
    }
  }

  String _resolveStorageLanguageLocation(BookLanguage bookLanguage) {
    switch (bookLanguage) {
      case BookLanguage.ENGLISH:
        return Constants.STORAGE_ENGLISH_BOOKS;
      case BookLanguage.PORTUGUESE:
        return Constants.STORAGE_PORTUGUESE_BOOKS;
      case BookLanguage.DEUTSCH:
        return Constants.STORAGE_DEUTSCH_BOOKS;
      case BookLanguage.UNDEFINED:
        return Constants.STORAGE_ENGLISH_BOOKS;
      default:
        return Constants.STORAGE_ENGLISH_BOOKS;
    }
  }
}
