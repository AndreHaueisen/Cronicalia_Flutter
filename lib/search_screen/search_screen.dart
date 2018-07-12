import 'package:cronicalia_flutter/custom_widgets/persistent_bottom_bar.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Column(
        children: [
          Expanded(child: new Text("Search Screen")),
          PersistentBottomBar(
            selectedItemIdex: 1,
          )
        ],
      ),
    );
  }
}
