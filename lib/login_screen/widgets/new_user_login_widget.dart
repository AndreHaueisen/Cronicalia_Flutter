import 'package:cronicalia_flutter/login_screen/login_handler.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/utils/flushbar_helper.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class NewUserLoginWidget extends StatefulWidget {
  NewUserLoginWidget({@required this.loginHandler, @required this.email, @required this.flushbar});

  final LoginHandler loginHandler;
  final Flushbar flushbar;
  final String email;

  @override
  State createState() {
    return new NewUserLoginWidgetState();
  }
}

class NewUserLoginWidgetState extends State<NewUserLoginWidget> {
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
              FlushbarHelper
                  .morphIntoInput(widget.flushbar,
                      textForm: new Form(
                        key: _newUserPasswordFormKey,
                        child: new TextFormField(
                          obscureText: _shouldObscureText,
                          keyboardType: TextInputType.text,
                          onFieldSubmitted: (String password) {
                            if (_newUserPasswordFormKey.currentState.validate()) {
                              widget.loginHandler.createUserOnFirebaseWithEmailAndPassword(widget.email, password);
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
                      ))
                  .commitChanges();
              widget.flushbar.show();
              //widget._loginHandler.signIntoFirebaseWithEmailAndPassword("andrehaueisen@gmail.com", "haueisen10");
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
          widget.loginHandler.signIntoFirebaseWithGoogle();
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
          widget.loginHandler.signIntoFirebaseWithFacebook();
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
          widget.loginHandler.signIntoFirebaseWithTwitter();
        },
        child: Text("LOGIN WITH TWITTER"),
        textColor: Colors.white,
        color: Colors.blue[400],
      ),
    );
  }
}
