import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

abstract class UserInputCallback {
  void onInputReady(String input, int index);
}

class BookFileWidget extends StatelessWidget {
  BookFileWidget(this._isLaunchedComplete, this._filePath, this._index, this._userInputCallback) {
    _formattedFilePath = _filePath.split("/").last;
  }

  bool _isLaunchedComplete;
  String _filePath;
  String _formattedFilePath;
  int _index;
  UserInputCallback _userInputCallback;

  Widget _bookCompleteFileRepresentation() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left:16.0, right: 16.0),
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
              child: Text(
                _formattedFilePath,
                textAlign: TextAlign.right,
                style: TextStyle(color: TextColorBrightBackground.primary)
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _bookIncompleteFileRepresentation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: <Widget>[
          Container(color: Colors.grey[200], constraints: BoxConstraints.expand(height: 1.0),),
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
                        _formattedFilePath,
                        style: TextStyle(color: TextColorBrightBackground.tertiary, fontSize: 12.0),
                      ),
                    ),
                    TextField(
                      maxLengthEnforced: true,
                      maxLength: Constants.MAX_TITLE_LENGTH,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (String chapterTitle) {
                        if (chapterTitle == null || chapterTitle.isEmpty) {
                          chapterTitle = _formattedFilePath.split(".").first;
                        }
                        _userInputCallback.onInputReady(chapterTitle.trim(), _index);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLaunchedComplete ? _bookCompleteFileRepresentation() : _bookIncompleteFileRepresentation();
  }
}
