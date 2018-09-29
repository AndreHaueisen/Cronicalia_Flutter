import 'dart:collection';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/custom_widgets/book_pdf_file_widget.dart';

enum BookUploadStatus { SUCCESS, FAILED }

enum BookGenre { UNDEFINED, ACTION, ADVENTURE, COMEDY, DRAMA, FANTASY, FICTION, HORROR, MYTHOLOGY, ROMANCE, SATIRE }

enum BookLanguage { UNDEFINED, ENGLISH, PORTUGUESE, DEUTSCH }

enum ChapterPeriodicity {
  NONE,
  EVERY_DAY,
  EVERY_3_DAYS,
  EVERY_7_DAYS,
  EVERY_14_DAYS,
  EVERY_30_DAYS,
  EVERY_42_DAYS,
}

// Book superclass
class Book{

  String title;
  String uID;
  String authorName;
  String authorEmailId;
  String authorTwitterProfile;
  int publicationDate;
  BookGenre genre;
  int bookPosition;
  double rating;
  int ratingCounter;
  double income;
  int readingsNumber;
  BookLanguage language;
  String localFullBookUri;
  String remoteFullBookUri;
  List<dynamic> chapterTitles = List();
  List<dynamic> chaptersLaunchDates = List();
  String remoteCoverUri;

  bool isSingleFileBook;
  bool isCurrentlyComplete;
  ChapterPeriodicity periodicity;
  String synopsis;

  Book(
      {this.title,
      this.uID,
      this.authorName,
      this.authorEmailId,
      this.authorTwitterProfile,
      this.publicationDate,
      this.genre,
      this.bookPosition,
      this.rating = 0.0,
      this.ratingCounter = 0,
      this.income = 0.0,
      this.readingsNumber = 0,
      this.language = BookLanguage.UNDEFINED,
      this.localFullBookUri,
      this.remoteFullBookUri,
      this.remoteCoverUri,
      this.isSingleFileBook = true,
      this.isCurrentlyComplete = false,
      this.periodicity = ChapterPeriodicity.NONE,
      this.synopsis});

Book.fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      this.rating = snapshot.data['rating'];
      this.authorTwitterProfile = snapshot.data['authorTwitterProfile'];
      this.isCurrentlyComplete = snapshot.data['isCurrentlyComplete'];

      this.publicationDate = snapshot.data['publicationDate'];
      this.uID = snapshot.data['uID'];
      this.income = snapshot.data['income'];

      this.ratingCounter = snapshot.data['ratingCounter'];
      this.authorName = snapshot.data['authorName'];
      this.remoteCoverUri = snapshot.data['remoteCoverUri'];
      this.isSingleFileBook = snapshot.data['isSingleFileBook'];
      this.authorEmailId = snapshot.data['authorEmailId'];
      this.localFullBookUri = snapshot.data['localFullBookUri'];
      this.title = snapshot.data['title'];
      this.readingsNumber = snapshot.data['readingsNumber'];
      this.bookPosition = snapshot.data['bookPosition'];
      this.remoteFullBookUri = snapshot.data['remoteFullBookUri'];
      
      this.synopsis = snapshot.data['synopsis'];
      this.chaptersLaunchDates.addAll(snapshot.data['chaptersLaunchDates']);
      
      this.chapterTitles.addAll(snapshot.data['chapterTitles']);

