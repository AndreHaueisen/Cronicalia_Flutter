import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_repository.dart';
import 'package:cronicalia_flutter/flux/book_sorter.dart';
import 'package:cronicalia_flutter/models/book.dart';

import 'package:flutter_flux/flutter_flux.dart';

class BookStore extends Store {
  final Firestore _firestore = Firestore.instance;

  DataRepository _dataRepository;

  int _totalNumberOfBooks = 0;

  final List<Book> _actionBooks = List<Book>();
  final List<Book> _adventureBooks = List<Book>();
  final List<Book> _comedyBooks = List<Book>();
  final List<Book> _dramaBooks = List<Book>();
  final List<Book> _fantasyBooks = List<Book>();
  final List<Book> _fictionBooks = List<Book>();
  final List<Book> _horrorBooks = List<Book>();
  final List<Book> _mythologyBooks = List<Book>();
  final List<Book> _romanceBooks = List<Book>();
  final List<Book> _satireBooks = List<Book>();

  BookStore() {
    _dataRepository = DataRepository(_firestore);

    triggerOnAction(loadBookRecomendationsAction, (BookLanguage preferredLanguage) async {
      final List<Book> recommendedBooks = await _dataRepository.getBookRecommendations(preferredLanguage);

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

  int get totalNumberOfBook => _totalNumberOfBooks;
  List<Book> get actionBooks => _actionBooks;
  List<Book> get adventureBooks => _adventureBooks;
  List<Book> get comedyBooks => _comedyBooks;
  List<Book> get dramaBooks => _dramaBooks;
  List<Book> get fantasyBooks => _fantasyBooks;
  List<Book> get fictionBooks => _fictionBooks;
  List<Book> get horrorBooks => _horrorBooks;
  List<Book> get mythologyBooks => _mythologyBooks;
  List<Book> get romanceBooks => _romanceBooks;
  List<Book> get satireBooks => _satireBooks;
}

final StoreToken bookStoreToken = new StoreToken(BookStore());

Action<BookLanguage> loadBookRecomendationsAction = new Action<BookLanguage>();
