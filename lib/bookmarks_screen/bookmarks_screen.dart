import 'package:cronicalia_flutter/custom_widgets/persistent_bottom_bar.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:flutter/material.dart';

class BookmarksScreen extends StatelessWidget {
  BookmarksScreen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(children: [
        Expanded(
          child: new Center(
            child: new FloatingActionButton(
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(Icons.timer),
              onPressed: () {},
            ),
          ),
        ),
        PersistentBottomBar(
          selectedItemIdex: 2,
        )
      ]),
    );
  }
}