      this.periodicity = ChapterPeriodicity.values.firstWhere((periodicity) {
        return periodicity.toString() == "ChapterPeriodicity.${snapshot.data['periodicity']}";
      }, orElse: () => null);
      this.genre = BookGenre.values.firstWhere((genre) {
        return genre.toString() == "BookGenre.${snapshot.data['genre']}";
      }, orElse: () => null);
      this.language = BookLanguage.values.firstWhere((bookLanguage) {
        return bookLanguage.toString() == "BookLanguage.${snapshot.data['language']}";
      }, orElse: () => null);
    }
  }

  Book.fromLinkedMap(LinkedHashMap linkedMap) {
    this.rating = linkedMap['rating'];
    this.authorTwitterProfile = linkedMap['authorTwitterProfile'];
    this.isCurrentlyComplete = linkedMap['isCurrentlyComplete'];

    this.publicationDate = linkedMap['publicationDate'];
    this.uID = linkedMap['uID'];
    this.income = linkedMap['income'];

    this.ratingCounter = linkedMap['ratingCounter'];
    this.authorName = linkedMap['authorName'];
    this.remoteCoverUri = linkedMap['remoteCoverUri'];
    this.isSingleFileBook = linkedMap['isSingleFileBook'];
    this.authorEmailId = linkedMap['authorEmailId'];
    this.localFullBookUri = linkedMap['localFullBookUri'];
    this.title = linkedMap['title'];
    this.readingsNumber = linkedMap['readingsNumber'];
    this.bookPosition = linkedMap['bookPosition'];
    this.remoteFullBookUri = linkedMap['remoteFullBookUri'];
    this.synopsis = linkedMap['synopsis'];
    this.chaptersLaunchDates.addAll(linkedMap['chaptersLaunchDates']);
    this.chapterTitles.addAll(linkedMap['chapterTitles']);

    this.periodicity = ChapterPeriodicity.values.firstWhere((periodicity) {
      return periodicity.toString() == "ChapterPeriodicity.${linkedMap['periodicity']}";
    }, orElse: () => null);
    this.genre = BookGenre.values.firstWhere((genre) {
      return genre.toString() == "BookGenre.${linkedMap['genre']}";
    }, orElse: () => null);
    this.language = BookLanguage.values.firstWhere((bookLanguage) {
      return bookLanguage.toString() == "BookLanguage.${linkedMap['language']}";
    }, orElse: () => null);
  }


  String generateStorageFolder() {
    return "${authorEmailId}_${title.replaceAll(' ', '_')}_${Book.convertLanguageToString(this.language).toUpperCase()}";
  }

   static String convertPeriodicityToString(ChapterPeriodicity periodicity) {
    switch (periodicity) {
      case ChapterPeriodicity.NONE:
        return "None";
      case ChapterPeriodicity.EVERY_DAY:
        return "Every day";
      case ChapterPeriodicity.EVERY_3_DAYS:
        return "Every three days";
      case ChapterPeriodicity.EVERY_7_DAYS:
        return "Every week";
      case ChapterPeriodicity.EVERY_14_DAYS:
        return "Every two weaks";
      case ChapterPeriodicity.EVERY_30_DAYS:
        return "Every month";
      case ChapterPeriodicity.EVERY_42_DAYS:
        return "Every 42 days";
      default:
        return "Every day";
    }
  }

  static String convertGenreToString(BookGenre bookGenre) {
    switch (bookGenre) {
      case BookGenre.ACTION:
        return "Action";
      case BookGenre.ADVENTURE:
        return "Adventure";
      case BookGenre.COMEDY:
        return "Comedy";
      case BookGenre.DRAMA:
        return "Drama";
      case BookGenre.FANTASY:
        return "Fantasy";
      case BookGenre.FICTION:
        return "Fiction";
      case BookGenre.HORROR:
        return "Horror";
      case BookGenre.MYTHOLOGY:
        return "Mythology";
      case BookGenre.ROMANCE:
        return "Romance";
      case BookGenre.SATIRE:
        return "Satire";
      default:
        return "Undefined";
    }
  }

  static String convertLanguageToString(BookLanguage language) {
    switch (language) {
      case BookLanguage.ENGLISH:
        return "English";
      case BookLanguage.PORTUGUESE:
        return "Portuguese";
      case BookLanguage.DEUTSCH:
        return "German";
      default:
        return "Undefined";
    }
  }

  @override
  int get hashCode {
    return uID.hashCode;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }

    if (other == null) return false;

    var that = other as Book;
    if(this.runtimeType != that.runtimeType) return false;

    return uID == that.uID;
  }
}

// BookPdf
class BookPdf extends Book {
  List<dynamic> chapterUris = List();
  String localCoverUri;

