import 'dart:async';

import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/login_screen/login_handler.dart';
import 'package:cronicalia_flutter/login_screen/widgets/old_user_login_widget.dart';
import 'package:cronicalia_flutter/login_screen/widgets/user_email_collector_widget.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cronicalia_flutter/login_screen/widgets/new_user_login_widget.dart';

void dismissFlushbar(Flushbar flushbar) {
  if (flushbar != null) {
    flushbar.dismiss();
  }
}

class LoginScreen extends StatefulWidget {
  LoginHandler _loginHandler;
  Flushbar _flushbar;
  final BuildContext context;

  LoginScreen(FirebaseAuth firebaseAuth, Firestore firestore, this.context) {
    _loginHandler = LoginHandler(firebaseAuth, firestore, (LoginState loginState,
        {String title, String message, String userName, String userEmail, String photoUrl}) {

      switch (loginState) {
        case LoginState.LOGGED_IN:
          {
      
            FlushbarHelper.createSuccess(title: title, message: message)
              ..onStatusChanged = (FlushbarStatus status) {
                if (status == FlushbarStatus.DISMISSED) {
                  getUserFromServerAction.call([userEmail, photoUrl]);

                  _loginHandler.isSignedIn().then((isSignedIn) {
                    changeLoginStatusAction(isSignedIn);
                  });

                  Navigator.of(context).pop();
                
                }
              }
              ..show(context);
            break;
          }

        case LoginState.LOADING:
          {
            _flushbar = FlushbarHelper.createInformation(title: title, message: message, duration: Duration(seconds: 4));
            _flushbar.show(context);

            break;
          }

        case LoginState.ERROR:
          {
            _flushbar = FlushbarHelper.createError(title: title, message: message);
            _flushbar.show(context);

            break;
          }

        case LoginState.PASSWORD_RESET:
          {
            _flushbar = FlushbarHelper.createSuccess(title: title, message: message);
            _flushbar.show(context);
            break;
          }

        case LoginState.LOGGED_OUT:
          break;
      }
    });
  }

  @override
  State createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  String _email;
  Future<List<String>> _providers = new Future.value(<String>[]);

  @override
  Widget build(BuildContext widgetContext) {
    return Scaffold(
        body: new AnimatedCrossFade(
      duration: new Duration(seconds: 1),
      firstChild: _emailCollectorWidget(),
      secondChild: _loginButtonsWidget(),
      alignment: Alignment.bottomCenter,
      crossFadeState: Utility.isEmailValid(_email) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    ));
  }

  Widget _emailCollectorWidget() {
    return new UserEmailCollectorWidget(
      loginHandler: widget._loginHandler,
      onEmailReady: (String email) {
        setState(() {
          _email = email;
          _providers = widget._loginHandler.resolveProviders(email);
        });
      },
    );
  }

  Widget _loginButtonsWidget() {
    return Container(
      child: Center(
        child: new FutureBuilder(
            future: _providers,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                return _getAppropriateUserLoginWidget(snapshot.data);
              } else {
                return Container(width: 0.0, height: 0.0);
              }
            }),
      ),
    );
  }

  Widget _getAppropriateUserLoginWidget(List<String> providers) {
    bool isNewUser = providers.isEmpty;

    if (isNewUser) {
      return NewUserLoginWidget(loginHandler: widget._loginHandler, email: _email);
    } else {
      bool shouldShowGoogle = providers.contains(Constants.PROVIDER_OPTIONS[ProviderOptions.GOOGLE]);
      bool shouldShowFacebook = providers.contains(Constants.PROVIDER_OPTIONS[ProviderOptions.FACEBOOK]);
      bool shouldShowTwitter = providers.contains(Constants.PROVIDER_OPTIONS[ProviderOptions.TWITTER]);
      bool shouldShowEmailAndPassword = providers.contains(Constants.PROVIDER_OPTIONS[ProviderOptions.PASSWORD]);

      return OldUserLoginWidget(
          loginHandler: widget._loginHandler,
          email: _email,
          shouldShowGoogle: shouldShowGoogle,
          shouldShowFacebook: shouldShowFacebook,
          shouldShowTwitter: shouldShowTwitter,
          shouldShowEmailAndPassword: shouldShowEmailAndPassword);
    }
  }
}
