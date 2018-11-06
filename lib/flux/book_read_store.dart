import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/backend/files_backend/file_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:cronicalia_flutter/utils/epub_parser.dart';
import 'package:epub/epub.dart' as epubLib;

class BookReadStore extends Store {
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  FileRepository _fileRepository;

  List<File> _currentPdfBookFiles = List<File>();

  EpubParser _epubParser;
  EpubParser get epubParser => _epubParser;

  List<dynamic> _navigationList = [];
  List<dynamic> get navigationList => _navigationList;

  int _currentChapterIndex = 0;
  int get currentChapterIndex => _currentChapterIndex;

  // This can contain the file path (for BookPdf) or the html raw data (for BookEpub)
  String _showingFileData;
  String get showingFileData => _showingFileData;

  BookReadStore() {
    _fileRepository = FileRepository(storageReference: _storageReference);

    triggerOnConditionalAction(downloadBookFileAction, (List<dynamic> payload) {
      assert(payload[0] != null && payload[1] != null, "Book and Completer cannot be null");
      Book book = payload[0];
      Completer epubBookReadyCompleter = payload[1];

      // Book is BookPdf and is launched by chapters
      try {
        if (book is BookEpub) {
          _fileRepository.downloadSingleFiledBook(book).then((File epubFile) {
            if (epubFile != null) {
              epubLib.EpubReader.readBook(epubFile.readAsBytesSync()).then((epubLib.EpubBook epubBook) {
                _epubParser = EpubParser(epubBook);
                epubBookReadyCompleter.complete();
              });
            }
          });
        } else if (book is BookPdf && !book.isSingleLaunch) {
          _fileRepository.downloadMultiFiledBook(book).then((List<File> filesList) {
            if (filesList.isNotEmpty) {
              _currentPdfBookFiles = filesList;
              epubBookReadyCompleter.complete();
            }
          });
        } else {
          _fileRepository.downloadSingleFiledBook(book).then((File pdfFile) {
            if (pdfFile != null) {
              _currentPdfBookFiles.clear();
              _currentPdfBookFiles.add(pdfFile);
              epubBookReadyCompleter.complete();
            }
          });
        }

        return false;
      } catch (error) {
        print("Book donwload failed: $error");
        return false;
      }
    });

    triggerOnConditionalAction(generateNavMapAction, (Book book) {
      if (book is BookEpub) {
        _navigationList.addAll(book.chapterTitles);
      } else {
        // TODO generate navMap to pdf file
      }

      return true;
    });

    triggerOnAction(forwardChapterAction, (Book book) {
      if (_currentChapterIndex < _navigationList.length - 1) {
        if (book is BookEpub) {
          _currentChapterIndex += 1;
          _showingFileData = _epubParser.readChapter(_currentChapterIndex);

        } // Book is BookPdf and is launched by chapters
        else if (book is BookPdf && !book.isSingleLaunch) {
          _showingFileData = _currentPdfBookFiles[_currentChapterIndex].path;
        } else {
          _showingFileData = _currentPdfBookFiles[0].path;
        }
      }
    });

    triggerOnAction(backwardChapterAction, (Book book) {

      if (_currentChapterIndex > 0) {
        if (book is BookEpub) {
          _currentChapterIndex -= 1;
          _showingFileData = _epubParser.readChapter(_currentChapterIndex);

        } // Book is BookPdf and is launched by chapters
        else if (book is BookPdf && !book.isSingleLaunch) {
          _showingFileData = _currentPdfBookFiles[_currentChapterIndex].path;
        } else {
          _showingFileData = _currentPdfBookFiles[0].path;
        }
      }
    });

    triggerOnAction(navigateToChapterAction, (List<dynamic> payload) {
      Book book = payload[0];
      int chapterIndex = payload[1];
      _currentChapterIndex = chapterIndex;

      if (book is BookEpub) {
        _showingFileData = _epubParser.readChapter(chapterIndex) ?? _epubParser.readChapter(0);
      } // Book is BookPdf and is launched by chapters
      else if (book is BookPdf && !book.isSingleLaunch) {
        _showingFileData = _currentPdfBookFiles[chapterIndex].path;
      } else {
        _showingFileData = _currentPdfBookFiles[0].path;
      }
    });

    triggerOnConditionalAction(disposeBookAction, (_) {
      _showingFileData = null;
      _epubParser = null;
      _currentChapterIndex = 0;
      _currentPdfBookFiles.clear();
      _navigationList.clear();

      return false;
    });
  }
}

final StoreToken bookReadStoreToken = StoreToken(BookReadStore());

// payload[0] contains Book
// payload[1] contains a Completer that completes when the book is ready for usage
final Action<List<dynamic>> downloadBookFileAction = Action<List<dynamic>>();

final Action<Book> generateNavMapAction = Action<Book>();
final Action<Book> forwardChapterAction = Action<Book>();
final Action<Book> backwardChapterAction = Action<Book>();
// payload[0] contains Book
// payload[1] contains chapter index to navigate to
final Action<List<dynamic>> navigateToChapterAction = Action<List<dynamic>>();

final Action disposeBookAction = Action();
