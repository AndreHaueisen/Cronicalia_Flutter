import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:validate/validate.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class Utility {
  static bool isEmailValid(String email) {
    try {
      Validate.isEmail(email);
      return true;
    } catch (error) {
      print('The E-mail Address must be a valid email address.');
      return false;
    }
  }

  static String validatePassword(String password) {
    if (password == null || password.isEmpty) return "Choose your password";
    if (password.length < 6) return "Too short. 6 characters minimum";
    if (password.length > 20) return "Too long. 20 characters maximum";

    return null;
  }

  static String encodeEmail(String decodedEmail) {
    return decodedEmail.replaceAll(".", ",");
  }

  static String decodeEmail(String encodedEmail) {
    return encodedEmail.replaceAll(",", ".");
  }

  static Future<void> saveImageToLocalCache(File inputFile, File outputFile) async {
    IOSink ioSink = outputFile.openWrite();

    File downsizedImageFile = await resizeImage(inputFile);

    await ioSink.addStream(downsizedImageFile.openRead());
    await ioSink.flush();
    ioSink.close();

    print("File write done");
    return await ioSink.done;
  }

  static Future<File> resizeImage(File inputFile) async {
    int imageMaxWidth = 1000;
    int imageMaxHeight = 700;

    ImageProperties properties = await FlutterNativeImage.getImageProperties(inputFile.path);

    bool isLandscape = properties.width >= properties.height;

    if (isLandscape) {
      if (properties.width > imageMaxWidth) {
        return await FlutterNativeImage.compressImage(inputFile.path,
            quality: 90, targetWidth: imageMaxWidth, targetHeight: (properties.height * imageMaxWidth / properties.width).round());
      } else {
        return inputFile;
      }
    } else {
      if (properties.height > imageMaxHeight) {
        return await FlutterNativeImage.compressImage(inputFile.path,
            quality: 90, targetWidth: (properties.width * imageMaxHeight / properties.height).round(), targetHeight: imageMaxHeight);
      } else {
        return inputFile;
      }
    }
  }

  static Future<File> createFile(String directoryName, String fileName) async {
    Directory applicationDirectory = await getApplicationDocumentsDirectory();
    String newFilePath = "${applicationDirectory.path}/cache/$directoryName/$fileName";

    try {
      File directory = File(newFilePath);
      File file;

      if (!directory.existsSync()) {
        file = await directory.create(recursive: true);
      }

      return (file == null) ? directory : file;
    } catch (exception) {
      print(exception.toString());
      return null;
    }
  }

  static Future<void> deleteFile(String directoryName, String fileName) async {
    Directory applicationDirectory = await getApplicationDocumentsDirectory();
    String newFilePath = "${applicationDirectory.path}/cache/$directoryName/$fileName";

    File fileToBeDeleted = File(newFilePath);

    if (fileToBeDeleted.existsSync()) {
      bool wasFileDeleted = !(await fileToBeDeleted.delete()).existsSync();
      if (wasFileDeleted)
        print("File deleted: $newFilePath");
      else
        print("File not deleted: $newFilePath");
    } else {
      print("File did not exist: $newFilePath");
    }
  }
}