  BookPdf(
      {this.localCoverUri,
      String title,
      String uID,
      String authorName,
      String authorEmailId,
      String authorTwitterProfile,
      int publicationDate,
      BookGenre genre,
      int bookPosition,
      double rating = 0.0,
      int ratingCounter = 0,
      double income = 0.0,
      int readingsNumber = 0,
      BookLanguage language = BookLanguage.UNDEFINED,
      String localFullBookUri,
      String remoteFullBookUri,
      String remoteCoverUri,
      bool isSingleFileBook = true,
      bool isCurrentlyComplete = false,
      ChapterPeriodicity periodicity = ChapterPeriodicity.NONE,
      String synopsis})
      : super(
            title: title,
            uID: uID,
            authorName: authorName,
            authorEmailId: authorEmailId,
            authorTwitterProfile: authorTwitterProfile,
            publicationDate: publicationDate,
            genre: genre,
            bookPosition: bookPosition,
            rating: rating,
            ratingCounter: ratingCounter,
            income: income,
            readingsNumber: readingsNumber,
            language: language,
            localFullBookUri: localFullBookUri,
            remoteFullBookUri: remoteFullBookUri,
            remoteCoverUri: remoteCoverUri,
            isSingleFileBook: isSingleFileBook,
            isCurrentlyComplete: isCurrentlyComplete,
            periodicity: periodicity,
            synopsis: synopsis);

  BookPdf.fromSnapshot(DocumentSnapshot snapshot) : super.fromSnapshot(snapshot) {
    if (snapshot != null && snapshot.exists) {
      this.localCoverUri = snapshot.data['localCoverUri'];
      this.chapterUris.addAll(snapshot.data['chapterUris']);
    }
  }

  BookPdf.fromLinkedMap(LinkedHashMap linkedMap) : super.fromLinkedMap(linkedMap) {
    this.localCoverUri = linkedMap['localCoverUri'];
    this.chapterUris.addAll(linkedMap['chapterUris']);
  }

  BookPdf copy() {
    BookPdf newBook = BookPdf(
      localCoverUri: this.localCoverUri,
      title: super.title,
      uID: super.uID,
      authorName: super.authorName,
      authorEmailId: super.authorEmailId,
      authorTwitterProfile: super.authorTwitterProfile,
      publicationDate: super.publicationDate,
      genre: super.genre,
      bookPosition: super.bookPosition,
      rating: super.rating,
      ratingCounter: super.ratingCounter,
      income: super.income,
      readingsNumber: super.readingsNumber,
      language: super.language,
      localFullBookUri: super.localFullBookUri,
      remoteFullBookUri: super.remoteFullBookUri,
      remoteCoverUri: super.remoteCoverUri,
      isSingleFileBook: super.isSingleFileBook,
      isCurrentlyComplete: super.isCurrentlyComplete,
      periodicity: super.periodicity,
      synopsis: super.synopsis,
    );

    newBook.chapterUris.addAll(this.chapterUris);
    newBook.chapterTitles.addAll(super.chapterTitles);

    newBook.chaptersLaunchDates.addAll(super.chaptersLaunchDates);

    return newBook;
  }

  Map<String, dynamic> toMap() {
    return {
      "localCoverUri": this.localCoverUri,
      "chapterUris": this.chapterUris,

      "rating": super.rating,
      "authorTwitterProfile": super.authorTwitterProfile,
      "isCurrentlyComplete": super.isCurrentlyComplete,
      "publicationDate": super.publicationDate,
      "uID": super.uID,
      "income": super.income,
      "ratingCounter": super.ratingCounter,
      "authorName": super.authorName,
      "remoteCoverUri": super.remoteCoverUri,
      "isSingleFileBook": super.isSingleFileBook,
      "authorEmailId": super.authorEmailId,
      "localFullBookUri": super.localFullBookUri,
      "title": super.title,
      "readingsNumber": super.readingsNumber,
      "bookPosition": super.bookPosition,
      "remoteFullBookUri": super.remoteFullBookUri,
      "synopsis": super.synopsis,
      "chaptersLaunchDates": super.chaptersLaunchDates,
      
      "chapterTitles": super.chapterTitles,
      "periodicity": periodicity.toString().split(".")[1],
      "genre": genre.toString().split(".")[1],
      "language": language.toString().split(".")[1]
    };
  }

  bool areFilesTheSame(List<BookPdfFileWidget> fileWidgets) {
    if (fileWidgets == null || fileWidgets.length < 1) return false;

    if (fileWidgets[0].isSingleFileBook) {
      return (this.remoteFullBookUri == fileWidgets[0].filePath);
    }

    //return false if there is a diference in chapter lengths
    if (fileWidgets.length != this.chapterUris.length) return false;

    for (var i = 0; i < fileWidgets.length; i++) {
      BookPdfFileWidget fileWidget = fileWidgets[i];

      if (this.chapterUris[i] != fileWidget.filePath) {
        return false;
      }
      if (this.chapterTitles[i] != fileWidget.fileTitle) {
        return false;
      }
    }

    return true;
  }

}

