import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({this.child, this.textColor, this.color, this.highlightColor, this.elevation = 0.0, this.onPressed});

  Widget child;

  Color textColor;
  Color color;
  Color highlightColor;
  Function onPressed;
  double elevation = 0.0;

  final double _borderRadius = 16.0;
  

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
      onPressed: onPressed,
      child: child,
      textColor: textColor,
      color: color, //Colors.blue[800],
      highlightColor: highlightColor, //Colors.blue[600]
    );
  }

}
