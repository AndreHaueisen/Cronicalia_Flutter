import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_repository.dart';
import 'package:cronicalia_flutter/backend/file_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_flux/flutter_flux.dart';

class UserStore extends Store {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  FileRepository fileRepository;
  DataRepository dataRepository;

  String _userEmail = "";
  bool _isLoggedIn = false;
  User _user = new User(
      name: "Unknown",
      encodedEmail: "Unknown",
      twitterProfile: "",
      aboutMe: "",
      /*localProfilePictureUri: "",
      remoteProfilePictureUri: "",*/
      localBackgroundPictureUri: "",
      remoteBackgroundPictureUri: "",
      fans: 0);

  UserStore() {
    fileRepository = FileRepository(_storageReference);
    dataRepository = DataRepository(_firestore);

    triggerOnAction(getUserFromCacheAction, (User newUser){
      _user = newUser;

    });

    triggerOnConditionalAction(getUserFromServerAction, (List<String> userInitialData) {
      this._userEmail = userInitialData[0];
      String photoUrl = userInitialData[1];

      dataRepository.getNewUser(_userEmail, photoUrl).then((User user) {
        if (user != null) {
          this._user = user;
          print("user loaded in store");
          trigger();
        } else {
          print('User not found.');
        }
      });

      return false;
    });

    triggerOnConditionalAction(updateUserProfileImageAction, (String localUri) {
      fileRepository.updateUserProfileImage(_user.encodedEmail, localUri, dataRepository).then((_) {
        dataRepository.getUser(_user.encodedEmail).then((user){
          if(user != null){
            _user = user;
            print("user loaded in store");
            // Do not need to trigger()
          }
        });
        return false;
      });
    });

    triggerOnConditionalAction(updateUserBackgroundImageAction, (String localUri) {
      fileRepository.updateUserBackgroundImage(_user.encodedEmail, localUri, dataRepository).then((_) {
        dataRepository.getUser(_user.encodedEmail).then((user){
          if(user != null){
            _user = user;
            print("user loaded in store");
            // Do not need to trigger()
          }
        });
        return false;
      });
    });

    triggerOnConditionalAction(changeLoginStatusAction, (bool isLoggedIn){
      this._isLoggedIn = isLoggedIn;
      return false;
    });

    triggerOnAction(updateUserNameAction, (String newName){
      this._user.name = newName;
      this._user.books.forEach((_, book){
        book.authorName = newName;
      });
      dataRepository.updateUserName(this._user);
    });

    triggerOnAction(updateUserTwitterProfileAction, (String newTwitterProfile){
      this._user.twitterProfile = newTwitterProfile;
      this._user.books.forEach((_, book){
        book.authorTwitterProfile = newTwitterProfile;
      });
      dataRepository.updateUserTwitterProfile(this._user);
    });

    triggerOnAction(updateUserAboutMeAction, (String newAboutMe){
      this._user.aboutMe = newAboutMe;
      dataRepository.updateUserAboutMe(this._user);
    });

    triggerOnConditionalAction(updateBookPosterImageAction, (List<String> payload){
      String bookKey = payload[0];
      String localUri = payload[1];

      fileRepository.updateBookPosterImage(_user.encodedEmail, _user.books[bookKey], localUri, dataRepository).then((_){
        dataRepository.getUser(_user.encodedEmail).then((user){
          if(user != null){
            _user = user;
            print("user loaded in store");
            // Do not need to trigger()
          }
        });
      });

      //TODO: may have to be true
      return false;
    });

    triggerOnConditionalAction(updateBookCoverImageAction, (List<String> payload){
      String bookKey = payload[0];
      String localUri = payload[1];

      fileRepository.updateBookCoverImage(_user.encodedEmail, _user.books[bookKey], localUri, dataRepository).then((_){
        dataRepository.getUser(_user.encodedEmail).then((user){
          if(user != null){
            _user = user;
            print("user loaded in store");
            // Do not need to trigger()
          }
        });
      });

      //TODO: may have to be true
      return false;
    });

    triggerOnAction(updateBookTitleAction, (List<String> payload){
      String bookKey = payload[0];
      String newTitle = payload[1];

      Book book = this._user.books[bookKey];
      book.title = newTitle;

      dataRepository.updateBookTitle(_user.encodedEmail, book, newTitle);

    });
    triggerOnAction(updateBookSynopsisAction, (List<String> payload){
      String bookKey = payload[0];
      String newSynopsis = payload[1];

      Book book = this._user.books[bookKey];
      book.synopsis = newSynopsis;

      dataRepository.updateBookSynopsis(_user.encodedEmail, book, newSynopsis);
    });
  }

  User get user => _user;

  String get userEmail => _userEmail;

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> isLoggedInAsync() async{
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();

    if(firebaseUser != null){
      _isLoggedIn = true;
      _userEmail = firebaseUser.email;
      return true;
    } else {
      _isLoggedIn = false;
      _userEmail = null;
      return false;
    }

  }

}

final StoreToken userStoreToken = new StoreToken(UserStore());

/// userInitialData[0] contains user email
/// userInitialData[1] contains user photoUrl
final Action<List<String>> getUserFromServerAction = new Action<List<String>>();
final Action<User> getUserFromCacheAction = new Action<User>();
final Action<bool> changeLoginStatusAction = new Action<bool>();

final Action<String> updateUserProfileImageAction = new Action<String>();
final Action<String> updateUserBackgroundImageAction = new Action<String>();
final Action<String> updateUserNameAction = new Action<String>();
final Action<String> updateUserTwitterProfileAction = new Action<String>();
final Action<String> updateUserAboutMeAction = new Action<String>();

/// payload[0] contains user bookKey
/// payload[1] contains user localUri
final Action<List<String>> updateBookPosterImageAction = new Action<List<String>>();
/// payload[0] contains user bookKey
/// payload[1] contains user localUri
final Action<List<String>> updateBookCoverImageAction = new Action<List<String>>();
/// payload[0] contains user bookKey
/// payload[1] contains user newTitle
final Action<List<String>> updateBookTitleAction = new Action<List<String>>();
/// payload[0] contains user bookKey
/// payload[1] contains user newSynopsis
final Action<List<String>> updateBookSynopsisAction = new Action<List<String>>();
