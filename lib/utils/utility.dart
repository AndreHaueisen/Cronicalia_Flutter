import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:validate/validate.dart';

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

  static Future<void> saveFileToLocalCacheSync(File inputFile, File outputFile) async{

    IOSink ioSink = outputFile.openWrite();

    await ioSink.addStream(inputFile.openRead());
    await ioSink.flush();
    ioSink.close();

    await ioSink.done;
    print("File write done");
  }

  static void saveFileToLocalCache(File inputFile, File outputFile){

    IOSink ioSink = outputFile.openWrite();

    ioSink.addStream(inputFile.openRead()).then((_){
      ioSink.flush().then((_){
        ioSink.close();
      });
    });

    ioSink.done.then((_) {
      print("File write done");
    });
  }

  static Future<File> createUserFile(String directoryName, String fileName) async {
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
}