// BookEpub
class BookEpub extends Book {

  Uint8List coverData;

  BookEpub(
      {this.coverData,
      String title,
      String uID,
      String authorName,
      String authorEmailId,
      String authorTwitterProfile,
      int publicationDate,
      BookGenre genre,
      int bookPosition,
      double rating = 0.0,
      int ratingCounter = 0,
      double income = 0.0,
      int readingsNumber = 0,
      BookLanguage language = BookLanguage.UNDEFINED,
      String localFullBookUri,
      String remoteFullBookUri,
      String remoteCoverUri,
      bool isSingleFileBook = true,
      bool isCurrentlyComplete = false,
      ChapterPeriodicity periodicity = ChapterPeriodicity.NONE,
      String synopsis}): super(
            title: title,
            uID: uID,
            authorName: authorName,
            authorEmailId: authorEmailId,
            authorTwitterProfile: authorTwitterProfile,
            publicationDate: publicationDate,
            genre: genre,
            bookPosition: bookPosition,
            rating: rating,
            ratingCounter: ratingCounter,
            income: income,
            readingsNumber: readingsNumber,
            language: language,
            localFullBookUri: localFullBookUri,
            remoteFullBookUri: remoteFullBookUri,
            remoteCoverUri: remoteCoverUri,
            isSingleFileBook: isSingleFileBook,
            isCurrentlyComplete: isCurrentlyComplete,
            periodicity: periodicity,
            synopsis: synopsis);

  BookEpub.fromSnapshot(DocumentSnapshot snapshot) :super.fromSnapshot(snapshot) {
    if (snapshot != null && snapshot.exists) {
      this.coverData = snapshot.data['coverData'];
    }
  }

  BookEpub.fromLinkedMap(LinkedHashMap linkedMap) : super.fromLinkedMap(linkedMap){
    this.coverData = linkedMap['coverData'];
  }

  BookEpub copy() {
    BookEpub newBook = BookEpub(
      title: this.title,
      uID: this.uID,
      authorName: this.authorName,
      authorEmailId: this.authorEmailId,
      authorTwitterProfile: this.authorTwitterProfile,
      publicationDate: this.publicationDate,
      genre: this.genre,
      bookPosition: this.bookPosition,
      rating: this.rating,
      ratingCounter: this.ratingCounter,
      income: this.income,
      readingsNumber: this.readingsNumber,
      language: this.language,
      localFullBookUri: this.localFullBookUri,
      remoteFullBookUri: this.remoteFullBookUri,
      coverData: this.coverData,
      remoteCoverUri: this.remoteCoverUri,
      isSingleFileBook: this.isSingleFileBook,
      isCurrentlyComplete: this.isCurrentlyComplete,
      periodicity: this.periodicity,
      synopsis: this.synopsis,
    );

    newBook.chapterTitles.addAll(this.chapterTitles);
    newBook.chaptersLaunchDates.addAll(this.chaptersLaunchDates);

    return newBook;
  }

  Map<String, dynamic> toMap() {
    return {
      "rating": this.rating,
      "authorTwitterProfile": this.authorTwitterProfile,
      "isCurrentlyComplete": this.isCurrentlyComplete,
      "publicationDate": this.publicationDate,
      "uID": this.uID,
      "income": this.income,
      "ratingCounter": this.ratingCounter,
      "authorName": this.authorName,
      "remoteCoverUri": this.remoteCoverUri,
      "authorEmailId": this.authorEmailId,
      "isSingleFileBook": this.isSingleFileBook,
      "localFullBookUri": this.localFullBookUri,
      "title": this.title,
      "readingsNumber": this.readingsNumber,
      "bookPosition": this.bookPosition,
      "remoteFullBookUri": this.remoteFullBookUri,
      "coverData": this.coverData,
      "synopsis": this.synopsis,
      "chaptersLaunchDates": this.chaptersLaunchDates,
      "chapterTitles": this.chapterTitles,
      "periodicity": periodicity.toString().split(".")[1],
      "genre": genre.toString().split(".")[1],
      "language": language.toString().split(".")[1]
    };
  }

}