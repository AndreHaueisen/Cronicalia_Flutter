import 'package:cronicalia_flutter/login_screen/login_handler.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:flutter/material.dart';

class OldUserLoginWidget extends StatefulWidget {
  OldUserLoginWidget(
      {@required this.loginHandler,
      @required this.email,
      @required this.shouldShowGoogle,
      @required this.shouldShowFacebook,
      @required this.shouldShowTwitter,
      this.shouldShowEmailAndPassword});

  final bool shouldShowGoogle;
  final bool shouldShowFacebook;
  final bool shouldShowTwitter;
  final bool shouldShowEmailAndPassword;
  final LoginHandler loginHandler;
  final String email;

  @override
  State createState() {
    return OldUserLoginWidgetState();
  }
}

class OldUserLoginWidgetState extends State<OldUserLoginWidget> {
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
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(widget.email),
              ),
              new Form(
                key: _oldUserPasswordFormKey,
                child: new TextFormField(
                  obscureText: _shouldObscureText,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (String password) {
                    if (_oldUserPasswordFormKey.currentState.validate()) {
                      widget.loginHandler.signIntoFirebaseWithEmailAndPassword(widget.email, password);
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
                child: new FlatButton(onPressed: (){
                    widget.loginHandler.requestForgotPasswordEmail(widget.email);
                }, child: Text("Forgot password?")),
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
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 48.0, right: 48.0, bottom: 8.0),
      child: MaterialButton(
        onPressed: () {
          widget.loginHandler.signIntoFirebaseWithGoogle(false);
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
          widget.loginHandler.signIntoFirebaseWithFacebook(false);
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
          widget.loginHandler.signIntoFirebaseWithTwitter(false);
        },
        child: Text("LOGIN WITH TWITTER"),
        textColor: Colors.white,
        color: Colors.blue[400],
      ),
    );
  }
}
