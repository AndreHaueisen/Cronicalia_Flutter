import 'dart:async';

import 'package:cronicalia_flutter/login_screen/login_handler.dart';
import 'package:cronicalia_flutter/login_screen/widgets/old_user_login_widget.dart';
import 'package:cronicalia_flutter/login_screen/widgets/user_email_collector_widget.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cronicalia_flutter/login_screen/widgets/new_user_login_widget.dart';

class LoginScreen extends StatefulWidget {

  final FirebaseAuth firebaseAuth;

  LoginScreen(this.firebaseAuth);

  @override
  State createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  String _email;
  Future<List<String>> _providers = new Future.value(<String>[]);

  @override
  Widget build(BuildContext context) {
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
      onEmailReady: (String email) {
        setState(() {
          _email = email;
          _providers = resolveProviders(email);
        });
      },
    );
  }

  Future<List<String>> resolveProviders(String email) async {
    if (email != null) {
      List<String> providers = await widget.firebaseAuth.fetchProvidersForEmail(email: email);
      return providers;
    }
    return null;
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
      return NewUserLoginWidget(email: _email);
    } else {
      bool shouldShowGoogle = providers.contains(Constants.PROVIDER_OPTIONS[ProviderOptions.GOOGLE]);
      bool shouldShowFacebook = providers.contains(Constants.PROVIDER_OPTIONS[ProviderOptions.FACEBOOK]);
      bool shouldShowTwitter = providers.contains(Constants.PROVIDER_OPTIONS[ProviderOptions.TWITTER]);
      bool shouldShowEmailAndPassword = providers.contains(Constants.PROVIDER_OPTIONS[ProviderOptions.PASSWORD]);

      return OldUserLoginWidget(
          email: _email,
          shouldShowGoogle: shouldShowGoogle,
          shouldShowFacebook: shouldShowFacebook,
          shouldShowTwitter: shouldShowTwitter,
          shouldShowEmailAndPassword: shouldShowEmailAndPassword);
    }
  }

}
