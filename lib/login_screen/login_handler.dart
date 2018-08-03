import 'dart:async';

import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef void LoginStatusCallback(LoginState loginState,
    {String title, String message, User newUser});

enum LoginState { LOGGED_IN, LOGGED_OUT, LOADING, ERROR, PASSWORD_RESET }
enum ProviderOptions { GOOGLE, FACEBOOK, TWITTER, PASSWORD }

class LoginHandler {
  final FirebaseAuth firebaseAuth;
  final Firestore firestore;
  final LoginStatusCallback loginStatusCallback;

  LoginHandler(this.firebaseAuth, this.firestore, this.loginStatusCallback);

  Future<bool> isSignedIn() async {
    if (await firebaseAuth.currentUser() == null)
      return false;
    else
      return true;
  }

  signOut() {
    firebaseAuth.signOut();
  }

  Future<List<String>> resolveProviders(String email) async {
    if (email != null) {
      List<String> providers = await firebaseAuth.fetchProvidersForEmail(email: email);
      return providers;
    }
    return null;
  }

  void signIntoFirebaseWithGoogle(bool isUserNew) async {
    loginStatusCallback(LoginState.LOADING,
        title: "Loading credentials", message: "Wait while we confirm your ID with Google");

    Map googleCredentials = await _getCredentialsUsingGoogle();

    FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(
        idToken: googleCredentials[Constants.GOOGLE_ID_TOKEN],
        accessToken: googleCredentials[Constants.GOOGLE_ACCESS_TOKEN]);

    if (firebaseUser == null) {
      throw ("firebase user returned null");
    }

    _saveUserLoginDataOnDatabase(firebaseUser, isUserNew);
  }

  Future<Map<String, String>> _getCredentialsUsingGoogle() async {
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: [
        'profile',
        'email',
      ],
    );
    GoogleSignInAccount googleAccount;

