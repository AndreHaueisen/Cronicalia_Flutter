import 'package:cronicalia_flutter/main.dart';
import 'package:flutter/material.dart';

class BookStatsWidget extends StatelessWidget {
  BookStatsWidget({this.readingsNumber, this.rating, this.income});

  final int readingsNumber;
  final double rating;
  final double income;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Icon(
                Icons.remove_red_eye,
                color: TextColorDarkBackground.tertiary,
              ),
            ),
            Text(readingsNumber.toString(),
                style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold))
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 6.0),
              child: Icon(Icons.star, color: TextColorDarkBackground.tertiary),
            ),
            Text(rating.toString(),
                style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold))
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.attach_money, color: TextColorDarkBackground.tertiary),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(income.toString(),
                  style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold)),
            )
          ],
        )
      ],
    );
  }
}
