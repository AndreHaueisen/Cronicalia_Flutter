import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/models/book_epub.dart';
import 'package:cronicalia_flutter/models/book_pdf.dart';

class User {
  String name;
  String encodedEmail;
  String twitterProfile;
  String aboutMe;
  String localProfilePictureUri;
  String remoteProfilePictureUri;
  String localBackgroundPictureUri;
  String remoteBackgroundPictureUri;
  int fans;
  Map<String, BookPdf> booksPdf;
  Map<String, BookEpub> booksEpub;

  User({this.name,
    this.encodedEmail,
    this.twitterProfile,
    this.aboutMe,
    this.localProfilePictureUri,
    this.remoteProfilePictureUri,
    this.localBackgroundPictureUri,
    this.remoteBackgroundPictureUri,
    this.fans,
    this.booksPdf,
    this.booksEpub});

  User.fromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      this.name = snapshot.data['name'];
      this.encodedEmail = snapshot.data['encodedEmail'];
      this.twitterProfile = snapshot.data['twitterProfile'];
      this.aboutMe = snapshot.data['aboutMe'];
      this.localProfilePictureUri = snapshot.data['localProfilePictureUri'];
      this.remoteProfilePictureUri = snapshot.data['remoteProfilePictureUri'];
      this.localBackgroundPictureUri = snapshot.data['localBackgroundPictureUri'];
      this.remoteBackgroundPictureUri = snapshot.data['remoteBackgroundPictureUri'];
      this.fans = snapshot.data['fans'];
      this.booksPdf = new Map<String, BookPdf>();
      LinkedHashMap booksPdfLinkedMap = (snapshot.data['booksPdf'] as LinkedHashMap);
      if (booksPdfLinkedMap != null) {
        booksPdfLinkedMap.forEach((key, value) {
          booksPdf[key] = BookPdf.fromLinkedMap(value);
        });
      }
      this.booksEpub = new Map<String, BookEpub>();
      LinkedHashMap booksEpubLinkedMap = (snapshot.data['booksEpub'] as LinkedHashMap);
      if (booksEpubLinkedMap != null) {
        booksEpubLinkedMap.forEach((key, value) {
          booksEpub[key] = BookEpub.fromLinkedMap(value);
        });
      }
    }
  }

  User.empty(){
    this.name = "";
    this.encodedEmail = "";
    this.twitterProfile = "";
    this.aboutMe =  "";
    this.localProfilePictureUri = "";
    this.localBackgroundPictureUri = "";
    this.remoteProfilePictureUri = "";
    this.remoteBackgroundPictureUri = "";
    this.fans = 0;
    this.booksPdf = Map<String, BookPdf>();
    this.booksEpub = Map<String, BookEpub>();
  }

  Map<String, dynamic> toMap(){
    return {
      "name" : this.name,
      "encodedEmail" : this.encodedEmail,
      "twitterProfile" : this.twitterProfile,
      "aboutMe" : this.aboutMe,
      "localProfilePictureUri" : this.localProfilePictureUri,
      "remoteProfilePictureUri" : this.remoteProfilePictureUri,
      "localBackgroundPictureUri" : this.localBackgroundPictureUri,
      "remoteBackgroundPictureUri" : this.remoteBackgroundPictureUri,
      "fans" : this.fans,
      "booksPdf" : this.booksPdf,
      "booksEpub" : this.booksEpub
    };
  }

  int calculateTotalBookViews(){
    int bookTotalViews = 0;
    this.booksPdf.forEach((_, book){
      bookTotalViews += book.readingsNumber;
    });
    this.booksEpub.forEach((_, book){
      bookTotalViews += book.readingsNumber;
    });

    return bookTotalViews;
  }

  double calculateTotalIncome(){
    double totalIncome = 0.0;
    this.booksPdf.forEach((_, book){
      totalIncome += book.income;
    });
    this.booksEpub.forEach((_, book){
      totalIncome += book.income;
    });

    return totalIncome;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }
    if (other == null || this.runtimeType != other.runtimeType) {
      return false;
    }

    var that = other as User;
    return name == that.name &&
        encodedEmail == that.encodedEmail &&
        twitterProfile == that.twitterProfile &&
        aboutMe == that.aboutMe &&
        localProfilePictureUri == that.localProfilePictureUri &&
        remoteProfilePictureUri == that.remoteProfilePictureUri &&
        localBackgroundPictureUri == that.localBackgroundPictureUri &&
        remoteBackgroundPictureUri == that.remoteBackgroundPictureUri &&
        fans == that.fans &&
        booksPdf == that.booksPdf &&
        booksEpub == that.booksEpub;
  }

  @override
  int get hashCode {
    return name.hashCode +
        encodedEmail.hashCode +
        twitterProfile.hashCode +
        aboutMe.hashCode +
        localProfilePictureUri.hashCode +
        remoteProfilePictureUri.hashCode +
        localBackgroundPictureUri.hashCode +
        remoteBackgroundPictureUri.hashCode +
        fans.hashCode +
        booksPdf.hashCode +
        booksEpub.hashCode;
  }

  User copy({String name,
    String encodedEmail,
    String twitterProfile,
    String aboutMe,
    String localProfilePictureUri,
    String remoteProfilePictureUri,
    String localBackgroundPictureUri,
    String remoteBackgroundPictureUri,
    int fans,
    Map<String, BookPdf> booksPdf,
    Map<String, BookEpub> booksEpub}) {
    return new User(
        name: (name == null) ? this.name : name,
        encodedEmail: (encodedEmail == null) ? this.encodedEmail : encodedEmail,
        twitterProfile: (twitterProfile == null) ? this.twitterProfile : twitterProfile,
        aboutMe: (aboutMe == null) ? this.aboutMe : aboutMe,
        localProfilePictureUri: (localProfilePictureUri == null) ? this.localProfilePictureUri : localProfilePictureUri,
        remoteProfilePictureUri: (remoteProfilePictureUri == null)
            ? this.remoteProfilePictureUri
            : remoteProfilePictureUri,
        localBackgroundPictureUri: (localBackgroundPictureUri == null)
            ? this.localBackgroundPictureUri
            : localBackgroundPictureUri,
        remoteBackgroundPictureUri: (remoteBackgroundPictureUri == null)
            ? this.remoteBackgroundPictureUri
            : remoteBackgroundPictureUri,
        fans: (fans == null) ? this.fans : fans,
        booksPdf: (booksPdf == null) ? this.booksPdf : booksPdf,
        booksEpub: (booksEpub == null) ? this.booksEpub : booksEpub
    );
  }
}
