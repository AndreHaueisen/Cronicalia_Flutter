import 'package:cronicalia_flutter/login_screen/login_handler.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:flutter/material.dart';

typedef EmailCallback(String email);

class UserEmailCollectorWidget extends StatefulWidget {
  UserEmailCollectorWidget({@required this.onEmailReady});

  EmailCallback onEmailReady;

  @override
  State createState() {
    return new UserEmailCollectorWidgetState();
  }
}

class UserEmailCollectorWidgetState extends State<UserEmailCollectorWidget> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Image(
              image: AssetImage(
                "images/icon_stub.png",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 48.0),
            child: Form(
              key: _emailFormKey,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (String email) {
                  if (_emailFormKey.currentState.validate()) {
                    widget.onEmailReady(email);
                  }
                },
                
                validator: (value) => Utility.isEmailValid(value) ? null : 'Not a valid email.',
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                decoration: InputDecoration(
                    fillColor: Colors.white10,
                    filled: true,
                    suffixIcon: Icon(
                      Icons.email,
                    ),
                    border: UnderlineInputBorder(),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.grey[300])),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
