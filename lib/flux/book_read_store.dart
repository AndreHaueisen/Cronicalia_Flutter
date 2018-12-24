import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/backend/files_backend/file_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:cronicalia_flutter/utils/book_parser.dart';
import 'package:epub/epub.dart' as epubLib;

// payload[0] contains BookPdf
// payload[1] contains a Completer that completes when the book is ready for usage
final Action<List<dynamic>> downloadPdfFileAction = Action<List<dynamic>>();

final Action<void> pdfForwardChapterAction = Action<void>();
final Action<void> pdfBackwardChapterAction = Action<void>();
final Action<int> pdfNavigateToChapterAction = Action<int>();

final Action disposePdfBookAction = Action();

class PdfReadStore extends Store {
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  FileRepository _fileRepository;

  PdfParser _pdfParser;

  String get showingFilePath => _pdfParser != null ? _pdfParser.showingFilePath : null;

  PdfReadStore() {
    _fileRepository = FileRepository(storageReference: _storageReference);

    triggerOnConditionalAction(downloadPdfFileAction, (List<dynamic> payload) {
      assert(payload[0] != null && payload[1] != null, "Book and Completer cannot be null");
      Book book = payload[0];
      Completer pdfBookReadyCompleter = payload[1];

      // Book is BookPdf and is launched by chapters
      try {
        if (!book.isSingleLaunch) {
          _fileRepository.downloadMultiFiledBook(book).then((List<File> filesList) {
            if (filesList.isNotEmpty) {
              _pdfParser = PdfParser(book, filesList);
              pdfBookReadyCompleter.complete();
              trigger();
            }
          });
        } else {
          _fileRepository.downloadSingleFiledBook(book).then((File pdfFile) {
            if (pdfFile != null) {
              _pdfParser = PdfParser(book, [pdfFile]);
              pdfBookReadyCompleter.complete();
              trigger();
            }
          });
        }

        return false;
      } catch (error) {
        print("Book donwload failed: $error");
        return false;
      }
    });

    triggerOnAction(pdfForwardChapterAction, (_) {
      _pdfParser.readNextChapter();
    });

    triggerOnAction(pdfBackwardChapterAction, (_) {
      _pdfParser.readPreviousChapter();
    });

    triggerOnAction(pdfNavigateToChapterAction, (int chapterIndex) {
      _pdfParser.readChapter(chapterIndex);
    });

    triggerOnConditionalAction(disposePdfBookAction, (_) {
      _pdfParser = null;
      return false;
    });
  }
}

class EpubReadStore extends Store {
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  FileRepository _fileRepository;

  EpubParser _epubParser;
  EpubParser get epubParser => _epubParser;

  List<String> _loadedData = [];
  List<String> get loadedData => _loadedData;

  int get currentChapterIndex => _epubParser != null ? _epubParser.currentChapterIndex : 0;

  EpubReadStore() {
    _fileRepository = FileRepository(storageReference: _storageReference);

    triggerOnConditionalAction(downloadEpubFileAction, (List<dynamic> payload) {
      assert(payload[0] != null && payload[1] != null, "Book and Completer cannot be null");
      Book book = payload[0];
      Completer epubBookReadyCompleter = payload[1];

      try {
        _fileRepository.downloadSingleFiledBook(book).then((File epubFile) {
          if (epubFile != null) {
            epubLib.EpubReader.readBook(epubFile.readAsBytesSync()).then((epubLib.EpubBook epubBook) {
              _epubParser = EpubParser(epubBook, book: book);

              epubBookReadyCompleter.complete();
            });
          }
        });

        return false;
      } catch (error) {
        print("Book donwload failed: $error");
        return false;
      }
    });

    triggerOnAction(epubForwardChapterAction, (_) async {
      List<String> data = await _epubParser.readNextChapter();
      if(data != null) {
        _loadedData = data;
      }
    });

    triggerOnAction(epubBackwardChapterAction, (_) async {
      List<String> data = await _epubParser.readPreviousChapter();
      if(data != null) {
        _loadedData = data;
      }
    });

    triggerOnAction(epubNavigateToChapterAction, (int chapterIndex) async {
      List<String> data = await _epubParser.readChapter(chapterIndex);
      if(data != null) {
        _loadedData = data;
      }
    });

    triggerOnConditionalAction(loadNextSubChapterAction, (_) {
      if(_epubParser.canLoadNextSubChapter()) {
        List<String> data = _epubParser.loadNextSubChapter();
        if (data != null) {
          _loadedData = data;
          return true;
        }
      }

      return false;
    });

    triggerOnAction(loadPreviousSubChapterAction, (_){
      if(_epubParser.canLoadPreviousSubChapter()) {
        List<String> data = _epubParser.loadPreviousSubChapter();
        if (data != null) {
          _loadedData = data;
          return true;
        }
      }
      return false;
    });

    triggerOnConditionalAction(disposeEpubBookAction, (_) {
      _epubParser = null;
      _loadedData.clear();
      return false;
    });
  }
}

final StoreToken epubReadStoreToken = StoreToken(EpubReadStore());
final StoreToken pdfReadStoreToken = StoreToken(PdfReadStore());

// payload[0] contains BookEpub
// payload[1] contains a Completer that completes when the book is ready for usage
final Action<List<dynamic>> downloadEpubFileAction = Action<List<dynamic>>();

final Action epubForwardChapterAction = Action();
final Action epubBackwardChapterAction = Action();

final Action<int> epubNavigateToChapterAction = Action<int>();

final Action disposeEpubBookAction = Action();

final Action loadNextSubChapterAction = Action();
final Action loadPreviousSubChapterAction = Action();
