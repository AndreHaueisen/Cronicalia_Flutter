import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/backend/data_repository.dart';
import 'package:cronicalia_flutter/backend/file_repository.dart';
import 'package:cronicalia_flutter/login_screen/login_handler.dart';
import 'package:cronicalia_flutter/models/book_epub.dart';
import 'package:cronicalia_flutter/models/book_pdf.dart';
import 'package:cronicalia_flutter/models/progress_stream.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:cronicalia_flutter/utils/utility_book.dart';
import 'package:epub/epub.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flux/flutter_flux.dart';

class UserStore extends Store {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  FileRepository _fileRepository;
  DataRepository _dataRepository;
  LoginHandler _loginHandler;

  ProgressStream _progressStream = new ProgressStream();

  bool _isLoggedIn = false;
  User _user = User.empty();

  UserStore() {
    _fileRepository = FileRepository(_storageReference);
    _dataRepository = DataRepository(_firestore);
    _loginHandler = LoginHandler(_firebaseAuth, _firestore);

    triggerOnConditionalAction(loginWithEmailAction, (List<dynamic> payload) {
      String email = payload[0];
      String name = payload[1];
      String password = payload[2];
      bool isUserNew = payload[3];
      BuildContext context = payload[4];
      Completer<bool> _loggedStatusCompleter = payload[5];

      Flushbar infoFlushbar = FlushbarHelper.createInformation(message: "Loading credentials", duration: null);
      infoFlushbar.show(context);

      if (isUserNew) {
        _loginHandler.createUserOnFirebaseWithEmailAndPassword(email, name, password).then((User user) {
          _onLogin(infoFlushbar, user, context, isUserNew, _loggedStatusCompleter);
        }).catchError((error) {
          _onLoginError(infoFlushbar, error, context, _loggedStatusCompleter);
        });
      } else {
        _loginHandler.signIntoFirebaseWithEmailAndPassword(email, password).then((User user) {
          _onLogin(infoFlushbar, user, context, isUserNew, _loggedStatusCompleter);
        }).catchError((error) {
          _onLoginError(infoFlushbar, error, context, _loggedStatusCompleter);
        });
      }

      return false;
    });
    triggerOnConditionalAction(loginWithGoogleAction, (List<dynamic> payload) {
      bool isUserNew = payload[0];
      BuildContext context = payload[1];
      Completer<bool> _loggedStatusCompleter = payload[2];

      Flushbar infoFlushbar = FlushbarHelper.createInformation(
        message: "Loading Google credentials",
        duration: null,
      );
      infoFlushbar.show(context);

      _loginHandler.signIntoFirebaseWithGoogle(isUserNew).then((User user) {
        _onLogin(infoFlushbar, user, context, isUserNew, _loggedStatusCompleter);
      }).catchError((error) {
        _onLoginError(infoFlushbar, error, context, _loggedStatusCompleter);
      });

      return false;
    });
    triggerOnConditionalAction(loginWithFacebookAction, (List<dynamic> payload) {
      bool isUserNew = payload[0];
      BuildContext context = payload[1];
      Completer<bool> _loggedStatusCompleter = payload[2];

      Flushbar infoFlushbar = FlushbarHelper.createInformation(
        message: "Loading Facebook credentials",
        duration: null,
      );
      infoFlushbar.show(context);

      _loginHandler.signIntoFirebaseWithFacebook(isUserNew).then((User user) {
        _onLogin(infoFlushbar, user, context, isUserNew, _loggedStatusCompleter);
      }).catchError((error) {
        _onLoginError(infoFlushbar, error, context, _loggedStatusCompleter);
      });

      return false;
    });
    triggerOnConditionalAction(loginWithTwitterAction, (List<dynamic> payload) {
      bool isUserNew = payload[0];
      BuildContext context = payload[1];
      Completer<bool> _loggedStatusCompleter = payload[2];

      Flushbar infoFlushbar = FlushbarHelper.createInformation(
        message: "Loading Twitter credentials",
        duration: null,
      );
      infoFlushbar.show(context);

      _loginHandler.signIntoFirebaseWithTwitter(isUserNew).then((User user) {
        _onLogin(infoFlushbar, user, context, isUserNew, _loggedStatusCompleter);
      }).catchError((error) {
        _onLoginError(infoFlushbar, error, context, _loggedStatusCompleter);
      });

      return false;
    });

    triggerOnConditionalAction(changeLoginStatusAction, (bool isLoggedIn) {
      this._isLoggedIn = isLoggedIn;
      return false;
    });

    triggerOnConditionalAction(logoutAction, (_) {
      _logout().then((_) {
        trigger();
      });
      return false;
    });

    triggerOnConditionalAction(requestNewPasswordAction, (List<dynamic> payload) {
      String email = payload[0];
      BuildContext context = payload[1];

      _loginHandler.requestForgotPasswordEmail(email).then((_) {
        FlushbarHelper.createInformation(message: "Email sent. Check your inbox").show(context);
      }).catchError((error) {
        FlushbarHelper.createError(message: error.toString()).show(context);
      });
      return false;
    });

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

    triggerOnAction(updateUserNameAction, (String newName) {
      this._user.name = newName;
      this._user.booksPdf.forEach((_, book) {
        book.authorName = newName;
      });
      _dataRepository.updateUserName(this._user);
    });

    triggerOnAction(updateUserTwitterProfileAction, (String newTwitterProfile) {
      this._user.twitterProfile = newTwitterProfile;
      this._user.booksPdf.forEach((_, book) {
        book.authorTwitterProfile = newTwitterProfile;
      });
      _dataRepository.updateUserTwitterProfile(this._user);
    });

    triggerOnAction(updateUserAboutMeAction, (String newAboutMe) {
      this._user.aboutMe = newAboutMe;
      _dataRepository.updateUserAboutMe(this._user);
    });

    triggerOnConditionalAction(updateBookCoverImageAction, (List<dynamic> payload) {
      String bookUID = payload[0] as String;
      String localUri = payload[1] as String;
      BuildContext context = payload[2] as BuildContext;

      _user.booksPdf[bookUID].localCoverUri = localUri;

      _fileRepository.updateBookCoverImage(_user.encodedEmail, _user.booksPdf[bookUID], localUri, _dataRepository).then((_) {
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

      BookPdf book = this._user.booksPdf[bookKey];
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

      BookPdf book = this._user.booksPdf[bookKey];
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

      BookPdf book = this._user.booksPdf[bookKey];
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

      BookPdf book = this._user.booksPdf[bookKey];
      book.periodicity = newPeriodicity;

      _dataRepository.updateBookChapterPeriodicity(_user.encodedEmail, book).then((_) {
        FlushbarHelper.createSuccess(
                message:
                    "Your readers will expect a new chapter ${UtilityBook.convertPeriodicityToString(newPeriodicity).toLowerCase()}")
            .show(context);

        trigger();
      }, onError: () {
        FlushbarHelper.createError(message: "Periodicity could not be updated").show(context);
      }).timeout(Duration(seconds: 4), onTimeout: () {
        FlushbarHelper.createError(message: "Connection failed").show(context);
      });

      return false;
    });

    triggerOnConditionalAction(updateBookFilesAction, (BookPdf modifiedBook) {
      BookPdf originalBook = user.booksPdf[modifiedBook.uID];
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

    triggerOnConditionalAction(createCompleteBookAction, (BookPdf book) {
      const int numberOfFilesToBeUploaded = 2;
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
      BookPdf book = payload[0];
      List<String> pdfLocalPaths = payload[1];
      const int pictureFilesNumber = 1;
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

    triggerOnConditionalAction(createEpubBookAction, (List<dynamic> payload){
      EpubBook book = payload[0];
      String epubFilePath = payload[1];

      //_fileRepository.createNewEpubBook();

    });
  }

  User get user => _user;

  ProgressStream getProgressStream() {
    return _progressStream;
  }

  bool get isLoggedIn => _isLoggedIn;

  void _onLogin(Flushbar infoFlushbar, User user, BuildContext context, bool isUserNew, Completer<bool> logInCompleter) {
    _isLoggedIn = true;

    isUserNew ? getUserFromCacheAction(user) : getUserFromServerAction(user);
    infoFlushbar.dismiss().then((_) {
      logInCompleter.complete(true);
    });
  }

  void _onLoginError(Flushbar infoFlushbar, dynamic error, BuildContext context, Completer<bool> logInCompleter) {
    _isLoggedIn = false;
    infoFlushbar.dismiss().then((_) {
      logInCompleter.complete(false);
      FlushbarHelper.createError(message: error.toString(), duration: null).show(context);
    });
  }

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

  Future<void> _logout() async {
    await _firebaseAuth.signOut();
    await _loginHandler.signOutFromGoogle();
    _user = User.empty();
    _isLoggedIn = false;

    return;
  }
}

final StoreToken userStoreToken = new StoreToken(UserStore());

/// payload[0] contains user email
/// payload[1] contains user name. name == null is user is not new
/// payload[2] contains user password
/// payload[3] contains bool indicating if user is new
/// payload[4] contains context
/// payload[5] contains a completer to report when log in process finished
final Action<List<dynamic>> loginWithEmailAction = Action<List<dynamic>>();

/// payload[0] contains isUserNew
/// payload[1] contains context
/// payload[2] contains a completer to report when log in process finished
final Action<List<dynamic>> loginWithGoogleAction = Action<List<dynamic>>();

/// payload[0] contains isUserNew
/// payload[1] contains context
/// payload[2] contains a completer to report when log in process finished
final Action<List<dynamic>> loginWithFacebookAction = Action<List<dynamic>>();

/// payload[0] contains isUserNew
/// payload[1] contains context
/// payload[2] contains a completer to report when log in process finished
final Action<List<dynamic>> loginWithTwitterAction = Action<List<dynamic>>();

/// payload[0] contains user email
/// payload[1] contains context
final Action<List<dynamic>> requestNewPasswordAction = Action<List<dynamic>>();

/// userInitialData[0] contains user email
/// userInitialData[1] contains user photoUrl
final Action<User> getUserFromServerAction = new Action<User>();
final Action<User> getUserFromCacheAction = new Action<User>();
final Action<bool> changeLoginStatusAction = new Action<bool>();
final Action<void> logoutAction = new Action();

final Action<String> updateUserProfileImageAction = new Action<String>();
final Action<String> updateUserBackgroundImageAction = new Action<String>();
final Action<String> updateUserNameAction = new Action<String>();
final Action<String> updateUserTwitterProfileAction = new Action<String>();
final Action<String> updateUserAboutMeAction = new Action<String>();

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

///contains the bookPdf with file alterations
Action<BookPdf> updateBookFilesAction = Action<BookPdf>();

final Action<BookPdf> createCompleteBookAction = new Action<BookPdf>();

/// payload[0] contains book
/// payload[1] contains local pdf file paths
final Action<List<dynamic>> createIncompleteBookAction = new Action<List<dynamic>>();

/// payload[0] contains bookEpub
/// payload[1] contains path to raw Epub file
final Action<List<dynamic>> createEpubBookAction = Action<List<dynamic>>();