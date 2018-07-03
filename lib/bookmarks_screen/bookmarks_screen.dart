import 'package:cronicalia_flutter/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

class BookmarksScreen extends StatelessWidget {
  BookmarksScreen(this.flushbar);

  final Flushbar flushbar;

  @override
  Widget build(BuildContext context) {
    return new Stack(children: [
      new Container(
        child: new Center(
          child: new FloatingActionButton(
            backgroundColor: Theme.of(context).accentColor,
            child: Icon(Icons.timer),
            onPressed: () {
              if(flushbar.isShowing()){
                flushbar.dismiss();
              } else {
                FlushbarHelper
                    .morphIntoInfo(flushbar,
                    title: "No connection",
                    message: "Your app is diconnected. Action not saved")
                    .commitChanges();
                flushbar.show();
              }
            },
          ),
        ),
      ),
      flushbar
    ]);
  }
}
