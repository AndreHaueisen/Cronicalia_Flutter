import 'package:cronicalia_flutter/main.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class FlushbarHelper {
  /// Get a success notification flushbar.
  static Flushbar createSuccess({@required String message, String title, Duration duration = const Duration(seconds: 3)}) {
    return Flushbar()
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..titleText = title != null
          ? Text(
              title,
              style: TextStyle(color: TextColorBrightBackground.primary),
            )
          : null
      ..backgroundColor = Colors.grey[100]
      ..shadowColor = Colors.grey[900]
      ..icon = Icon(
        Icons.check_circle,
        color: Colors.green[400],
      )
      ..duration = duration
      ..leftBarIndicatorColor = Colors.green[400];
  }

  /// Get an information notification flushbar
  static Flushbar createInformation(
      {@required String message, String title, Duration duration = const Duration(seconds: 3)}) {
    return Flushbar()
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..titleText = title != null
          ? Text(
              title,
              style: TextStyle(color: TextColorBrightBackground.primary),
            )
          : null
      ..backgroundColor = Colors.grey[100]
      ..shadowColor = Colors.grey[900]
      ..icon = Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[400],
      )
      ..duration = duration
      ..leftBarIndicatorColor = Colors.blue[400];
  }

  /// Get a error notification flushbar
  static Flushbar createError({@required String message, String title, Duration duration = const Duration(seconds: 3)}) {
    return Flushbar()
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..titleText = title != null
          ? Text(
              title,
              style: TextStyle(color: TextColorBrightBackground.primary),
            )
          : null
      ..backgroundColor = Colors.grey[100]
      ..shadowColor = Colors.grey[900]
      ..icon = Icon(
        Icons.warning,
        size: 28.0,
        color: Colors.red[400],
      )
      ..duration = duration
      ..leftBarIndicatorColor = Colors.red[400];
  }

  /// Get a flushbar that can receive a user action through a button.
  static Flushbar createAction(
      {@required String message,
      @required FlatButton button,
      String title,
      Duration duration = const Duration(seconds: 3)}) {
    return Flushbar()
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..titleText = title != null
          ? Text(
              title,
              style: TextStyle(color: TextColorBrightBackground.primary),
            )
          : null
      ..backgroundColor = Colors.grey[100]
      ..shadowColor = Colors.grey[900]
      ..duration = duration
      ..mainButton = button
      ..leftBarIndicatorColor = button.textColor;
  }

  /// Get a flushbar that shows the progress of a async computation.
  static Flushbar createLoading(
      {@required String message,
      String title,
      AnimationController indicatorController,
      Color indicatorBackgroundColor,
      Duration duration}) {
    return Flushbar()
      ..messageText = Text(
        message,
        style: TextStyle(color: TextColorBrightBackground.secondary),
      )
      ..titleText = title != null
          ? Text(
              title,
              style: TextStyle(color: TextColorBrightBackground.primary),
            )
          : null
      ..backgroundColor = Colors.grey[100]
      ..shadowColor = Colors.grey[900]
      ..icon = Icon(
        Icons.cloud_upload,
        color: Colors.blue[400],
      )
      ..duration = duration
      ..showProgressIndicator = true
      ..progressIndicatorController = indicatorController
      ..progressIndicatorBackgroundColor = indicatorBackgroundColor;
  }

  static Flushbar createInput({@required Form textForm}) {
    return Flushbar()
      ..backgroundColor = Colors.grey[100]
      ..duration = null
      ..userInputForm = textForm;
  }
}
