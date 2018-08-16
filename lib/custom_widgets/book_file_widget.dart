import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/my_books_screen/create_my_book_screen.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

class BookFileWidget extends StatelessWidget {
  BookFileWidget({Key key, this.isLaunchedComplete, this.filePath, this.index})
      : formattedFilePath = filePath.split("/").last,
        super(key: key);

  final bool isLaunchedComplete;
  final String filePath;
  final String formattedFilePath;
  final int index;
  String _chapterTitle;

  String get chapterTitle => _chapterTitle;

  Widget _bookCompleteFileRepresentation() {
    return SizedBox(
      height: FILE_WIDGET_HEIGHT,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Book Files",
              style: TextStyle(color: TextColorBrightBackground.primary, fontSize: 24.0),
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Icon(
                    Icons.attach_file,
                    color: TextColorBrightBackground.secondary,
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: Container(
                  constraints: BoxConstraints.expand(height: 48.0),
                  padding: EdgeInsets.all(8.0),
                  color: Colors.black12,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(formattedFilePath,
                        textAlign: TextAlign.right, style: TextStyle(color: TextColorBrightBackground.primary)),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _bookIncompleteFileRepresentation() {
    return SizedBox(
      height: FILE_WIDGET_HEIGHT,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Colors.grey[200],
              constraints: BoxConstraints.expand(height: 1.0),
            ),
            Row(
              children: <Widget>[
                Flexible(
                    flex: 1,
                    child: IconButton(
                        icon: Icon(
                          Icons.reorder,
                          color: TextColorBrightBackground.secondary,
                        ),
                        onPressed: () {})),
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 16.0),
                        child: Text(
                          formattedFilePath,
                          style: TextStyle(color: TextColorBrightBackground.tertiary, fontSize: 12.0),
                        ),
                      ),
                      TextField(
                        maxLengthEnforced: true,
                        maxLength: Constants.MAX_TITLE_LENGTH,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onChanged: (String title) {
                          _chapterTitle = title.trim();
                        },
                        style: TextStyle(color: TextColorBrightBackground.primary),
                        maxLines: 1,
                        decoration: InputDecoration(
                            fillColor: Colors.black12,
                            filled: true,
                            border: UnderlineInputBorder(),
                            labelText: "Chapter title",
                            labelStyle: TextStyle(color: TextColorBrightBackground.secondary),
                            counterStyle: TextStyle(color: TextColorBrightBackground.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLaunchedComplete ? _bookCompleteFileRepresentation() : _bookIncompleteFileRepresentation();
  }
}
