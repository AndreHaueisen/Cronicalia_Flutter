import 'package:cronicalia_flutter/login_screen/login_handler.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:flutter/material.dart';

typedef EmailCallback(String email);

class UserEmailCollectorWidget extends StatefulWidget {
  UserEmailCollectorWidget({@required this.loginHandler, @required this.onEmailReady});

  final LoginHandler loginHandler;
  EmailCallback onEmailReady;

  @override
  State createState() {
    return new UserEmailCollectorWidgetState();
  }
}

class UserEmailCollectorWidgetState extends State<UserEmailCollectorWidget> {
  final GlobalKey<FormState> _emailFormKey = new GlobalKey<FormState>();
  double _progressIndicatorOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Form(
              key: _emailFormKey,
              child: new TextFormField(
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (String email) {
                  if (_emailFormKey.currentState.validate()) {
                    widget.onEmailReady(email);
                    _progressIndicatorOpacity = 1.0;
                  }
                },
                validator: (value) => Utility.isEmailValid(value) ? null : 'Not a valid email.',
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                decoration: InputDecoration(
                    fillColor: Colors.white10,
                    filled: true,
                    icon: Icon(
                      Icons.email,
                      color: Colors.grey[500],
                    ),
                    border: UnderlineInputBorder(),
                    labelText: "Your email",
                    labelStyle: TextStyle(color: Colors.grey)),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: new Opacity(opacity: _progressIndicatorOpacity, child: CircularProgressIndicator()),
            )
          ],
        ),
      ),
    );
  }
}

