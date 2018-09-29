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
}
