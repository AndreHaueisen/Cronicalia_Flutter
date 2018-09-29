import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_backend/data_repository.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:meta/meta.dart';

class UserDataRepository extends DataRepository {
  
  UserDataRepository(Firestore firestore) : super(firestore: firestore);

  Future<User> getNewUser({@required User user}) async {
    DocumentSnapshot snapshot = await firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail).get();

    if (snapshot != null && snapshot.exists) {
      user = new User.fromSnapshot(snapshot);
      return user;
    } else {
      return null;
    }
  }

  Future<User> getUser(String encodedEmail) async {
    DocumentSnapshot snapshot = await firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail).get();

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
    DocumentReference reference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    Map<String, dynamic> valuesToUpdate = {
      "localProfilePictureUri": localProfileImageUri,
      "remoteProfilePictureUri": remoteProfileImageUri
    };

    return reference.updateData(valuesToUpdate);
  }

  Future<void> updateUserBackgroundPictureReferences(
      String encodedEmail, String localBackgroundImageUri, String remoteBackgroundImageUri) async {
    DocumentReference reference = firestore.collection(Constants.COLLECTION_USERS).document(encodedEmail);
    Map<String, dynamic> valuesToUpdate = {
      "localBackgroundPictureUri": localBackgroundImageUri,
      "remoteBackgroundPictureUri": remoteBackgroundImageUri
    };

    return reference.updateData(valuesToUpdate);
  }

  Future<void> updateUserName(User user) async {
    DocumentReference referenceUser = firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
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
    DocumentReference referenceUser = firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
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
    DocumentReference reference = firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
    Map<String, dynamic> valuesToUpdate = {"aboutMe": user.aboutMe};

    return reference.updateData(valuesToUpdate);
  }
}
