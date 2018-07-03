import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';


class FlushbarHelper {
  /// Morph flushbar into a success notification.
  static Flushbar morphIntoSuccess(Flushbar flushbar,
      {@required String title, @required String message, Duration duration = const Duration(seconds: 3)}) {
    return flushbar
      ..title = title
      ..message = message
      ..icon = Icon(
        Icons.check_circle,
        color: Colors.green[200],
      )
      ..duration = duration
      ..mainButton = null
      ..userInputForm = null
      ..linearProgressIndicator = null;
  }

  /// Morph flushbar into a information notification.
  static Flushbar morphIntoInfo(Flushbar flushbar,
      {@required String title, @required String message, Duration duration = const Duration(seconds: 3)}) {
    return flushbar
      ..title = title
      ..message = message
      ..icon = Icon(
        Icons.info_outline,
        color: Colors.blue[200],
      )
      ..duration = duration
      ..mainButton = null
      ..userInputForm = null
      ..linearProgressIndicator = null;
  }

  /// Morph flushbar into a error notification.
  static Flushbar morphIntoError(Flushbar flushbar,
      {@required String title, @required String message, Duration duration = const Duration(seconds: 3)}) {
    return flushbar
      ..title = title
      ..message = message
      ..icon = Icon(
        Icons.warning,
        color: Colors.red[200],
      )
      ..duration = duration
      ..mainButton = null
      ..userInputForm = null
      ..linearProgressIndicator = null;
  }

  /// Morph flushbar into a notification that can receive a user action through a button.
  static Flushbar morphIntoAction(Flushbar flushbar,
      {@required String title,
        @required String message,
        @required FlatButton button,
        Duration duration = const Duration(seconds: 3)}) {
    return flushbar
      ..title = title
      ..message = message
      ..icon = null
      ..duration = duration
      ..mainButton = button
      ..userInputForm = null
      ..linearProgressIndicator = null;
  }

  /// Morph flushbar into a notification that shows the progress of a async computation.
  static Flushbar morphIntoLoading(Flushbar flushbar,
      {@required String title,
        @required String message,
        @required LinearProgressIndicator linearProgressIndicator,
        Duration duration = const Duration(seconds: 3)}) {
    return flushbar
      ..title = title
      ..message = message
      ..icon = Icon(
        Icons.cloud_upload,
        color: Colors.blue[200],
      )
      ..duration = duration
      ..mainButton = null
      ..userInputForm = null
      ..linearProgressIndicator = linearProgressIndicator;

  }

  static Flushbar morphIntoInput(Flushbar flushbar, {@required Form textForm}){
    return flushbar
      ..duration = null
      ..userInputForm = textForm;

  }
}