    try {
      if (await _googleSignIn.isSignedIn()) {
        googleAccount = _googleSignIn.currentUser;
      } else {
        googleAccount = await _googleSignIn.signIn();
      }

      if (googleAccount == null) throw ("Google sign in failed");

      GoogleSignInAuthentication authentication = await googleAccount.authentication;

      if (authentication == null) {
        throw ("Google sign in failed");
      }

      return {
        Constants.GOOGLE_ID_TOKEN: authentication.idToken,
        Constants.GOOGLE_ACCESS_TOKEN: authentication.accessToken
      };
    } catch (error) {
      loginStatusCallback(LoginState.ERROR, title: "Error", message: error);
      print(error);
      return null;
    }
  }

  void signIntoFirebaseWithFacebook(bool isUserNew) async {
    loginStatusCallback(LoginState.LOADING,
        title: "Loading credentials", message: "Wait while we confirm your ID with Facebook");

    String accessToken = await _getCredentialsUsingFacebook();

    FirebaseUser firebaseUser = await firebaseAuth.signInWithFacebook(accessToken: accessToken);

    if (firebaseUser == null) {
      throw ("Firebase user returned null");
    }

    _saveUserLoginDataOnDatabase(firebaseUser, isUserNew);
  }

  Future<String> _getCredentialsUsingFacebook() async {
    try {
      FacebookLogin facebookLogin = FacebookLogin();
      FacebookLoginResult loginResult = await facebookLogin.logInWithReadPermissions(['email']);

      switch (loginResult.status) {
        case FacebookLoginStatus.loggedIn:
          return loginResult.accessToken.token;

        case FacebookLoginStatus.cancelledByUser:
          throw ("Login canceled");
        case FacebookLoginStatus.error:
          throw ("Facebook credentials failed");
        default:
          throw ("Unknown error");
      }
    } catch (error) {
      loginStatusCallback(LoginState.ERROR, title: "Error", message: error);
      print(error);
      return null;
    }
  }

  void signIntoFirebaseWithTwitter(bool isUserNew) async {
    loginStatusCallback(LoginState.LOADING,
        title: "Loading credentials", message: "Wait while we confirm your ID with Twitter");

    Map twitterCredentials = await _getCredentialsUsingTwitter();

    FirebaseUser firebaseUser = await firebaseAuth.signInWithTwitter(
        authToken: twitterCredentials[Constants.TWITTER_CONSUMER_KEY],
        authTokenSecret: twitterCredentials[Constants.TWITTER_CONSUMER_SECRET]);

    if (firebaseUser == null) {
      throw ("firebase user returned null");
    }

    _saveUserLoginDataOnDatabase(firebaseUser, isUserNew);
  }

  Future<Map<String, String>> _getCredentialsUsingTwitter() async {
    try {
      

      final TwitterLoginResult result = await twitterLogin.authorize();

      switch (result.status) {
        case TwitterLoginStatus.loggedIn:
          var session = result.session;
          return {Constants.TWITTER_CONSUMER_KEY: session.token, Constants.TWITTER_CONSUMER_SECRET: session.secret};

        case TwitterLoginStatus.cancelledByUser:
          throw ("Login canceled");

        case TwitterLoginStatus.error:
          throw ("Twitter credentials failed");

        default:
          throw ("Unknown error");
      }
    } catch (error) {
      loginStatusCallback(LoginState.ERROR, title: "Error", message: error);
      print(error);
      return null;
    }
  }

  createUserOnFirebaseWithEmailAndPassword(String email, String password) async {
    loginStatusCallback(LoginState.LOADING,
        title: "Creating account", message: "Wait while we create you a new account");

    firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).then((firebaseUser) {
      if (firebaseUser != null) {
        _saveUserLoginDataOnDatabase(firebaseUser, true);
      }
    }).catchError((error) {
      loginStatusCallback(LoginState.ERROR, title: "Error", message: error.message);
      print(error);
    });
  }

  signIntoFirebaseWithEmailAndPassword(String email, String password) async {
    loginStatusCallback(LoginState.LOADING,
        title: "Loading credentials", message: "Wait while we confirm your ID with the database");

    firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((firebaseUser) {
      if (firebaseUser != null) {
        _saveUserLoginDataOnDatabase(firebaseUser, false);
      }
    }).catchError((error) {
      loginStatusCallback(LoginState.ERROR, title: "Error", message: error.message);
      print(error);
    });
  }

  requestForgotPasswordEmail(String email) {
    firebaseAuth.sendPasswordResetEmail(email: email);
    loginStatusCallback(LoginState.PASSWORD_RESET,
        title: "Email sent", message: "Follow the intructions to reset your password");
  }

  Future<void> _saveUserLoginDataOnDatabase(FirebaseUser firebaseUser, bool isUserNew) async {
    if (firestore == null) {
      throw ("Firestore returned null");
    }

    String userEncodedEmail = firebaseUser.email.replaceAll('.', ',');
    String messageToken = await firebaseUser.getIdToken(refresh: false);
    String userUID = firebaseUser.uid;

    final Map<String, String> emailTokenMap = {userEncodedEmail: messageToken};
    final Map<String, String> emailUIDMap = {userEncodedEmail: userUID};

    User newUser = User(
        name: firebaseUser.displayName,
        encodedEmail: userEncodedEmail,
        remoteProfilePictureUri: firebaseUser.photoUrl,
        fans: 0,
        books: Map<String, Book>());

    final WriteBatch batch = firestore.batch();
    final DocumentReference messageTokensReference =
        firestore.collection(Constants.COLLECTION_CREDENTIALS).document(Constants.DOCUMENT_MESSAGE_TOKENS);
    final DocumentReference uidUserReference =
        firestore.collection(Constants.COLLECTION_CREDENTIALS).document(Constants.DOCUMENT_UID_MAPPINGS);

    if(isUserNew) _saveNewUserOnDatabase(batch, newUser);

    batch.setData(messageTokensReference, emailTokenMap, merge: true);
    batch.setData(uidUserReference, emailUIDMap, merge: true);

    batch.commit().then((value) {
      String title;
      if (firebaseUser.displayName == null) {
        title = "Hi!";
      } else {
        title = "Hi ${firebaseUser.displayName}!";
      }

      String message = "Your account data is beeing loaded. Welcome!";

      loginStatusCallback(LoginState.LOGGED_IN,
          title: title,
          message: message,
          newUser: newUser);
      print("token saved!");
    }, onError: (error) {
      loginStatusCallback(LoginState.ERROR, title: "Error", message: error.toString());
      print("token not saved");
    });
  }

  Future<void> _saveNewUserOnDatabase(WriteBatch batch, User newUser) async{
    final DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(newUser.encodedEmail);
    batch.setData(userReference, newUser.toMap(), merge: true);
  }
}
