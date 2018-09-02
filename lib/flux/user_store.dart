import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_repository.dart';
import 'package:cronicalia_flutter/backend/file_repository.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/models/progress_stream.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flux/flutter_flux.dart';

class UserStore extends Store {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  FileRepository _fileRepository;
  DataRepository _dataRepository;
  ProgressStream _progressStream = new ProgressStream();

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
      books: new Map<String, Book>(),
      fans: 0);

  UserStore() {
    _fileRepository = FileRepository(_storageReference);
    _dataRepository = DataRepository(_firestore);

    triggerOnAction(getUserFromCacheAction, (User newUser) {
      _user = newUser;
    });

    triggerOnConditionalAction(getUserFromServerAction, (User user) {
      _dataRepository.getNewUser(user: user).then((User userFromDatabase) {
        if (userFromDatabase != null) {
          this._user = userFromDatabase;
          print("user loaded in store");
          trigger();
        } else {
          print('User not found.');
        }
      });

      return false;
    });

    triggerOnConditionalAction(updateUserProfileImageAction, (String localUri) {
      _fileRepository.updateUserProfileImage(_user.encodedEmail, localUri, _dataRepository).then((_) {
        _dataRepository.getUser(_user.encodedEmail).then((user) {
          if (user != null) {
            _user = user;
            print("user loaded in store");
            // Do not need to trigger()
          }
        });
        return false;
      });
    });

    triggerOnConditionalAction(updateUserBackgroundImageAction, (String localUri) {
      _fileRepository.updateUserBackgroundImage(_user.encodedEmail, localUri, _dataRepository).then((_) {
        _dataRepository.getUser(_user.encodedEmail).then((user) {
          if (user != null) {
            _user = user;
            print("user loaded in store");
            // Do not need to trigger()
          }
        });
        return false;
      });
    });

    triggerOnConditionalAction(changeLoginStatusAction, (bool isLoggedIn) {
      this._isLoggedIn = isLoggedIn;
      return false;
    });

    triggerOnAction(updateUserNameAction, (String newName) {
      this._user.name = newName;
      this._user.books.forEach((_, book) {
        book.authorName = newName;
      });
      _dataRepository.updateUserName(this._user);
    });

    triggerOnAction(updateUserTwitterProfileAction, (String newTwitterProfile) {
      this._user.twitterProfile = newTwitterProfile;
      this._user.books.forEach((_, book) {
        book.authorTwitterProfile = newTwitterProfile;
      });
      _dataRepository.updateUserTwitterProfile(this._user);
    });

    triggerOnAction(updateUserAboutMeAction, (String newAboutMe) {
      this._user.aboutMe = newAboutMe;
      _dataRepository.updateUserAboutMe(this._user);
    });

    triggerOnConditionalAction(updateBookPosterImageAction, (List<dynamic> payload) {
      String bookUID = payload[0] as String;
      String localUri = payload[1] as String;
      BuildContext context = payload[2] as BuildContext;

      //First update locally
      _user.books[bookUID].localPosterUri = localUri;

      _fileRepository.updateBookPosterImage(_user.encodedEmail, _user.books[bookUID], localUri, _dataRepository).then((_) {
        _dataRepository.getUser(_user.encodedEmail).then((user) {
          if (user != null) {
            _user = user;
            print("user loaded in store");
            trigger();

            FlushbarHelper.createSuccess(message: "Poster uploaded").show(context);
          }
        }, onError: () {
          FlushbarHelper.createError(message: "Poster upload failed").show(context);
        });
      }).timeout(Duration(seconds: 12), onTimeout: () {
        FlushbarHelper.createError(message: "Connection failed. New poster was not sent").show(context);
      });

      return false;
    });

    triggerOnConditionalAction(updateBookCoverImageAction, (List<dynamic> payload) {
      String bookUID = payload[0] as String;
      String localUri = payload[1] as String;
      BuildContext context = payload[2] as BuildContext;

      _user.books[bookUID].localCoverUri = localUri;

      _fileRepository.updateBookCoverImage(_user.encodedEmail, _user.books[bookUID], localUri, _dataRepository).then((_) {
        _dataRepository.getUser(_user.encodedEmail).then((user) {
          if (user != null) {
            _user = user;
            print("user loaded in store");
            trigger();

            FlushbarHelper.createSuccess(message: "Cover uploaded").show(context);
          }
        }, onError: () {
          FlushbarHelper.createError(message: "Cover upload failed").show(context);
        });
      }).timeout(Duration(seconds: 12), onTimeout: () {
        FlushbarHelper.createError(message: "Connection failed. New cover was not sent").show(context);
      });

      return false;
    });

    triggerOnConditionalAction(updateBookTitleAction, (List<dynamic> payload) {
      String bookKey = payload[0] as String;
      String newTitle = payload[1] as String;
      BuildContext context = payload[2] as BuildContext;

      Book book = this._user.books[bookKey];
      book.title = newTitle;

      _dataRepository.updateBookTitle(_user.encodedEmail, book).then((_) {
        FlushbarHelper.createSuccess(message: "Title updated").show(context);
        trigger();
      }, onError: () {
        FlushbarHelper.createError(message: "Title update failed").show(context);
      }).timeout(Duration(seconds: 4), onTimeout: () {
        FlushbarHelper.createError(message: "Connection failed").show(context);
      });

      return false;
    });

    triggerOnConditionalAction(updateBookSynopsisAction, (List<dynamic> payload) {
      String bookKey = payload[0] as String;
      String newSynopsis = payload[1] as String;
      BuildContext context = payload[2] as BuildContext;

      Book book = this._user.books[bookKey];
      book.synopsis = newSynopsis;

      _dataRepository.updateBookSynopsis(_user.encodedEmail, book, newSynopsis).then((_) {
        FlushbarHelper.createSuccess(message: "Synopsis updated").show(context);
        trigger();
      }, onError: () {
        FlushbarHelper.createError(message: "Synopsis update failed").show(context);
      }).timeout(Duration(seconds: 4), onTimeout: () {
        FlushbarHelper.createError(message: "Connection failed").show(context);
      });

      return false;
    });

    triggerOnConditionalAction(updateBookCompletionStatusAction, (List<dynamic> payload) {
      String bookKey = payload[0];
      bool isBookCurrentlyComplete = payload[1];
      BuildContext context = payload[2] as BuildContext;

      Book book = this._user.books[bookKey];
      book.isCurrentlyComplete = isBookCurrentlyComplete;

      _dataRepository.updateBookCompletionStatus(_user.encodedEmail, book).then((_) {
        trigger();
      }, onError: () {
        FlushbarHelper.createError(message: "Book status could not be updated").show(context);
      }).timeout(Duration(seconds: 4), onTimeout: () {
        FlushbarHelper.createError(message: "Connection failed").show(context);
      });

      return false;
    });

    triggerOnConditionalAction(updateBookChapterPeriodicityAction, (List<dynamic> payload) {
      String bookKey = payload[0];
      ChapterPeriodicity newPeriodicity = payload[1];
      BuildContext context = payload[2] as BuildContext;

      Book book = this._user.books[bookKey];
      book.periodicity = newPeriodicity;

      _dataRepository.updateBookChapterPeriodicity(_user.encodedEmail, book).then((_) {
        FlushbarHelper.createSuccess(
                message:
                    "Your readers will expect a new chapter ${Book.convertPeriodicityToString(newPeriodicity).toLowerCase()}")
            .show(context);

        trigger();
      }, onError: () {
        FlushbarHelper.createError(message: "Periodicity could not be updated").show(context);
      }).timeout(Duration(seconds: 4), onTimeout: () {
        FlushbarHelper.createError(message: "Connection failed").show(context);
      });

      return false;
    });

    triggerOnConditionalAction(updateBookFilesAction, (Book modifiedBook) {
      Book originalBook = user.books[modifiedBook.uID];
      _fileRepository
          .updateBookFiles(
              originalBook: originalBook,
              modifiedBook: modifiedBook,
              dataRepository: _dataRepository,
              progressStream: _progressStream)
          .then((_) {
        _dataRepository.getUser(_user.encodedEmail).then((user) {
          if (user != null) {
            _user = user;
            trigger();
            print("user loaded in store");
          }
        });
      }).catchError((_) {
        print("Complete book creation failed");
      });

      return false;
    });

    triggerOnConditionalAction(createCompleteBookAction, (Book book) {
      const int numberOfFilesToBeUploaded = 3;
      _progressStream.filesTotalNumber = numberOfFilesToBeUploaded;

      _fileRepository
          .createNewSingleFileBook(_user.encodedEmail, book, _dataRepository, progressStream: _progressStream)
          .then((_) {
        _dataRepository.getUser(_user.encodedEmail).then((user) {
          if (user != null) {
            _user = user;
            trigger();
            print("user loaded in store");
          }
        });
      }).catchError((_) {
        print("Complete book creation failed");
      });

      return false;
    });

    triggerOnConditionalAction(createIncompleteBookAction, (List<dynamic> payload) {
      Book book = payload[0];
      List<String> pdfLocalPaths = payload[1];
      const int pictureFilesNumber = 2;
      final int numberOfFilesToBeUploaded = pictureFilesNumber + pdfLocalPaths.length;
      _progressStream.filesTotalNumber = numberOfFilesToBeUploaded;

      _fileRepository
          .createNewMultiFileBook(_user.encodedEmail, book, pdfLocalPaths, _dataRepository, progressStream: _progressStream)
          .then((_) {
        _dataRepository.getUser(_user.encodedEmail).then((user) {
          if (user != null) {
            _user = user;
            trigger();
            print("user loaded in store");
          }
        });
      }).catchError((_) {
        print("Incomplete book creation failed");
      });

      return false;
    });
  }

  User get user => _user;

  ProgressStream getProgressStream() {
    return _progressStream;
  }

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> isLoggedInAsync() async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();

    if (firebaseUser != null) {
      _isLoggedIn = true;
      _user.encodedEmail = Utility.encodeEmail(firebaseUser.email);
      _user.name = firebaseUser.displayName;
      return true;
    } else {
      _isLoggedIn = false;

      return false;
    }
  }
}

