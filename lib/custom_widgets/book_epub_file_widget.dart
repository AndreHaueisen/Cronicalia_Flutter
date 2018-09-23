import 'package:flutter/material.dart';
import 'package:cronicalia_flutter/main.dart';

class BookEpubFileWidget extends StatelessWidget {
  BookEpubFileWidget(this._chapterTitle, this._chapterNumber);

  final String _chapterTitle;
  final int _chapterNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Section ${_chapterNumber + 1}",
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
                  _chapterTitle,
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
