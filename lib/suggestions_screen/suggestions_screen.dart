import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

class SuggestionsScreen extends StatelessWidget{

  SuggestionsScreen(this.flushbar);

  final Flushbar flushbar;

  @override
  Widget build(BuildContext context) {
    return new Stack(children: [
      new Text("Suggestions Screen"),
      flushbar
    ]);

  }
}