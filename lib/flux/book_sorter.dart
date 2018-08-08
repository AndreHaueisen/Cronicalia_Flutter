import 'package:cronicalia_flutter/models/book.dart';
import 'package:meta/meta.dart';

class BookSorter {
  BookSorter({@required this.recommendedBooks});

  List<Book> recommendedBooks;


  List<Book> getActionBooks() {
    
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.ACTION);
    }).toList();
  }

  List<Book> getAdventureBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.ADVENTURE);
    }).toList();
  }

  List<Book> getComedyBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.COMEDY);
    }).toList();
  }

  List<Book> getDramaBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.DRAMA);
    }).toList();
  }

  List<Book> getFantasyBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.FANTASY);
    }).toList();
  }

  List<Book> getFictionBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.FICTION);
    }).toList();
  }

  List<Book> getHorrorBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.HORROR);
    }).toList();
  }

  List<Book> getMythologyBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.MYTHOLOGY);
    }).toList();
  }

  List<Book> getRomanceBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.ROMANCE);
    }).toList();
  }

  List<Book> getSatireBooks() {
    return recommendedBooks.where((Book book) {
      return (book.genre == BookGenre.SATIRE);
    }).toList();
  }
}
