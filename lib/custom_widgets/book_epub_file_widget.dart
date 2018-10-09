import 'package:flutter/material.dart';
import 'package:cronicalia_flutter/main.dart';

class BookEpubFileWidget extends StatelessWidget {
  BookEpubFileWidget({this.chapterTitle, this.chapterNumber, this.isOld = true});

  final String chapterTitle;
  final int chapterNumber;
  final bool isOld;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isOld
            ? Container(
                height: 0.0,
                width: 0.0,
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: Colors.green,
                ),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("NEW"),
                  ),
                ),
              ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Section ${chapterNumber + 1}",
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[400],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  chapterTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: TextColorBrightBackground.secondary, fontSize: 18.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
