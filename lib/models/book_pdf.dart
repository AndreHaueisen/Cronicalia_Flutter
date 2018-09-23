import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/custom_widgets/book_pdf_file_widget.dart';
import 'package:cronicalia_flutter/utils/utility_book.dart';

class BookPdf {
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

  String remoteCoverUri;

  bool isSingleFileBook;
  bool isCurrentlyComplete;
  ChapterPeriodicity periodicity;
  String synopsis;

  BookPdf(
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
      this.remoteCoverUri,
      this.isSingleFileBook = true,
      this.isCurrentlyComplete = false,
      this.periodicity = ChapterPeriodicity.NONE,
      this.synopsis});

  BookPdf.fromSnapshot(DocumentSnapshot snapshot) {
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

  BookPdf.fromLinkedMap(LinkedHashMap linkedMap) {
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
    return "${authorEmailId}_${title.replaceAll(' ', '_')}_${UtilityBook.convertLanguageToString(language).toUpperCase()}";
  }

  BookPdf copy() {
    BookPdf newBook = BookPdf(
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
      remoteCoverUri: this.remoteCoverUri,
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

  @override
  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }
    if (other == null || this.runtimeType != other.runtimeType) {
      return false;
    }

    var that = other as BookPdf;
    return uID == that.uID;
  }

  @override
  int get hashCode {
    return uID.hashCode;
  }
}
