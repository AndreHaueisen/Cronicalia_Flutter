import 'package:flutter/material.dart';

class LoginButton {
  
  static Widget getGoogleButton({@required Function onPressed}) {
    return RaisedButton(
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      onPressed: onPressed,
      child: Text("LOGIN WITH GOOGLE"),
      textColor: Colors.white,
      color: Color(0xBBE53935), // Colors.red[600],
      highlightColor: Color(0xBBEF5350), //Colors.red[400],
    );
  }

  static Widget getFacebookButton({@required Function onPressed}) {
    return RaisedButton(
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      onPressed: onPressed,
      child: Text("LOGIN WITH FACEBOOK"),
      textColor: Colors.white,
      color: Color(0xBB1565C0), //Colors.blue[800],
      highlightColor: Color(0xBB1E88E5), //Colors.blue[600]
    );
  }

  static Widget getTwitterButton({@required Function onPressed}) {
    return RaisedButton(
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      onPressed: onPressed,
      child: Text("LOGIN WITH TWITTER"),
      textColor: Colors.white,
      color: Color(0xBB42A5F5), //Colors.blue[400]
      highlightColor: Color(0xBB64B5F6), //Colors.blue[300]
    );
  }

  static Widget getEmailButton({@required Function onPressed}) {
    return RaisedButton(
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      onPressed: onPressed,
      child: Text("LOGIN WITH EMAIL"),
      textColor: Colors.white,
      color: Color(0xBB2E7D32), //Colors.green[800],
      highlightColor: Color(0xBB43A047), //Colors.green[600]
    );
  }
}
