import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';

class DataRepository {
  final Firestore _firestore;

  //TODO: remove uniqueImmutableTitle from database

  DataRepository(this._firestore);

  //USER
  Future<User> getNewUser(String decodedEmail, String photoUrl) async {
    DocumentSnapshot snapshot = await _firestore.collection(Constants.COLLECTION_USERS).document(Utility.encodeEmail(decodedEmail)).get();

    User user;

    if (snapshot != null && snapshot.exists) {
      user = new User.fromSnapshot(snapshot);
      if (user.localProfilePictureUri == null && user.remoteProfilePictureUri == null) {
        user.remoteProfilePictureUri = photoUrl;
      }
      return user;
    } else {
      return null;
    }
  }

  Future<User> getUser(String encodedEmail) async {
    DocumentSnapshot snapshot = await _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail).get();

    User user;

    if (snapshot != null && snapshot.exists) {
      user = new User.fromSnapshot(snapshot);
      return user;
    } else {
      return null;
    }
  }

  Future<void> updateUserProfilePictureReferences(String encodedEmail, String localProfileImageUri, String remoteProfileImageUri) async {
    DocumentReference reference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    Map<String, dynamic> valuesToUpdate = {
      "localProfilePictureUri": localProfileImageUri,
      "remoteProfilePictureUri": remoteProfileImageUri
    };

    return reference.updateData(valuesToUpdate);
  }

  Future<void> updateUserBackgroundPictureReferences(
      String encodedEmail, String localBackgroundImageUri, String remoteBackgroundImageUri) async {
    DocumentReference reference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    Map<String, dynamic> valuesToUpdate = {
      "localBackgroundPictureUri": localBackgroundImageUri,
      "remoteBackgroundPictureUri": remoteBackgroundImageUri
    };

    return reference.updateData(valuesToUpdate);
  }

  Future<void> updateUserName(User user) async {
    DocumentReference referenceUser = _firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
    Map<String, dynamic> valuesToUpdate = {"name": user.name};
    user.books.forEach((key, book) {
      valuesToUpdate.putIfAbsent("books.$key.authorName", () => user.name);
    });

    return referenceUser.updateData(valuesToUpdate);
  }

  Future<void> updateUserTwitterProfile(User user) async {
    DocumentReference referenceUser = _firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
    Map<String, dynamic> valuesToUpdate = {"twitterProfile": user.twitterProfile};
    user.books.forEach((key, book) {
      valuesToUpdate.putIfAbsent("books.$key.twitterProfile", () => user.twitterProfile);
    });

    return referenceUser.updateData(valuesToUpdate);
  }

  Future<void> updateUserAboutMe(User user) async {
    DocumentReference reference = _firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
    Map<String, dynamic> valuesToUpdate = {"aboutMe": user.aboutMe};

    return reference.updateData(valuesToUpdate);
  }

  //BOOK
  Future<void> updateBookPosterPictureReferences(String encodedEmail, Book book, String localPosterUri, String remotePosterUri) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userBookReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    Map<String, dynamic> userBookToUpdate = {
      "books.${book.uID}.localPosterUri": localPosterUri,
      "books.${book.uID}.remotePosterUri": remotePosterUri
    };

    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document(book.uID);
    Map<String, dynamic> bookToUpdate = {"localPosterUri": localPosterUri, "remotePosterUri": remotePosterUri};

    writeBatch.updateData(userBookReference, userBookToUpdate);
    writeBatch.updateData(bookReference, bookToUpdate);

    return await writeBatch.commit();
  }

  Future<void> updateBookCoverPictureReferences(String encodedEmail, Book book, String localCoverUri, String remoteCoverUri) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userBookReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    Map<String, dynamic> userBookToUpdate = {
      "books.${book.uID}.localCoverUri": localCoverUri,
      "books.${book.uID}.remoteCoverUri": remoteCoverUri
    };

    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document(book.uID);
    Map<String, dynamic> bookToUpdate = {"localCoverUri": localCoverUri, "remoteCoverUri": remoteCoverUri};

    writeBatch.updateData(userBookReference, userBookToUpdate);
    writeBatch.updateData(bookReference, bookToUpdate);

    return await writeBatch.commit();
  }

  Future<void> updateBookTitle(String encodedEmail, Book book, String newTitle) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document(book.uID);

    Map<String, dynamic> valueToUpdateOnUser = {"books.${book.uID}.title": newTitle};
    Map<String, dynamic> valueToUpdateOnBook = {"title": newTitle};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return await writeBatch.commit();
  }

  Future<void> updateBookSynopsis(String encodedEmail, Book book, String newSynopsis) async {
    WriteBatch writeBatch = _firestore.batch();


    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document(book.uID);

    Map<String, dynamic> valueToUpdateOnUser = {"books.${book.uID}.synopsis": newSynopsis};
    Map<String, dynamic> valueToUpdateOnBook = {"synopsis": newSynopsis};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return await writeBatch.commit();
  }

  Future<void> createNewBook(String encodedEmail, Book book) async {
    WriteBatch writeBatch = _firestore.batch();
   
    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document();

    book.uID = bookReference.documentID;
    Map<String, dynamic> bookToSaveOnUser = {"books.${book.uID}": book.toMap()};

    writeBatch.updateData(userReference, bookToSaveOnUser);
    writeBatch.setData(bookReference, book.toMap());

    return await writeBatch.commit();
  }

  String _resolveCollectionLanguageLocation(BookLanguage bookLanguage) {
    switch (bookLanguage) {
      case BookLanguage.ENGLISH:
        return Constants.COLLECTION_BOOKS_ENGLISH;
      case BookLanguage.PORTUGUESE:
        return Constants.COLLECTION_BOOKS_PORTUGUESE;
      case BookLanguage.DEUTSCH:
        return Constants.COLLECTION_BOOKS_DEUTSCH;
      case BookLanguage.UNDEFINED:
        return Constants.COLLECTION_BOOKS_ENGLISH;
      default:
        return Constants.COLLECTION_BOOKS_ENGLISH;
    }
  }
}
