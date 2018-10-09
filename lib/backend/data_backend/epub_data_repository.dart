import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_backend/data_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/constants.dart';

class EpubDataRepository extends DataRepository {
  EpubDataRepository(Firestore firestore) : super(firestore: firestore);

  Future<void> createNewBook(String encodedEmail, BookEpub book) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    DocumentReference bookReference = firestore.collection(resolveCollectionLanguageLocation(book.language)).document();

    book.uID = bookReference.documentID;

    //remove data from coverData. It is not needed on database
    book.coverData = null;

    Map<String, dynamic> bookToSaveOnUser = {"booksEpub.${book.uID}": book.toMap()};

    writeBatch.updateData(userReference, bookToSaveOnUser);
    writeBatch.setData(bookReference, book.toMap());

    return await writeBatch.commit();
  }

  Future<void> updateBookData(BookEpub editedBook) async {
    WriteBatch writeBatch = firestore.batch();

    DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(editedBook.authorEmailId);

    DocumentReference bookReference =
        firestore.collection(resolveCollectionLanguageLocation(editedBook.language)).document(editedBook.uID);

    Map<String, dynamic> valueToUpdateOnUser = {
      "booksEpub.${editedBook.uID}.remoteCoverUri": editedBook.remoteCoverUri,
      "booksEpub.${editedBook.uID}.localFullBookUri": editedBook.localFullBookUri,
      "booksEpub.${editedBook.uID}.remoteFullBookUri": editedBook.remoteFullBookUri,
      "booksEpub.${editedBook.uID}.synopsis": editedBook.synopsis,
      "booksEpub.${editedBook.uID}.chapterTitles": editedBook.chapterTitles,
      "booksEpub.${editedBook.uID}.chaptersLaunchDates": editedBook.chaptersLaunchDates
    };

    Map<String, dynamic> valueToUpdateOnBook = {
      "remoteCoverUri": editedBook.remoteCoverUri,
      "localFullBookUri": editedBook.localFullBookUri,
      "remoteFullBookUri": editedBook.remoteFullBookUri,
      "synopsis": editedBook.synopsis,
      "chapterTitles": editedBook.chapterTitles,
      "chaptersLaunchDates": editedBook.chaptersLaunchDates
    };

    writeBatch.updateData(userReference, valueToUpdateOnUser);
    writeBatch.updateData(bookReference, valueToUpdateOnBook);

    return writeBatch.commit();
  }
}
