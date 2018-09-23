import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/models/book_pdf.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:cronicalia_flutter/utils/utility_book.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:flutter/painting.dart';

class DataRepository {
  final Firestore _firestore;

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

  Future<void> updateUserProfilePictureReferences(
      String encodedEmail, String localProfileImageUri, String remoteProfileImageUri) async {
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
    user.booksPdf.forEach((key, book) {
      valuesToUpdate.putIfAbsent("booksPdf.$key.authorName", () => user.name);
    });
    user.booksEpub.forEach((key, book) {
      valuesToUpdate.putIfAbsent("booksEpub.$key.authorName", () => user.name);
    });

    return referenceUser.updateData(valuesToUpdate);
  }

  Future<void> updateUserTwitterProfile(User user) async {
    DocumentReference referenceUser = _firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
    Map<String, dynamic> valuesToUpdate = {"twitterProfile": user.twitterProfile};
    user.booksPdf.forEach((key, book) {
      valuesToUpdate.putIfAbsent("booksPdf.$key.twitterProfile", () => user.twitterProfile);
    });

    user.booksEpub.forEach((key, book) {
      valuesToUpdate.putIfAbsent("booksEpub.$key.twitterProfile", () => user.twitterProfile);
    });

    return referenceUser.updateData(valuesToUpdate);
  }

  Future<void> updateUserAboutMe(User user) async {
    DocumentReference reference = _firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
    Map<String, dynamic> valuesToUpdate = {"aboutMe": user.aboutMe};

    return reference.updateData(valuesToUpdate);
  }

  //BOOK
  Future<List<BookPdf>> getBookRecommendations(BookLanguage preferredLanguage) async {
    String bookCollection = _resolveBookCollection(preferredLanguage);

    QuerySnapshot snapshot =
        await _firestore.collection(bookCollection).orderBy("genre").orderBy("rating", descending: true).getDocuments();

    List<BookPdf> recommendedBooks = List<BookPdf>();
    if (snapshot != null) {
      snapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
        BookPdf book = BookPdf.fromSnapshot(documentSnapshot);
        recommendedBooks.add(book);
      });

