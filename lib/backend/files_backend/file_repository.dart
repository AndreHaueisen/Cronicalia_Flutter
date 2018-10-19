import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class FileRepository {
  FileRepository({this.storageReference});

  final StorageReference storageReference;

  //get file from FirebaseStorage
  Future<File> downloadSingleFiledBook(Book book) async {
    try {
      final String fileName = book is BookPdf ? book.generatePdfFileTitle() : (book as BookEpub).generateEpubFileTitle();
      final File file = await Utility.createFile(Constants.FOLDER_NAME_MY_READINGS, fileName);
      final FileStat fileStat = await file.stat();

      StorageReference reference = _getFileStorageReference(book);

      StorageMetadata metadata = await reference.getMetadata();
      int creationTimeOnDatabase = metadata.creationTimeMillis;
      int creationTimeOnLocalCache = file.lastModifiedSync().millisecondsSinceEpoch;

      // Local file either new or is outdated and needs to be downloaded
      if (fileStat.size == 0 || creationTimeOnDatabase > creationTimeOnLocalCache) {
        int maxSize = metadata.sizeBytes;
        await Utility.saveBookFileToLocalCache(file, await reference.getData(maxSize));
      }

      return file;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // Test it
  Future<List<File>> downloadMultiFiledBook(Book book) async {
    assert(book is BookPdf && book.isSingleLaunch == false, "Book has to be PDF and not be single launch");

    final String folderName = (book as BookPdf).uID;
    final List<File> _bookFileList = List<File>();

    try{

      for(int i = 0; i < book.chapterTitles.length; i++){

        // file path goes: my_readings/book.uID/chapterTitle.pdf
        final String chapterFileName = Utility.resolveFileNameFromUrl((book as BookPdf).chapterUris[i]);
        final File file = await Utility.createFile("${Constants.FOLDER_NAME_MY_READINGS}/$folderName", chapterFileName);
        final FileStat fileStat = await file.stat();

        StorageReference reference = _getFileStorageReference(book, chapterFileName: chapterFileName);

        StorageMetadata metadata = await reference.getMetadata();
        int creationTimeOnDatabase = metadata.creationTimeMillis;
        int creationTimeOnLocalCache = file.lastModifiedSync().millisecondsSinceEpoch;

        if (fileStat.size == 0 || creationTimeOnDatabase > creationTimeOnLocalCache) {
          int maxSize = metadata.sizeBytes;
          await Utility.saveBookFileToLocalCache(file, await reference.getData(maxSize));
          }

        _bookFileList.add(file);

      }

      return _bookFileList;

    } catch (error){
      print(error);
      return null;
    }
  }

  StorageReference _getFileStorageReference(Book book, {String chapterFileName}){
    assert(chapterFileName == null || (chapterFileName != null && book is BookPdf), "Uri index problem");

    return storageReference
        .child(resolveStorageLanguageLocation(book.language))
        .child(book.authorEmailId)
        .child(book.generateStorageFolder())
        .child(chapterFileName == null ? Utility.resolveFileNameFromUrl(book.remoteFullBookUri) : chapterFileName);
  }

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
