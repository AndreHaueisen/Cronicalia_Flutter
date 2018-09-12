import 'dart:async';

import 'package:cronicalia_flutter/login_screen/login_button.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';

class OldUserLoginWidget extends StatefulWidget {
  OldUserLoginWidget(
      {@required this.email,
      @required this.shouldShowGoogle,
      @required this.shouldShowFacebook,
      @required this.shouldShowTwitter,
      this.shouldShowEmailAndPassword});

  final bool shouldShowGoogle;
  final bool shouldShowFacebook;
  final bool shouldShowTwitter;
  final bool shouldShowEmailAndPassword;

  final String email;

  @override
  State createState() {
    return OldUserLoginWidgetState();
  }
}

class OldUserLoginWidgetState extends State<OldUserLoginWidget> with StoreWatcherMixin<OldUserLoginWidget> {
  bool _shouldObscureText = true;
  final GlobalKey<FormState> _oldUserPasswordFormKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (widget.shouldShowGoogle) {
      return _getGoogleButton();
    }

    if (widget.shouldShowFacebook) {
      return _getFacebookButton();
    }

    if (widget.shouldShowTwitter) {
      return _getTwitterButton();
    }

    if (widget.shouldShowEmailAndPassword) {
      return new Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(widget.email),
            ),
            new Form(
              key: _oldUserPasswordFormKey,
              child: new TextFormField(
                obscureText: _shouldObscureText,
                keyboardType: TextInputType.text,
                onFieldSubmitted: (String password) {
                  if (_oldUserPasswordFormKey.currentState.validate()) {
                    //completer signal sent by loginWithEmailAction
                    Completer<bool> loggedStatusCompleter = Completer<bool>();
                    loginWithEmailAction([widget.email, null, password, false, context, loggedStatusCompleter]);
                    loggedStatusCompleter.future.then((bool isLogInSuccessful) {
                      if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
                    });
                  }
                },
                validator: (value) => Utility.validatePassword(value),
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                decoration: InputDecoration(
                    suffixIcon: new GestureDetector(
                      onTap: () {
                        setState(() {
                          _shouldObscureText = !_shouldObscureText;
                        });
                      },
                      child: new Icon(_shouldObscureText ? Icons.visibility : Icons.visibility_off),
                    ),
                    fillColor: Colors.white10,
                    filled: true,
                    border: UnderlineInputBorder(),
                    labelText: "Your password",
                    labelStyle: TextStyle(color: Colors.grey[300])),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new FlatButton(
                  onPressed: () {
                    requestNewPasswordAction([widget.email, context]);
                  },
                  child: Text("Forgot password?")),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  Widget _getGoogleButton() {
    return LoginButton.getGoogleButton(onPressed: () {
      //completer signal sent by loginWithGoogleAction
      Completer<bool> loggedStatusCompleter = Completer<bool>();
      loginWithGoogleAction([false, context, loggedStatusCompleter]);
      loggedStatusCompleter.future.then((bool isLogInSuccessful) {
        if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
      });
    });
  }

  Widget _getFacebookButton() {
    return LoginButton.getFacebookButton(onPressed: () {
      //completer signal sent by loginWithFacebookAction
      Completer<bool> loggedStatusCompleter = Completer<bool>();
      loginWithFacebookAction([false, context, loggedStatusCompleter]);
      loggedStatusCompleter.future.then((bool isLogInSuccessful) {
        if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
      });
    });
  }

  Widget _getTwitterButton() {
    return LoginButton.getTwitterButton(onPressed: () {
      //completer signal sent by loginWithTwitterAction
      Completer<bool> loggedStatusCompleter = Completer<bool>();
      loginWithTwitterAction([false, context, loggedStatusCompleter]);
      loggedStatusCompleter.future.then((bool isLogInSuccessful) {
        if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
      });
    });
  }

  void _showSuccessFlushbarToPopRoute() {
    FlushbarHelper.createSuccess(
      message: "Welcome back!",
    )
      ..onStatusChanged = (FlushbarStatus status) {
        if (status == FlushbarStatus.DISMISSED) {
          Navigator.of(context).pop();
        }
      }
      ..show(context);
  }
}
