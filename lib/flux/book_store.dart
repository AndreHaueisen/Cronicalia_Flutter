
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_backend/data_repository.dart';
import 'package:cronicalia_flutter/backend/data_backend/pdf_data_repository.dart';
import 'package:cronicalia_flutter/flux/book_sorter.dart';
import 'package:cronicalia_flutter/models/book.dart';

import 'package:flutter_flux/flutter_flux.dart';

class BookStore extends Store {
  final Firestore _firestore = Firestore.instance;

  DataRepository dataRepository;

  int _totalNumberOfBooks = 0;

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
