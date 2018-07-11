import 'package:flutter/material.dart';

class BookmarksScreen extends StatelessWidget {
  BookmarksScreen();

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Center(
        child: new FloatingActionButton(
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(Icons.timer),
          onPressed: () {},
        ),
      ),
    );
  }
}
