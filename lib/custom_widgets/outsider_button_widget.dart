import 'dart:math';

import 'package:cronicalia_flutter/main.dart';
import 'package:flutter/material.dart';

enum OutsiderButtonPosition { TOP, BOTTOM }

class OutsiderButton extends StatelessWidget {

  final Function onPressed;
  final Icon icon;
  final OutsiderButtonPosition position;

  OutsiderButton({this.onPressed, @required this.icon, this.position});

  @override
  Widget build(BuildContext context) {
    return new Stack(fit: StackFit.loose, alignment: Alignment.center, children: [
      new CustomPaint(
        painter: new _OutsiderShapePainter(position: position),
        size: const Size(60.0, 60.0),
        isComplex: false,
      ),
      OutlineButton(
        borderSide: BorderSide(width: 1.0, color: Colors.white),
        color: AppThemeColors.accentColor,
        shape: new CircleBorder(),
        child: new Padding(
          padding: const EdgeInsets.all(6.0),
          child: icon,
        ),
        onPressed: onPressed,
      )
    ]);
  }
}

class _OutsiderShapePainter extends CustomPainter {
  final Paint bookMarkPaint;
  final double hexagonOffset = 15.0;
  final OutsiderButtonPosition position;
  Path path = Path();

  _OutsiderShapePainter({this.position = OutsiderButtonPosition.TOP}) : bookMarkPaint = new Paint() {
    bookMarkPaint.color = AppThemeColors.primaryColorLight;
    bookMarkPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {

    canvas.save();

    if (position == OutsiderButtonPosition.BOTTOM) {
      canvas.rotate(pi);
      canvas.translate(-size.width, -size.height);
    }

    path.moveTo(0.0, hexagonOffset);
    path.relativeLineTo(size.width / 3, -hexagonOffset);
    path.relativeLineTo(size.width / 3, 0.0);
    path.relativeLineTo(size.width / 3, hexagonOffset);
    path.relativeLineTo(0.0, size.height - hexagonOffset);
    path.relativeLineTo(-size.width, 0.0);
    path.close();

    //canvas.drawShadow(path, Colors.grey[900], 2.0, false);
    canvas.drawPath(path, bookMarkPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
