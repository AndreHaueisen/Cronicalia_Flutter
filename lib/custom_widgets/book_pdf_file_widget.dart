import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/utility.dart';
import 'package:flutter/material.dart';

abstract class BookFileWidgetCallback {
  void onRemoveFileClick({int position});
}

class BookPdfFileWidget extends StatelessWidget {
  BookPdfFileWidget(
      {Key key,
      @required this.isReorderable,
      @required this.allowUserInput,
      @required this.isSingleFileBook,
      this.isDeletable = true,
      this.filePath,
      this.date,
      this.position,
      this.fileTitle,
      this.bookFileWidgetCallback,
      this.widgetHeight})
      : assert(filePath != null, "File path can not be null"),
        super(key: key) {
    _formattedFilePath = _formatFilePath(filePath);
  }

  final bool isReorderable;
  final bool allowUserInput;
  final bool isSingleFileBook;
  final bool isDeletable;

  final String filePath;
  final int date;
  final BookFileWidgetCallback bookFileWidgetCallback;
  final double widgetHeight;
  int position;
  String fileTitle;
  String _formattedFilePath;

  String get formattedFilePath => _formattedFilePath;

  TextEditingController _textController;

  String _formatFilePath(String filePath) {
    if (Utility.isFileRemote(filePath)) {
      return Utility.resolveFileNameFromUrl(filePath);
    } else {
      return Utility.resolveFileNameFromLocalFolder(filePath);
    }
  }

  Widget _noInputFileRepresentation() {
    return SizedBox(
      height: widgetHeight,
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Container(
                constraints: BoxConstraints.expand(height: 56.0),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4.0)),
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(formattedFilePath,
                        textAlign: TextAlign.left, style: TextStyle(color: TextColorBrightBackground.primary))),
              ),
            ),
          ),
          isDeletable
              ? Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: TextColorBrightBackground.tertiary,
                      ),
                      onPressed: () {
                        bookFileWidgetCallback.onRemoveFileClick(position: position);
                      },
                    ),
                  ),
                )
              : Container(
                  height: 0.0,
                  width: 0.0,
                ),
          isReorderable
              ? Flexible(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.reorder,
                      color: TextColorBrightBackground.secondary,
                    ),
                    onPressed: () {},
                  ),
                )
              : Container(height: 0.0, width: 0.0),
        ],
      ),
    );
  }

  Widget _textInputFileRepresentation() {
    return SizedBox(
      height: widgetHeight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: Text(
                          formattedFilePath,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: TextColorBrightBackground.tertiary, fontSize: 13.0),
                        ),
                      ),
                    ),
                    TextField(
                      maxLengthEnforced: true,
                      controller: _textController,
                      maxLength: Constants.MAX_TITLE_LENGTH,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onChanged: (String title) {
                        fileTitle = title.trim();
                      },
                      style: TextStyle(color: TextColorBrightBackground.primary),
                      maxLines: 1,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          fillColor: Colors.black12,
                          filled: true,
                          border: UnderlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                          labelText: "Chapter Title",
                          labelStyle: TextStyle(color: TextColorBrightBackground.tertiary, fontSize: 13.0),
                          counterStyle: TextStyle(
                            color: TextColorBrightBackground.tertiary,
                            fontSize: 10.0,
                          )),
                    ),
                  ],
                ),
              ),
            ),
            isDeletable
                ? Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: TextColorBrightBackground.tertiary,
                        ),
                        onPressed: () {
                          bookFileWidgetCallback.onRemoveFileClick(position: position);
                        },
                      ),
                    ),
                  )
                : Container(
                    height: 0.0,
                    width: 0.0,
                  ),
            isReorderable
                ? Flexible(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(
                        Icons.reorder,
                        color: TextColorBrightBackground.primary,
                      ),
                      onPressed: () {},
                    ),
                  )
                : Container(
                    height: 0.0,
                    width: 0.0,
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (allowUserInput) return _textInputFileRepresentation();

    return _noInputFileRepresentation();
  }

  void cleanUp() {
    _textController?.dispose();
  }
}
