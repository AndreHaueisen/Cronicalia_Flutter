import 'dart:async';

import 'package:cronicalia_flutter/login_screen/login_button.dart';
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
  final GlobalKey<FormState> _newUserFormKey = new GlobalKey<FormState>();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  Flushbar _inputFlushbar;

  @override
  void initState() {
    _inputFlushbar = FlushbarHelper.createInput(
        textForm: new Form(
      key: _newUserFormKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: _buildTextFormField(
              isTextObscured: false,
              maxLength: 30,
              inputAction: TextInputAction.next,
              capitalization: TextCapitalization.words,
              label: "Name",
              inputTypeForValidator: _TextInputType.NAME,
              controller: _nameTextController),
        ),
        _buildTextFormField(
            isTextObscured: false,
            maxLength: 20,
            inputAction: TextInputAction.done,
            capitalization: TextCapitalization.none,
            label: "Password",
            inputTypeForValidator: _TextInputType.PASSWORD,
            controller: _passwordTextController),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            child: _buildSubmitButton(),
            alignment: Alignment.bottomRight,
          ),
        ),
      ]),
    ))
      ..backgroundColor = Colors.grey[100];

    super.initState();
  }

  Widget _buildTextFormField(
      {@required bool isTextObscured,
      @required int maxLength,
      @required String label,
      @required TextCapitalization capitalization,
      @required TextInputAction inputAction,
      @required TextEditingController controller,
      _TextInputType inputTypeForValidator,
      Widget suffixIcon}) {
    return TextFormField(
      obscureText: isTextObscured,
      keyboardType: TextInputType.text,
      maxLength: maxLength,
      maxLengthEnforced: true,
      textCapitalization: capitalization,
      textInputAction: inputAction,
      controller: controller,
      validator: (value) =>
          inputTypeForValidator == _TextInputType.NAME ? Utility.validateName(value) : Utility.validatePassword(value),
      style: TextStyle(color: TextColorBrightBackground.primary),
      maxLines: 1,
      decoration: InputDecoration(
          suffixIcon: suffixIcon,
          fillColor: Colors.black26,
          filled: true,
          border: UnderlineInputBorder(),
          labelText: label,
          counterStyle: TextStyle(color: TextColorBrightBackground.tertiary),
          labelStyle: TextStyle(color: TextColorBrightBackground.secondary)),
    );
  }

  Widget _buildSubmitButton() {
    return FlatButton(
      child: Text("SUBMIT"),
      textColor: TextColorDarkBackground.primary,
      color: AppThemeColors.primaryColor,
      onPressed: () {
        if (_newUserFormKey.currentState.validate()) {
          //completer signal sent by loginWithEmailAction
          Completer<bool> loggedStatusCompleter = Completer<bool>();

          String name = _nameTextController.value.text;
          String password = _passwordTextController.value.text;

          _inputFlushbar.dismiss();

          loginWithEmailAction([widget.email, name, password, true, context, loggedStatusCompleter]);
          loggedStatusCompleter.future.then((bool isLogInSuccessful) {
            if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
          });
        }
      },
    );
  }

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
        _getEmailButton(),
      ],
    );
  }

  Widget _getGoogleButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, right: 48.0, bottom: 8.0),
      child: LoginButton.getGoogleButton(onPressed: () {
        //completer signal sent by loginWithGoogleAction
        final Completer<bool> loggedStatusCompleter = Completer<bool>();
        loginWithGoogleAction([true, context, loggedStatusCompleter]);
        loggedStatusCompleter.future.then((bool isLogInSuccessful) {
          if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
        });
      }),
    );
  }

  Widget _getFacebookButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, right: 48.0, bottom: 8.0),
      child: LoginButton.getFacebookButton(onPressed: () {
        //completer signal sent by loginWithFacebookAction
        final Completer<bool> loggedStatusCompleter = Completer<bool>();
        loginWithFacebookAction([true, context, loggedStatusCompleter]);
        loggedStatusCompleter.future.then((bool isLogInSuccessful) {
          if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
        });
      }),
    );
  }

  Widget _getTwitterButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, right: 48.0, bottom: 8.0),
      child: LoginButton.getTwitterButton(onPressed: () {
        //completer signal sent by loginWithTwitterAction
        final Completer<bool> loggedStatusCompleter = Completer<bool>();
        loginWithTwitterAction([true, context, loggedStatusCompleter]);
        loggedStatusCompleter.future.then((bool isLogInSuccessful) {
          if (isLogInSuccessful) _showSuccessFlushbarToPopRoute();
        });
      }),
    );
  }

  Widget _getEmailButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, right: 48.0),
      child: LoginButton.getEmailButton(onPressed: () {
        _inputFlushbar.show(context);
      }),
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

enum _TextInputType { NAME, PASSWORD }
