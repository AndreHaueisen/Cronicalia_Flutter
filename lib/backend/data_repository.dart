import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:meta/meta.dart';
import 'package:flutter/painting.dart';

class DataRepository {
  final Firestore _firestore;

  //TODO: remove uniqueImmutableTitle from database

  DataRepository(this._firestore);

  //USER
  Future<User> getNewUser({@required User user}) async {
    DocumentSnapshot snapshot = await _firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail).get();

    if (snapshot != null && snapshot.exists) {
      user = new User.fromSnapshot(snapshot);
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
  Future<List<Book>> getBookRecommendations(BookLanguage preferredLanguage) async {

    String bookCollection = _resolveBookCollection(preferredLanguage);

    QuerySnapshot snapshot = await _firestore.collection(bookCollection).orderBy("genre").orderBy("rating", descending: true).getDocuments();

    List<Book> recommendedBooks = List<Book>();
    if (snapshot != null) {
      snapshot.documents.forEach((DocumentSnapshot documentSnapshot){
        Book book = Book.fromSnapshot(documentSnapshot);
        recommendedBooks.add(book);
      });

      return recommendedBooks;
    } else {
      return null;
    }
  }

  String _resolveBookCollection(BookLanguage preferredLanguage){

    switch(preferredLanguage){
      case BookLanguage.ENGLISH: {return Constants.COLLECTION_BOOKS_ENGLISH;}
      case BookLanguage.PORTUGUESE: {return Constants.COLLECTION_BOOKS_PORTUGUESE;}
      case BookLanguage.DEUTSCH: {return Constants.COLLECTION_BOOKS_DEUTSCH;}
      default: {return Constants.COLLECTION_BOOKS_ENGLISH;}
      }

  }

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

  Future<void> updateBookTitle(String encodedEmail, Book editedBook) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {"books.${editedBook.uID}.title": editedBook.title};
    Map<String, dynamic> valueToUpdateOnBook = {"title": editedBook.title};

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

  Future<void> updateBookCompletionStatus(String encodedEmail, Book editedBook) async{
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {"books.${editedBook.uID}.isCurrentlyComplete": editedBook.isCurrentlyComplete};
    Map<String, dynamic> valueToUpdateOnBook = {"isCurrentlyComplete": editedBook.isCurrentlyComplete};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return await writeBatch.commit();
  }

  Future<void> updateBookChapterPeriodicity(String encodedEmail, Book editedBook) async{
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {"books.${editedBook.uID}.periodicity": editedBook.periodicity.toString().split(".")[1]};
    Map<String, dynamic> valueToUpdateOnBook = {"periodicity": editedBook.periodicity.toString().split(".")[1]};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return await writeBatch.commit();
  }

  Future<void> createNewBook(String encodedEmail, Book book) async {
    WriteBatch writeBatch = _firestore.batch();
   
    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document();

    book.uID = bookReference.documentID;
    book.localPosterUri = await _savePosterOnPermanentLocalFile(book.localPosterUri, book.uID);
    book.localCoverUri = await _saveCoverOnPermanentLocalFile(book.localCoverUri, book.uID);

    await _cleanupTemporaryFiles();

    Map<String, dynamic> bookToSaveOnUser = {"books.${book.uID}": book.toMap()};

    writeBatch.updateData(userReference, bookToSaveOnUser);
    writeBatch.setData(bookReference, book.toMap());

    return await writeBatch.commit();
  }

  Future<String> _savePosterOnPermanentLocalFile(String tempPosterPath, String bookUID) async {
    File posterTempFile = File(tempPosterPath);
    File posterPicFile = await Utility.createFile(
        Constants.FOLDER_NAME_BOOKS,
        "${bookUID}_${Constants.FILE_NAME_SUFFIX_POSTER_PICTURE}");

    await Utility.saveImageToLocalCache(posterTempFile, posterPicFile);
    return posterPicFile.path;
  }

  Future<String> _saveCoverOnPermanentLocalFile(String tempCoverPath, String bookUID) async {
    File coverTempFile = File(tempCoverPath);
    File coverPicFile = await Utility.createFile(
        Constants.FOLDER_NAME_BOOKS,
        "${bookUID}_${Constants.FILE_NAME_SUFFIX_COVER_PICTURE}");

    await Utility.saveImageToLocalCache(coverTempFile, coverPicFile);
    return coverPicFile.path;
  }

  Future<void> _cleanupTemporaryFiles() async {
    await Utility.deleteFile(Constants.FOLDER_NAME_BOOKS, "${Constants.FILE_NAME_TEMP_POSTER_PICTURE}");
    await Utility.deleteFile(Constants.FOLDER_NAME_BOOKS, "${Constants.FILE_NAME_TEMP_COVER_PICTURE}");
    imageCache.clear();
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
