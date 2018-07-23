import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/my_books_screen/edit_my_book_screen.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class MyBookImagePicker {
  static void pickImageFromGallery(
      ImageType imageType, User user, String bookKey, String bookUID) async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      if (imageType == ImageType.POSTER) {
        File posterPicFile = await Utility.createUserFile(
            Constants.FOLDER_NAME_BOOKS,
            "${bookUID}_${Constants.FILE_NAME_SUFFIX_POSTER_PICTURE}");
        await Utility.saveImageToLocalCache(imageFile, posterPicFile);

        updateBookPosterImageAction([bookKey, posterPicFile.path]);
        _updateLocalPosterUri(user, bookKey, posterPicFile);
        getUserFromCacheAction(user.copy(books: user.books));
      } else {
        File coverPicFile = await Utility.createUserFile(
            Constants.FOLDER_NAME_BOOKS,
            "${bookUID}_${Constants.FILE_NAME_SUFFIX_COVER_PICTURE}");
        await Utility.saveImageToLocalCache(imageFile, coverPicFile);

        updateBookCoverImageAction([bookKey, coverPicFile.path]);
        _updateLocalCoverUri(user, bookKey, coverPicFile);
        getUserFromCacheAction(
            user.copy(localProfilePictureUri: coverPicFile.path));
      }
    }
  }

  static void pickImageFromCamera(
      ImageType imageType, User user, String bookKey, String bookUID) async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      if (imageType == ImageType.POSTER) {
        File posterPicFile = await Utility.createUserFile(
            Constants.FOLDER_NAME_BOOKS,
            "${bookUID}_${Constants.FILE_NAME_SUFFIX_POSTER_PICTURE}");
        await Utility.saveImageToLocalCache(imageFile, posterPicFile);

        updateBookPosterImageAction([bookKey, posterPicFile.path]);
        _updateLocalPosterUri(user, bookKey, posterPicFile);
        getUserFromCacheAction(user.copy(books: user.books));
      } else {
        File coverPicFile = await Utility.createUserFile(
            Constants.FOLDER_NAME_BOOKS,
            "${bookUID}_${Constants.FILE_NAME_SUFFIX_COVER_PICTURE}");
        await Utility.saveImageToLocalCache(imageFile, coverPicFile);

        updateBookCoverImageAction([bookKey, coverPicFile.path]);
        _updateLocalCoverUri(user, bookKey, coverPicFile);
        getUserFromCacheAction(
            user.copy(localProfilePictureUri: coverPicFile.path));
      }
    }
  }

  //TODO remember to delete temporary files
  static Future<String> pickImageFromCameraForNewBook(
      ImageType imageType) async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      if (imageType == ImageType.POSTER) {
        File posterPicFile = await Utility.createUserFile(
            Constants.FOLDER_NAME_BOOKS,
            "${Constants.FILE_NAME_TEMP_POSTER_PICTURE}");
        await Utility.saveImageToLocalCache(imageFile, posterPicFile);
        return posterPicFile.path;
      } else {
        File coverPicFile = await Utility.createUserFile(
            Constants.FOLDER_NAME_BOOKS,
            "${Constants.FILE_NAME_TEMP_COVER_PICTURE}");
        await Utility.saveImageToLocalCache(imageFile, coverPicFile);
        return coverPicFile.path;
      }
    }

    return null;
  }

  //TODO remember to delete temporary files
  static Future<String> pickImageFromGalleryForNewBook(
      ImageType imageType) async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      if (imageType == ImageType.POSTER) {
        File posterPicFile = await Utility.createUserFile(
            Constants.FOLDER_NAME_BOOKS,
            "${Constants.FILE_NAME_TEMP_POSTER_PICTURE}");
        await Utility.saveImageToLocalCache(imageFile, posterPicFile);
        return posterPicFile.path;
      } else {
        File coverPicFile = await Utility.createUserFile(
            Constants.FOLDER_NAME_BOOKS,
            "${Constants.FILE_NAME_TEMP_COVER_PICTURE}");
        await Utility.saveImageToLocalCache(imageFile, coverPicFile);
        return coverPicFile.path;
      }
    }

    return null;
  }

  static ImageProvider getPosterImageProvider(
      String localPosterPictureUri, String remotePosterPictureUri) {
    ImageProvider imageProvider = AssetImage("images/horizon.png");

    if (localPosterPictureUri != null) {
      File profileFile = File(localPosterPictureUri);
      if (profileFile.existsSync()) {
        imageProvider = FileImage(profileFile);
      } else {
        if (remotePosterPictureUri != null) {
          imageProvider = NetworkImage(remotePosterPictureUri);

        }
      }
    } else if (remotePosterPictureUri != null) {
      imageProvider = NetworkImage(remotePosterPictureUri);
    }

    return imageProvider;
  }

  static ImageProvider getProfileImageProvider(
      String localCoverPictureUri, String remoteCoverPictureUri) {
    //TODO test with CachedNetworkImage()

    ImageProvider imageProvider = AssetImage("images/profile.png");

    if (localCoverPictureUri != null) {
      File profileFile = File(localCoverPictureUri);
      if (profileFile.existsSync()) {
        imageProvider = FileImage(profileFile);
      } else {
        if (remoteCoverPictureUri != null) {
          imageProvider = NetworkImage(remoteCoverPictureUri);

        }
      }
    } else if (remoteCoverPictureUri != null) {
      imageProvider = NetworkImage(remoteCoverPictureUri);
    }

    return imageProvider;
  }

  static void _updateLocalCoverUri(User user, String bookKey, File file) {
    user.books.update(bookKey, (book) {
      book.localCoverUri = file.path;
    }, ifAbsent: () {
      print("No key found");
    });
  }

  static void _updateLocalPosterUri(User user, String bookKey, File file) {
    user.books.update(bookKey, (book) {
      book.localPosterUri = file.path;
    }, ifAbsent: () {
      print("No key found");
    });
  }
}
