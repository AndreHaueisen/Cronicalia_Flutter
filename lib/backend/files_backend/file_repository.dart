import 'dart:async';

import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart' show rootBundle;

class FileRepository{

  FileRepository({this.storageReference});

  final StorageReference storageReference;

  //get file from FirebaseStorage
  Future<String> downloadBookFile() async {
    //StorageReference.getReferenceFromUrl();

    //Placeholder
    String fileText = await rootBundle.loadString('assets/test_file.txt');

    return fileText;
  }

  void _resolveFilesDiff({@required BookPdf originalBook, @required BookPdf modifiedBook}) {}

   String resolveStorageLanguageLocation(BookLanguage bookLanguage) {
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