import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';

class DataRepository {
  final Firestore firestore;

  DataRepository({this.firestore});

  Future<List<Book>> getBookRecommendations(BookLanguage preferredLanguage) async {
    String bookCollection = resolveBookCollection(preferredLanguage);

    QuerySnapshot snapshot =
        await firestore.collection(bookCollection).orderBy("genre").orderBy("rating", descending: true).getDocuments();

    List<Book> recommendedBooks = List<Book>();
    if (snapshot != null) {
      snapshot.documents.forEach((DocumentSnapshot documentSnapshot) {

           //if true, document is epub
        if(documentSnapshot.data.containsKey("coverData")){
          BookEpub bookEpub = BookEpub.fromSnapshot(documentSnapshot);
          recommendedBooks.add(bookEpub);
        } else { //document is pdf
          BookPdf bookPdf = BookPdf.fromSnapshot(documentSnapshot);
          recommendedBooks.add(bookPdf);
        }
        
      });

      return recommendedBooks;
    } else {
      return null;
    }
  }

  String resolveBookCollection(BookLanguage preferredLanguage) {
    switch (preferredLanguage) {
      case BookLanguage.ENGLISH:
        {
          return Constants.COLLECTION_BOOKS_ENGLISH;
        }
      case BookLanguage.PORTUGUESE:
        {
          return Constants.COLLECTION_BOOKS_PORTUGUESE;
        }
      case BookLanguage.DEUTSCH:
        {
          return Constants.COLLECTION_BOOKS_DEUTSCH;
        }
      default:
        {
          return Constants.COLLECTION_BOOKS_ENGLISH;
        }
    }
  }

  Future<String> saveCoverOnPermanentLocalFile(String tempCoverPath, String bookUID) async {
    File coverTempFile = File(tempCoverPath);
    File coverPicFile =
        await Utility.createFile(Constants.FOLDER_NAME_BOOKS, "${bookUID}_${Constants.FILE_NAME_SUFFIX_COVER_PICTURE}");

    await Utility.saveImageToLocalCache(coverTempFile, coverPicFile);
    return coverPicFile.path;
  }

  Future<void> cleanupTemporaryFiles() async {
    await Utility.deleteFile(Constants.FOLDER_NAME_BOOKS, "${Constants.FILE_NAME_TEMP_COVER_PICTURE}");
    imageCache.clear();
  }

  String resolveCollectionLanguageLocation(BookLanguage bookLanguage) {
    switch (bookLanguage) {
      case BookLanguage.ENGLISH:
        return Constants.COLLECTION_BOOKS_ENGLISH;
      case BookLanguage.PORTUGUESE:
        return Constants.COLLECTION_BOOKS_PORTUGUESE;
      case BookLanguage.DEUTSCH:
        return Constants.COLLECTION_BOOKS_DEUTSCH;
      case BookLanguage.UNDEFINED:
        return Constants.COLLECTION_BOOKS_ENGLISH;
      default:
        return Constants.COLLECTION_BOOKS_ENGLISH;
    }
  }
}