final StoreToken userStoreToken = new StoreToken(UserStore());

/// userInitialData[0] contains user email
/// userInitialData[1] contains user photoUrl
final Action<User> getUserFromServerAction = new Action<User>();
final Action<User> getUserFromCacheAction = new Action<User>();
final Action<bool> changeLoginStatusAction = new Action<bool>();

final Action<String> updateUserProfileImageAction = new Action<String>();
final Action<String> updateUserBackgroundImageAction = new Action<String>();
final Action<String> updateUserNameAction = new Action<String>();
final Action<String> updateUserTwitterProfileAction = new Action<String>();
final Action<String> updateUserAboutMeAction = new Action<String>();

/// payload[0] contains book bookKey
/// payload[1] contains book localUri
/// payload[2] contains BuildContext
final Action<List<dynamic>> updateBookPosterImageAction = new Action<List<dynamic>>();

/// payload[0] contains book bookKey
/// payload[1] contains book localUri
/// payload[2] contains BuildContext
final Action<List<dynamic>> updateBookCoverImageAction = new Action<List<dynamic>>();

/// payload[0] contains book bookKey
/// payload[1] contains book newTitle
/// payload[2] contains BuildContext
final Action<List<dynamic>> updateBookTitleAction = new Action<List<dynamic>>();

/// payload[0] contains book bookKey
/// payload[1] contains book newSynopsis
/// payload[2] contains BuildContext
final Action<List<dynamic>> updateBookSynopsisAction = new Action<List<dynamic>>();

/// payload[0] contains book bookKey
/// payload[1] contains book idCurrentlyComplete
/// payload[2] contains BuildContext
final Action<List<dynamic>> updateBookCompletionStatusAction = new Action<List<dynamic>>();

/// payload[0] contains book bookKey
/// payload[1] contains book periodicity
/// payload[2] contains BuildContext
final Action<List<dynamic>> updateBookChapterPeriodicityAction = new Action<List<dynamic>>();

///contains the book with file alterations
Action<Book> updateBookFilesAction = Action<Book>();

final Action<Book> createCompleteBookAction = new Action<Book>();

/// payload[0] contains book
/// payload[1] contains local pdf file paths
final Action<List<dynamic>> createIncompleteBookAction = new Action<List<dynamic>>();