      return recommendedBooks;
    } else {
      return null;
    }
  }

  String _resolveBookCollection(BookLanguage preferredLanguage) {
    switch (preferredLanguage) {
      case BookLanguage.ENGLISH:
        {
          return Constants.COLLECTION_BOOKS_ENGLISH;
        }
      case BookLanguage.PORTUGUESE:
        {
          return Constants.COLLECTION_BOOKS_PORTUGUESE;
        }
      case BookLanguage.DEUTSCH:
        {
          return Constants.COLLECTION_BOOKS_DEUTSCH;
        }
      default:
        {
          return Constants.COLLECTION_BOOKS_ENGLISH;
        }
    }
  }

  Future<void> updateBookCoverPictureReferences(
      String encodedEmail, var book, String localCoverUri, String remoteCoverUri) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userBookReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    Map<String, dynamic> userBookToUpdate;

    if (book is BookPdf) {
      userBookToUpdate = {
        "booksPdf.${book.uID}.localCoverUri": localCoverUri,
        "booksPdf.${book.uID}.remoteCoverUri": remoteCoverUri
      };
    } else {
      userBookToUpdate = {
        "booksEpub.${book.uID}.localCoverUri": localCoverUri,
        "booksEpub.${book.uID}.remoteCoverUri": remoteCoverUri
      };
    }

    DocumentReference bookReference =
        _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document(book.uID);
    Map<String, dynamic> bookToUpdate = {"localCoverUri": localCoverUri, "remoteCoverUri": remoteCoverUri};

    writeBatch.updateData(userBookReference, userBookToUpdate);
    writeBatch.updateData(bookReference, bookToUpdate);

    return writeBatch.commit();
  }

  Future<void> updateBookTitle(String encodedEmail, var editedBook) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        _firestore.collection(_resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser;
    if (editedBook is BookPdf) {
      valueToUpdateOnUser = {"booksPdf.${editedBook.uID}.title": editedBook.title};
    } else {
      valueToUpdateOnUser = {"booksEpub.${editedBook.uID}.title": editedBook.title};
    }

    Map<String, dynamic> valueToUpdateOnBook = {"title": editedBook.title};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateBookSynopsis(String encodedEmail, var book, String newSynopsis) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document(book.uID);

    Map<String, dynamic> valueToUpdateOnUser;
    if (book is BookPdf) {
      valueToUpdateOnUser = {"booksPdf.${book.uID}.synopsis": newSynopsis};
    } else {
      valueToUpdateOnUser = {"booksEpub.${book.uID}.synopsis": newSynopsis};
    }
    Map<String, dynamic> valueToUpdateOnBook = {"synopsis": newSynopsis};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateBookCompletionStatus(String encodedEmail, var editedBook) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        _firestore.collection(_resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser;
    if (editedBook is BookPdf) {
      valueToUpdateOnUser = {"booksPdf.${editedBook.uID}.isCurrentlyComplete": editedBook.isCurrentlyComplete};
    } else {
      valueToUpdateOnUser = {"booksEpub.${editedBook.uID}.isCurrentlyComplete": editedBook.isCurrentlyComplete};
    }
    Map<String, dynamic> valueToUpdateOnBook = {"isCurrentlyComplete": editedBook.isCurrentlyComplete};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateBookChapterPeriodicity(String encodedEmail, var editedBook) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        _firestore.collection(_resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser;
    if (editedBook is BookPdf) {
      valueToUpdateOnUser = {"booksPdf.${editedBook.uID}.periodicity": editedBook.periodicity.toString().split(".")[1]};
    } else {
      valueToUpdateOnUser = {"booksEpub.${editedBook.uID}.periodicity": editedBook.periodicity.toString().split(".")[1]};
    }
    Map<String, dynamic> valueToUpdateOnBook = {"periodicity": editedBook.periodicity.toString().split(".")[1]};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateSingleFileBookFile(String encodedEmail, var editedBook) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        _firestore.collection(_resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser;
    if (editedBook is BookPdf) {
      valueToUpdateOnUser = {
        "booksPdf.${editedBook.uID}.localFullBookUri": editedBook.localFullBookUri,
        "booksPdf.${editedBook.uID}.remoteFullBookUri": editedBook.remoteFullBookUri,
        "booksPdf.${editedBook.uID}.publicationDate": editedBook.publicationDate
      };
    } else {
      valueToUpdateOnUser = {
        "booksEpub.${editedBook.uID}.localFullBookUri": editedBook.localFullBookUri,
        "booksEpub.${editedBook.uID}.remoteFullBookUri": editedBook.remoteFullBookUri,
        "booksEpub.${editedBook.uID}.publicationDate": editedBook.publicationDate
      };
    }

    Map<String, dynamic> valueToUpdateOnBook = {
      "localFullBookUri": editedBook.localFullBookUri,
      "remoteFullBookUri": editedBook.remoteFullBookUri,
      "publicationDate": editedBook.publicationDate
    };

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateMultiFileBookFiles(String encodedEmail, var editedBook) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        _firestore.collection(_resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser;
    if (editedBook is BookPdf) {
      valueToUpdateOnUser = {
        "booksPdf.${editedBook.uID}.chapterUris": editedBook.chapterUris,
        "booksPdf.${editedBook.uID}.chapterTitles": editedBook.chapterTitles,
        "booksPdf.${editedBook.uID}.chaptersLaunchDates": editedBook.chaptersLaunchDates
      };
    } else {
      valueToUpdateOnUser = {
        "booksEpub.${editedBook.uID}.chapterUris": editedBook.chapterUris,
        "booksEpub.${editedBook.uID}.chapterTitles": editedBook.chapterTitles,
        "booksEpub.${editedBook.uID}.chaptersLaunchDates": editedBook.chaptersLaunchDates
      };
    }

    Map<String, dynamic> valueToUpdateOnBook = {
      "chapterUris": editedBook.chapterUris,
      "chapterTitles": editedBook.chapterTitles,
      "chaptersLaunchDates": editedBook.chaptersLaunchDates
    };

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> createNewBook(String encodedEmail, var book) async {
    WriteBatch writeBatch = _firestore.batch();

    DocumentReference userReference = _firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = _firestore.collection(_resolveCollectionLanguageLocation(book.language)).document();

    book.uID = bookReference.documentID;

    book.localCoverUri = await _saveCoverOnPermanentLocalFile(book.localCoverUri, book.uID);

    await _cleanupTemporaryFiles();

    Map<String, dynamic> bookToSaveOnUser;
    if (book is BookPdf) {
      bookToSaveOnUser = {"booksPdf.${book.uID}": book.toMap()};
    } else {
      bookToSaveOnUser = {"booksEpub.${book.uID}": book.toMap()};
    }

    writeBatch.updateData(userReference, bookToSaveOnUser);
    writeBatch.setData(bookReference, book.toMap());

    return await writeBatch.commit();
  }

  Future<String> _saveCoverOnPermanentLocalFile(String tempCoverPath, String bookUID) async {
    File coverTempFile = File(tempCoverPath);
    File coverPicFile =
        await Utility.createFile(Constants.FOLDER_NAME_BOOKS, "${bookUID}_${Constants.FILE_NAME_SUFFIX_COVER_PICTURE}");

    await Utility.saveImageToLocalCache(coverTempFile, coverPicFile);
    return coverPicFile.path;
  }

  Future<void> _cleanupTemporaryFiles() async {
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
