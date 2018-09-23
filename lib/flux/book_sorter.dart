import 'package:cronicalia_flutter/models/book_pdf.dart';
import 'package:cronicalia_flutter/utils/utility_book.dart';
import 'package:meta/meta.dart';

class BookSorter {
  BookSorter({@required this.recommendedBooks});

  List<BookPdf> recommendedBooks;


  List<BookPdf> getActionBooks() {
    
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.ACTION);
    }).toList();
  }

  List<BookPdf> getAdventureBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.ADVENTURE);
    }).toList();
  }

  List<BookPdf> getComedyBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.COMEDY);
    }).toList();
  }

  List<BookPdf> getDramaBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.DRAMA);
    }).toList();
  }

  List<BookPdf> getFantasyBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.FANTASY);
    }).toList();
  }

  List<BookPdf> getFictionBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.FICTION);
    }).toList();
  }

  List<BookPdf> getHorrorBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.HORROR);
    }).toList();
  }

  List<BookPdf> getMythologyBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.MYTHOLOGY);
    }).toList();
  }

  List<BookPdf> getRomanceBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.ROMANCE);
    }).toList();
  }

  List<BookPdf> getSatireBooks() {
    return recommendedBooks.where((BookPdf book) {
      return (book.genre == BookGenre.SATIRE);
    }).toList();
  }
}
