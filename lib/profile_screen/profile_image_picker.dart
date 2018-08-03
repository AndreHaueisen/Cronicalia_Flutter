import 'dart:io';

import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/profile_screen/profile_screen.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileImagePicker {
  static void pickImageFromGallery(ImageType imageType, User user) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(image != null) {
      if (imageType == ImageType.BACKGROUND) {

        File backgroundPicFile = await Utility.createUserFile(Constants.FOLDER_NAME_PROFILE, Constants.FILE_NAME_BACKGROUND_PICTURE);
        await Utility.saveImageToLocalCache(image, backgroundPicFile);
        updateUserBackgroundImageAction(backgroundPicFile.path);
        getUserFromCacheAction(user.copy(localBackgroundPictureUri: backgroundPicFile.path));

      } else {

        File profilePicFile = await Utility.createUserFile(Constants.FOLDER_NAME_PROFILE, Constants.FILE_NAME_PROFILE_PICTURE);
        await Utility.saveImageToLocalCache(image, profilePicFile);
        updateUserProfileImageAction(profilePicFile.path);
        getUserFromCacheAction(user.copy(localProfilePictureUri: profilePicFile.path));
      }
    }
  }

  static void pickImageFromCamera(ImageType imageType, User user) async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    if(image != null) {
      if (imageType == ImageType.BACKGROUND) {
        
        File backgroundPicFile = await Utility.createUserFile(Constants.FOLDER_NAME_PROFILE, Constants.FILE_NAME_BACKGROUND_PICTURE);
        await Utility.saveImageToLocalCache(image, backgroundPicFile);
        updateUserBackgroundImageAction(backgroundPicFile.path);
        getUserFromCacheAction(user.copy(localBackgroundPictureUri: backgroundPicFile.path));

      } else {
        
        File profilePicFile = await Utility.createUserFile(Constants.FOLDER_NAME_PROFILE, Constants.FILE_NAME_PROFILE_PICTURE);
        await Utility.saveImageToLocalCache(image, profilePicFile);
        updateUserProfileImageAction(profilePicFile.path);
        getUserFromCacheAction(user.copy(localProfilePictureUri: profilePicFile.path));
      }
    }
  }

  static ImageProvider getBackgroundImageProvider(String localBackgroundPictureUri, String remoteBackgroundPictureUri) {
    ImageProvider imageProvider = AssetImage("images/horizon.png");

    if (localBackgroundPictureUri != null) {
      File profileFile = File(localBackgroundPictureUri);
      if (profileFile.existsSync()) {
        imageProvider = FileImage(profileFile);
      } else {
        if (remoteBackgroundPictureUri != null) {
          imageProvider = NetworkImage(remoteBackgroundPictureUri);

          /*FirebaseStorage.instance.ref().child(Constants.STORAGE_USERS)
              .child(userStore.user.encodedEmail)
              .child("profile_picture.jpg ").getData(Constants.ONE_MB_IN_BYTES).then((encodedImage) {
            Utility.createUserDirectory("profile", Constants.FILE_NAME_PROFILE_PICTURE).then((file) {
              file.writeAsBytes(encodedImage.toList(growable: false));
            });
          });*/
        }
      }
    } else if (remoteBackgroundPictureUri != null) {
      imageProvider = NetworkImage(remoteBackgroundPictureUri);
    }

    return imageProvider;
  }

  static ImageProvider getProfileImageProvider(String localProfilePictureUri, String remoteProfilePictureUri) {
    //TODO test with CachedNetworkImage()

    ImageProvider imageProvider = AssetImage("images/unknown_profile_pic.png", );

    if (localProfilePictureUri != null) {
      File profileFile = File(localProfilePictureUri);
      if (profileFile.existsSync()) {
        imageProvider = FileImage(profileFile);
      } else {
        if (remoteProfilePictureUri != null) {
          imageProvider = NetworkImage(remoteProfilePictureUri);

          /*FirebaseStorage.instance.ref().child(Constants.STORAGE_USERS)
              .child(userStore.user.encodedEmail)
              .child("profile_picture.jpg ").getData(Constants.ONE_MB_IN_BYTES).then((encodedImage) {
            Utility.createUserDirectory("profile", Constants.FILE_NAME_PROFILE_PICTURE).then((file) {
              file.writeAsBytes(encodedImage.toList(growable: false));
            });
          });*/
        }
      }
    } else if (remoteProfilePictureUri != null) {
      imageProvider = NetworkImage(remoteProfilePictureUri);
    }

    return imageProvider;
  }
}
