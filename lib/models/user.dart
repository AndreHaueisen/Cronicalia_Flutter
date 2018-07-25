import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/models/book.dart';

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
  Map<String, Book> books;

  User({this.name,
    this.encodedEmail,
    this.twitterProfile,
    this.aboutMe,
    this.localProfilePictureUri,
    this.remoteProfilePictureUri,
    this.localBackgroundPictureUri,
    this.remoteBackgroundPictureUri,
    this.fans,
    this.books});

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
      this.books = new Map<String, Book>();
      LinkedHashMap booksLinkedMap = (snapshot.data['books'] as LinkedHashMap);
      if (booksLinkedMap != null) {
        booksLinkedMap.forEach((key, value) {
          books[key] = Book.fromLinkedMap(value);
        });
      }
    }
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
      "books" : this.books
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
        books == that.books;
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
        books.hashCode;
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
    Map<String, Book> books}) {
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
        books: (books == null) ? this.books : books
    );
  }
}
