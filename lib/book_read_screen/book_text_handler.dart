import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';

class BookTextHandler {
  Future<String> getBookText({@required String localFilePath, @required String remoteFilePath}) async {
    File bookFile = File(localFilePath);
    List<String> fileLines;

    if (bookFile.existsSync()) {
      fileLines = await bookFile.readAsLines();
    } else {
      //dowload file from storage, save it and read it
    }
  }
}
