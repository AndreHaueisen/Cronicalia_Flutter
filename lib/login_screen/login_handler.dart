import 'dart:async';

import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/models/user.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum LoginState { LOGGED_IN, LOGGED_OUT, LOADING, ERROR, PASSWORD_RESET }
enum ProviderOptions { GOOGLE, FACEBOOK, TWITTER, PASSWORD }

class LoginHandler {
  final FirebaseAuth firebaseAuth;
  final Firestore firestore;

  LoginHandler(this.firebaseAuth, this.firestore);

  Future<bool> isSignedIn() async {
    if (await firebaseAuth.currentUser() == null)
      return false;
    else
      return true;
  }

  signOut() {
    firebaseAuth.signOut();
  }

  Future<User> signIntoFirebaseWithGoogle(bool isUserNew) async {
    try {
      Map googleCredentials = await _getCredentialsUsingGoogle();

      FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(
          idToken: googleCredentials[Constants.GOOGLE_ID_TOKEN],
          accessToken: googleCredentials[Constants.GOOGLE_ACCESS_TOKEN]);

      if (firebaseUser == null) {
        throw ("firebase user returned null");
      }

      return _saveUserLoginDataOnDatabase(firebaseUser, isUserNew);
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<Map<String, String>> _getCredentialsUsingGoogle() async {
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: [
        'profile',
        'email',
      ],
    );
    GoogleSignInAccount googleAccount;

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

    return {Constants.GOOGLE_ID_TOKEN: authentication.idToken, Constants.GOOGLE_ACCESS_TOKEN: authentication.accessToken};
  }

  //remove this method when FirebaseAuth supports full signOut
  Future<void> signOutFromGoogle() async{
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: [
        'profile',
        'email',
      ],
    );

    if (await _googleSignIn.isSignedIn()) {
      _googleSignIn.signOut();
    } else {
      return;
    }
  }

  Future<User> signIntoFirebaseWithFacebook(bool isUserNew) async {
    try {
      String accessToken = await _getCredentialsUsingFacebook();

      FirebaseUser firebaseUser = await firebaseAuth.signInWithFacebook(accessToken: accessToken);

      if (firebaseUser == null) {
        throw ("Firebase user returned null");
      }

      return _saveUserLoginDataOnDatabase(firebaseUser, isUserNew);
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<String> _getCredentialsUsingFacebook() async {
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
  }

  Future<User> signIntoFirebaseWithTwitter(bool isUserNew) async {
    try {
      TwitterSession session = await _getCredentialsUsingTwitter();

      FirebaseUser firebaseUser = await firebaseAuth.signInWithTwitter(
          authToken: session.token,
          authTokenSecret: session.secret);

      if (firebaseUser == null) {
        throw ("firebase user returned null");
      }

      return _saveUserLoginDataOnDatabase(firebaseUser, isUserNew, twitterHandle: session.username);
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<TwitterSession> _getCredentialsUsingTwitter() async {
    

    final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        
        return result.session;

      case TwitterLoginStatus.cancelledByUser:
        throw ("Login canceled");

      case TwitterLoginStatus.error:
        throw ("Twitter credentials failed");

      default:
        throw ("Unknown error");
    }
  }

  Future<User> createUserOnFirebaseWithEmailAndPassword(String email, String password) async {
    try {
      FirebaseUser firebaseUser = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      return _saveUserLoginDataOnDatabase(firebaseUser, true);
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<User> signIntoFirebaseWithEmailAndPassword(String email, String password) async {
    try {
      FirebaseUser firebaseUser = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      return _saveUserLoginDataOnDatabase(firebaseUser, false);
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> requestForgotPasswordEmail(String email) async {
    try {
      return firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<User> _saveUserLoginDataOnDatabase(FirebaseUser firebaseUser, bool isUserNew, {String twitterHandle}) async {
    if (firestore == null) {
      throw ("Firestore returned null");
    }

    String userEncodedEmail = firebaseUser.email.replaceAll('.', ',');
    String messageToken = await firebaseUser.getIdToken(refresh: false);
    String userUID = firebaseUser.uid;

    final Map<String, String> emailTokenMap = {userEncodedEmail: messageToken};
    final Map<String, String> emailUIDMap = {userEncodedEmail: userUID};

    User user = User(
        name: firebaseUser.displayName,
        twitterProfile: twitterHandle != null ? "@$twitterHandle" : null,
        encodedEmail: userEncodedEmail,
        remoteProfilePictureUri: firebaseUser.photoUrl,
        fans: 0,
        books: Map<String, Book>());

    final WriteBatch batch = firestore.batch();
    final DocumentReference messageTokensReference =
        firestore.collection(Constants.COLLECTION_CREDENTIALS).document(Constants.DOCUMENT_MESSAGE_TOKENS);
    final DocumentReference uidUserReference =
        firestore.collection(Constants.COLLECTION_CREDENTIALS).document(Constants.DOCUMENT_UID_MAPPINGS);

    if (isUserNew) {
      final DocumentReference userReference = firestore.collection(Constants.COLLECTION_USERS).document(user.encodedEmail);
      batch.setData(userReference, user.toMap(), merge: true);
    }

    batch.setData(messageTokensReference, emailTokenMap, merge: true);
    batch.setData(uidUserReference, emailUIDMap, merge: true);

    await batch.commit();

    return user;
  }
}
