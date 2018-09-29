import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/backend/data_backend/user_data_repository.dart';
import 'package:cronicalia_flutter/backend/files_backend/file_repository.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserFileRepository extends FileRepository{

  UserFileRepository(StorageReference storageReference) : super(storageReference: storageReference);

  Future<String> updateUserProfileImage(String encodedEmail, String newLocalPath, UserDataRepository dataRepository) async {
    try {
      final File file = File(newLocalPath);
      final metadata = new StorageMetadata(
          contentType: Constants.CONTENT_TYPE_IMAGE,
          customMetadata: {Constants.METADATA_TITLE_IMAGE_TYPE: Constants.METADATA_PROPERTY_IMAGE_TYPE_PROFILE});

      if (file.existsSync()) {
        final StorageUploadTask uploadTask = storageReference
            .child(Constants.STORAGE_USERS)
            .child(encodedEmail)
            .child(file.path.split('/').last)
            .putFile(file, metadata);

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

  Future<String> updateUserBackgroundImage(String encodedEmail, String newLocalPath, UserDataRepository dataRepository) async {
    try {
      final File file = File(newLocalPath);
      final metadata = new StorageMetadata(
          contentType: Constants.CONTENT_TYPE_IMAGE,
          customMetadata: {Constants.METADATA_TITLE_IMAGE_TYPE: Constants.METADATA_PROPERTY_IMAGE_TYPE_BACKGROUND});

      if (file.existsSync()) {
        final StorageUploadTask uploadTask = storageReference
            .child(Constants.STORAGE_USERS)
            .child(encodedEmail)
            .child(file.path.split('/').last)
            .putFile(file, metadata);

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
}