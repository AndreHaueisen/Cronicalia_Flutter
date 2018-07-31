import 'package:cronicalia_flutter/main.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class FlushbarHelper {
  /// Get a success notification flushbar.
  static Flushbar createSuccess({@required String title, @required String message, Duration duration = const Duration(seconds: 3)}) {
    return Flushbar()
      ..titleText = Text(
        title,
        style: TextStyle(color: TextColorBrightBackground.primary),
      )
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..backgroundColor = Colors.grey[200]
      ..shadowColor = Colors.grey[300]
      ..icon = Icon(
        Icons.check_circle,
        color: Colors.green[300],
      )
      ..duration = duration
      ..mainButton = null
      ..userInputForm = null
      ..linearProgressIndicator = null;
  }

  /// Get an information notification flushbar
  static Flushbar createInformation({@required String title, @required String message, Duration duration = const Duration(seconds: 3)}) {
    return Flushbar()
      ..titleText = Text(
        title,
        style: TextStyle(color: TextColorBrightBackground.primary),
      )
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..backgroundColor = Colors.grey[200]
      ..shadowColor = Colors.grey[300]
      ..icon = Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      )
      ..duration = duration
      ..mainButton = null
      ..userInputForm = null
      ..linearProgressIndicator = null;
  }

  /// Get a error notification flushbar
  static Flushbar createError({@required String title, @required String message, Duration duration = const Duration(seconds: 3)}) {
    return Flushbar()
      ..titleText = Text(
        title,
        style: TextStyle(color: TextColorBrightBackground.primary),
      )
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..backgroundColor = Colors.grey[200]
      ..shadowColor = Colors.grey[300]
      ..icon = Icon(
        Icons.warning,
        size: 28.0,
        color: Colors.red[300],
      )
      ..duration = duration
      ..mainButton = null
      ..userInputForm = null
      ..linearProgressIndicator = null;
  }

  /// Get a flushbar that can receive a user action through a button.
  static Flushbar createAction(
      {@required String title, @required String message, @required FlatButton button, Duration duration = const Duration(seconds: 3)}) {
    return Flushbar()
      ..titleText = Text(
        title,
        style: TextStyle(color: TextColorBrightBackground.primary),
      )
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..backgroundColor = Colors.grey[200]
      ..shadowColor = Colors.grey[300]
      ..icon = null
      ..duration = duration
      ..mainButton = button
      ..userInputForm = null
      ..linearProgressIndicator = null;
  }

  /// Get a flushbar that shows the progress of a async computation.
  static Flushbar createLoading(
      {@required String title, @required String message, @required LinearProgressIndicator linearProgressIndicator, Duration duration}) {
    return Flushbar()
      ..titleText = Text(
        title,
        style: TextStyle(color: TextColorBrightBackground.primary),
      )
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..backgroundColor = Colors.grey[200]
      ..shadowColor = Colors.grey[300]
      ..icon = Icon(
        Icons.cloud_upload,
        color: Colors.blue[300],
      )
      ..duration = duration
      ..mainButton = null
      ..userInputForm = null
      ..linearProgressIndicator = linearProgressIndicator;
  }

  static Flushbar createInput({@required Form textForm}) {
    return Flushbar()
      ..backgroundColor = Colors.grey[200]
      ..duration = null
      ..userInputForm = textForm;
  }
}
