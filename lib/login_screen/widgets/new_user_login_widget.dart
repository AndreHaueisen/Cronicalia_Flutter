import 'dart:async';

import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';

class NewUserLoginWidget extends StatefulWidget {
  NewUserLoginWidget({@required this.email});

  final String email;

  @override
  State createState() {
    return new NewUserLoginWidgetState();
  }
}

class NewUserLoginWidgetState extends State<NewUserLoginWidget> with StoreWatcherMixin<NewUserLoginWidget> {
  bool _shouldObscureText = true;
  final GlobalKey<FormState> _newUserPasswordFormKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _getGoogleButton(),
        _getFacebookButton(),
        _getTwitterButton(),
        new Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 48.0, right: 48.0, bottom: 8.0),
          child: MaterialButton(
            onPressed: () {
              FlushbarHelper.createInput(
                  textForm: new Form(
                key: _newUserPasswordFormKey,
                child: new TextFormField(
                  obscureText: _shouldObscureText,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (String password) {
                    if (_newUserPasswordFormKey.currentState.validate()) {
                      //completer signal sent by loginWithEmailAction
                      Completer<bool> loggedStatusCompleter = Completer<bool>();
                      loginWithEmailAction([widget.email, password, true, context, loggedStatusCompleter]);
                      loggedStatusCompleter.future.then((bool isLogInSuccessful) {
                        if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
                      });
                    }
                  },
                  maxLength: 20,
                  maxLengthEnforced: true,
                  validator: (value) => Utility.validatePassword(value),
                  style: TextStyle(color: TextColorDarkBackground.primary),
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
                      fillColor: Colors.black26,
                      filled: true,
                      border: UnderlineInputBorder(),
                      labelText: "Your password",
                      labelStyle: TextStyle(color: TextColorDarkBackground.tertiary)),
                ),
              )).show(context);
            },
            child: Text("LOGIN WITH EMAIL"),
            textColor: Colors.white,
            color: Colors.green[800],
          ),
        ),
      ],
    );
  }

  Widget _getGoogleButton() {
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 48.0, right: 48.0, bottom: 8.0),
      child: MaterialButton(
        onPressed: () {
          //completer signal sent by loginWithGoogleAction
          final Completer<bool> loggedStatusCompleter = Completer<bool>();
          loginWithGoogleAction([true, context, loggedStatusCompleter]);
          loggedStatusCompleter.future.then((bool isLogInSuccessful) {
            if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
          });
        },
        child: Text("LOGIN WITH GOOGLE"),
        textColor: Colors.white,
        color: Colors.red[600],
      ),
    );
  }

  Widget _getFacebookButton() {
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 48.0, right: 48.0, bottom: 8.0),
      child: MaterialButton(
        onPressed: () {
          //completer signal sent by loginWithFacebookAction
          final Completer<bool> loggedStatusCompleter = Completer<bool>();
          loginWithFacebookAction([true, context, loggedStatusCompleter]);
          loggedStatusCompleter.future.then((bool isLogInSuccessful) {
            if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
          });
        },
        child: Text("LOGIN WITH FACEBOOK"),
        textColor: Colors.white,
        color: Colors.blue[800],
      ),
    );
  }

  Widget _getTwitterButton() {
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 48.0, right: 48.0, bottom: 8.0),
      child: MaterialButton(
        onPressed: () {
          //completer signal sent by loginWithTwitterAction
          final Completer<bool> loggedStatusCompleter = Completer<bool>();
          loginWithTwitterAction([true, context, loggedStatusCompleter]);
          loggedStatusCompleter.future.then((bool isLogInSuccessful) {
            if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
          });
        },
        child: Text("LOGIN WITH TWITTER"),
        textColor: Colors.white,
        color: Colors.blue[400],
      ),
    );
  }

  void _showSuccessFlushbarToPopRoute() {
    FlushbarHelper.createSuccess(
      message: "Thanks for joining us!",
    )
      ..onStatusChanged = (FlushbarStatus status) {
        if (status == FlushbarStatus.DISMISSED) {
          Navigator.of(context).pop();
        }
      }
      ..show(context);
  }
}
