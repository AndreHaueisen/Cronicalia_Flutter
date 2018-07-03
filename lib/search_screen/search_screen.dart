import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

class SearchScreen extends StatelessWidget{

  SearchScreen(this.flushbar);

  final Flushbar flushbar;

  @override
  Widget build(BuildContext context) {
    return new Stack(children: [
      new Text("Search Screen"),
      flushbar
    ]);

  }
}