import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';

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

class Book {
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
  List<dynamic> chapterUris = List();
  List<dynamic> chaptersLaunchDates = List();
  String localCoverUri;
  String localPosterUri;
  String remoteCoverUri;
  String remotePosterUri;
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
      this.localCoverUri,
      this.localPosterUri,
      this.remoteCoverUri,
      this.remotePosterUri,
      this.isSingleFileBook = true,
      this.isCurrentlyComplete = false,
      this.periodicity = ChapterPeriodicity.NONE,
      this.synopsis});

  Book.fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      this.rating = snapshot.data['rating'];
      this.authorTwitterProfile = snapshot.data['authorTwitterProfile'];
      this.isCurrentlyComplete = snapshot.data['isCurrentlyComplete'];
      this.remotePosterUri = snapshot.data['remotePosterUri'];
      this.publicationDate = snapshot.data['publicationDate'];
      this.uID = snapshot.data['uID'];
      this.income = snapshot.data['income'];
      this.localPosterUri = snapshot.data['localPosterUri'];
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
      this.localCoverUri = snapshot.data['localCoverUri'];
      this.synopsis = snapshot.data['synopsis'];
      this.chaptersLaunchDates.addAll(snapshot.data['chaptersLaunchDates']);
      this.chapterUris.addAll(snapshot.data['chapterUris']);
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
    this.remotePosterUri = linkedMap['remotePosterUri'];
    this.publicationDate = linkedMap['publicationDate'];
    this.uID = linkedMap['uID'];
    this.income = linkedMap['income'];
    this.localPosterUri = linkedMap['localPosterUri'];
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
    this.localCoverUri = linkedMap['localCoverUri'];
    this.synopsis = linkedMap['synopsis'];
    this.chaptersLaunchDates.addAll(linkedMap['chaptersLaunchDates']);
    this.chapterUris.addAll(linkedMap['chapterUris']);
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
    return "${authorEmailId}_${title.replaceAll(' ', '_')}_${convertLanguageToString(language).toUpperCase()}";
  }

  Book copy() {
    Book newBook = Book(
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
      localCoverUri: this.localCoverUri,
      localPosterUri: this.localPosterUri,
      remoteCoverUri: this.remoteCoverUri,
      remotePosterUri: this.remotePosterUri,
      isSingleFileBook: this.isSingleFileBook,
      isCurrentlyComplete: this.isCurrentlyComplete,
      periodicity: this.periodicity,
      synopsis: this.synopsis,
    );

    newBook.chapterTitles.addAll(this.chapterTitles);
    newBook.chapterUris.addAll(this.chapterUris);
    newBook.chaptersLaunchDates.addAll(this.chaptersLaunchDates);

    return newBook;
  }

  static String convertPeriodicityToString(ChapterPeriodicity chapterPeriodicity) {
    switch (chapterPeriodicity) {
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

  static String convertLanguageToString(BookLanguage bookLanguage) {
    switch (bookLanguage) {
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

  Map<String, dynamic> toMap() {
    return {
      "rating": this.rating,
      "authorTwitterProfile": this.authorTwitterProfile,
      "isCurrentlyComplete": this.isCurrentlyComplete,
      "remotePosterUri": this.remotePosterUri,
      "publicationDate": this.publicationDate,
      "uID": this.uID,
      "income": this.income,
      "localPosterUri": this.localPosterUri,
      "ratingCounter": this.ratingCounter,
      "authorName": this.authorName,
      "remoteCoverUri": this.remoteCoverUri,
      "isSingleFileBook": this.isSingleFileBook,
      "authorEmailId": this.authorEmailId,
      "localFullBookUri": this.localFullBookUri,
      "title": this.title,
      "readingsNumber": this.readingsNumber,
      "bookPosition": this.bookPosition,
      "remoteFullBookUri": this.remoteFullBookUri,
      "localCoverUri": this.localCoverUri,
      "synopsis": this.synopsis,
      "chaptersLaunchDates": this.chaptersLaunchDates,
      "chapterUris": this.chapterUris,
      "chapterTitles": this.chapterTitles,
      "periodicity": periodicity.toString().split(".")[1],
      "genre": genre.toString().split(".")[1],
      "language": language.toString().split(".")[1]
    };
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }
    if (other == null || this.runtimeType != other.runtimeType) {
      return false;
    }

    var that = other as Book;
    return uID == that.uID;
  }

  @override
  int get hashCode {
    return uID.hashCode;
  }
}

enum BookUploadStatus { SUCCESS, FAILED }
