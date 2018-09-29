import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_backend/data_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/constants.dart';


class PdfDataRepository extends DataRepository {
  
  PdfDataRepository(Firestore firestore) : super(firestore: firestore);

  Future<void> updateBookCoverPictureReferences(
      String encodedEmail, BookPdf book, String localCoverUri, String remoteCoverUri) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userBookReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);

    Map<String, dynamic> userBookToUpdate = {
      "booksPdf.${book.uID}.localCoverUri": localCoverUri,
      "booksPdf.${book.uID}.remoteCoverUri": remoteCoverUri
    };

    DocumentReference bookReference =
        firestore.collection(resolveCollectionLanguageLocation(book.language)).document(book.uID);

    Map<String, dynamic> bookToUpdate = {"localCoverUri": localCoverUri, "remoteCoverUri": remoteCoverUri};

    writeBatch.updateData(userBookReference, userBookToUpdate);
    writeBatch.updateData(bookReference, bookToUpdate);

    return writeBatch.commit();
  }

  Future<void> updateBookTitle(String encodedEmail, BookPdf editedBook) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        firestore.collection(resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {"booksPdf.${editedBook.uID}.title": editedBook.title};
    Map<String, dynamic> valueToUpdateOnBook = {"title": editedBook.title};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateBookSynopsis(String encodedEmail, BookPdf book, String newSynopsis) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        firestore.collection(resolveCollectionLanguageLocation(book.language)).document(book.uID);

    Map<String, dynamic> valueToUpdateOnUser = {"booksPdf.${book.uID}.synopsis": newSynopsis};
    Map<String, dynamic> valueToUpdateOnBook = {"synopsis": newSynopsis};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateBookCompletionStatus(String encodedEmail, BookPdf editedBook) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        firestore.collection(resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {
      "booksPdf.${editedBook.uID}.isCurrentlyComplete": editedBook.isCurrentlyComplete
    };

    Map<String, dynamic> valueToUpdateOnBook = {"isCurrentlyComplete": editedBook.isCurrentlyComplete};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateBookChapterPeriodicity(String encodedEmail, BookPdf editedBook) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference =
        firestore.collection(resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {
      "booksPdf.${editedBook.uID}.periodicity": editedBook.periodicity.toString().split(".")[1]
    };

    Map<String, dynamic> valueToUpdateOnBook = {"periodicity": editedBook.periodicity.toString().split(".")[1]};

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateSingleFileBookFile(String encodedEmail, BookPdf editedBook) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);

    DocumentReference bookReference =
        firestore.collection(resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {
      "booksPdf.${editedBook.uID}.localFullBookUri": editedBook.localFullBookUri,
      "booksPdf.${editedBook.uID}.remoteFullBookUri": editedBook.remoteFullBookUri,
      "booksPdf.${editedBook.uID}.publicationDate": editedBook.publicationDate
    };

    Map<String, dynamic> valueToUpdateOnBook = {
      "localFullBookUri": editedBook.localFullBookUri,
      "remoteFullBookUri": editedBook.remoteFullBookUri,
      "publicationDate": editedBook.publicationDate
    };

    writeBatch.updateData(userReference, valueToUpdateOnUser);

    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> updateMultiFileBookFiles(String encodedEmail, BookPdf editedBook) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);

    DocumentReference bookReference =
        firestore.collection(resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {
      "booksPdf.${editedBook.uID}.chapterUris": editedBook.chapterUris,
      "booksPdf.${editedBook.uID}.chapterTitles": editedBook.chapterTitles,
      "booksPdf.${editedBook.uID}.chaptersLaunchDates": editedBook.chaptersLaunchDates
    };

    Map<String, dynamic> valueToUpdateOnBook = {
      "chapterUris": editedBook.chapterUris,
      "chapterTitles": editedBook.chapterTitles,
      "chaptersLaunchDates": editedBook.chaptersLaunchDates
    };

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }

  Future<void> createNewBook(String encodedEmail, BookPdf book) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = firestore.collection(resolveCollectionLanguageLocation(book.language)).document();

    book.uID = bookReference.documentID;
    book.localCoverUri = await saveCoverOnPermanentLocalFile(book.localCoverUri, book.uID);

    await cleanupTemporaryFiles();

    Map<String, dynamic> bookToSaveOnUser = {"booksPdf.${book.uID}": book.toMap()};

    writeBatch.updateData(userReference, bookToSaveOnUser);
    writeBatch.setData(bookReference, book.toMap());

    return await writeBatch.commit();
  }
}
