import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_backend/data_repository.dart';
import 'package:cronicalia_flutter/backend/data_backend/pdf_data_repository.dart';
import 'package:cronicalia_flutter/backend/files_backend/file_repository.dart';
import 'package:cronicalia_flutter/flux/book_sorter.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/epub_parser.dart';
import 'package:epub/epub.dart' as epubLib;
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_flux/flutter_flux.dart';

class BookStore extends Store {
  final Firestore _firestore = Firestore.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  DataRepository dataRepository;
  FileRepository _fileRepository;

  int _totalNumberOfBooks = 0;
  List<File> _currentPdfBookFiles = List<File>();

  EpubParser _epubParser;
  EpubParser get epubParser => _epubParser;

  Map<String, String> _navigationMap;
  Map<String, String> get navigationMap => _navigationMap;

  int _currentChapterIndex = 0;
  int get currentChapterIndex => _currentChapterIndex;

  // This can contain the file path (for BookPdf) or the html raw data (for BookEpub)
  String _showingFileData;
  String get showingFileData => _showingFileData;

  final Set<Book> _actionBooks = Set<Book>();
  final Set<Book> _adventureBooks = Set<Book>();
  final Set<Book> _comedyBooks = Set<Book>();
  final Set<Book> _dramaBooks = Set<Book>();
  final Set<Book> _fantasyBooks = Set<Book>();
  final Set<Book> _fictionBooks = Set<Book>();
  final Set<Book> _horrorBooks = Set<Book>();
  final Set<Book> _mythologyBooks = Set<Book>();
  final Set<Book> _romanceBooks = Set<Book>();
  final Set<Book> _satireBooks = Set<Book>();

  BookStore() {
    dataRepository = PdfDataRepository(_firestore);
    _fileRepository = FileRepository(storageReference: _storageReference);

    triggerOnAction(loadBookRecommendationsAction, (BookLanguage preferredLanguage) async {
      final List<Book> recommendedBooks = await dataRepository.getBookRecommendations(preferredLanguage);

      BookSorter bookSorter = BookSorter(recommendedBooks: recommendedBooks);
      var actionBooks = bookSorter.getActionBooks();
      var adventureBooks = bookSorter.getAdventureBooks();
      var comedyBooks = bookSorter.getComedyBooks();
      var dramaBooks = bookSorter.getDramaBooks();
      var fantasyBooks = bookSorter.getFantasyBooks();
      var fictionBooks = bookSorter.getFictionBooks();
      var horrorBooks = bookSorter.getHorrorBooks();
      var mythologyBooks = bookSorter.getMythologyBooks();
      var romanceBooks = bookSorter.getRomanceBooks();
      var satireBooks = bookSorter.getSatireBooks();

      if (actionBooks != null) _actionBooks.addAll(actionBooks);
      if (adventureBooks != null) _adventureBooks.addAll(adventureBooks);
      if (comedyBooks != null) _comedyBooks.addAll(comedyBooks);
      if (dramaBooks != null) _dramaBooks.addAll(dramaBooks);
      if (fantasyBooks != null) _fantasyBooks.addAll(fantasyBooks);
      if (fictionBooks != null) _fictionBooks.addAll(fictionBooks);
      if (horrorBooks != null) _horrorBooks.addAll(horrorBooks);
      if (mythologyBooks != null) _mythologyBooks.addAll(mythologyBooks);
      if (romanceBooks != null) _romanceBooks.addAll(romanceBooks);
      if (satireBooks != null) _satireBooks.addAll(satireBooks);

      _totalNumberOfBooks = _sumBooks();
    });

    triggerOnConditionalAction(downloadBookFileAction, (List<dynamic> payload) {
      assert(payload[0] != null && payload[1] != null, "Book and Completer cannot be null");
      Book book = payload[0];
      Completer epubBookReadyCompleter = payload[1];

      // Book is BookPdf and is launched by chapters
      if( book is BookEpub){

        _fileRepository.downloadSingleFiledBook(book).then((File epubFile) {
          if (epubFile != null) {
            epubLib.EpubReader.readBook(epubFile.readAsBytesSync()).then((epubLib.EpubBook epubBook){
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
    });

    triggerOnConditionalAction(generateNavMapAction, (Book book){

      if(book is BookEpub){
        _navigationMap = _epubParser.extractNavMap();
      } else {
        // TODO generate navMap to pdf file
      }

      return true;
    });

    triggerOnAction(forwardChapterAction, (Book book) {

      if(_currentChapterIndex < _navigationMap.length) {
        _currentChapterIndex += 1;

        if (book is BookEpub) {
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

      if(_currentChapterIndex > 0) {
        _currentChapterIndex -= 1;

        if (book is BookEpub) {
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
        _showingFileData = _epubParser.readChapter(chapterIndex);
      } // Book is BookPdf and is launched by chapters
      else if (book is BookPdf && !book.isSingleLaunch) {
        _showingFileData = _currentPdfBookFiles[chapterIndex].path;
      } else {
        _showingFileData = _currentPdfBookFiles[0].path;
      }
    });

    triggerOnConditionalAction(disposeBookAction, (_){
      _showingFileData = null;
      _epubParser = null;
      _currentPdfBookFiles.clear();
      _navigationMap.clear();

      return false;
    });
  }

  int _sumBooks() {
    return _actionBooks.length +
        _adventureBooks.length +
        _comedyBooks.length +
        _dramaBooks.length +
        _fantasyBooks.length +
        _fictionBooks.length +
        _horrorBooks.length +
        _mythologyBooks.length +
        _romanceBooks.length +
        _satireBooks.length;
  }

  int get totalNumberOfBooks => _totalNumberOfBooks;

  List<Book> get actionBooks => _actionBooks.toList();
  List<Book> get adventureBooks => _adventureBooks.toList();
  List<Book> get comedyBooks => _comedyBooks.toList();
  List<Book> get dramaBooks => _dramaBooks.toList();
  List<Book> get fantasyBooks => _fantasyBooks.toList();
  List<Book> get fictionBooks => _fictionBooks.toList();
  List<Book> get horrorBooks => _horrorBooks.toList();
  List<Book> get mythologyBooks => _mythologyBooks.toList();
  List<Book> get romanceBooks => _romanceBooks.toList();
  List<Book> get satireBooks => _satireBooks.toList();
}

final StoreToken bookStoreToken = StoreToken(BookStore());

final Action<BookLanguage> loadBookRecommendationsAction = Action<BookLanguage>();
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
