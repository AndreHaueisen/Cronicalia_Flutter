import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

abstract class BookFileWidgetCallback {
  void onRemoveFileClick({String filePath, String fileTitle});
}

class BookFileWidget extends StatelessWidget {
  BookFileWidget(
      {Key key,
      this.isComplete,
      this.isReorderable = true,
      this.filePath,
      this.fileTitle,
      this.index,
      this.bookFileWidgetCallback,
      this.widgetHeight})
      : formattedFilePath = filePath?.split("/")?.last,
        _textController = (fileTitle != null) ? TextEditingController(text: fileTitle) : null,
        super(key: key);

  final bool isComplete;
  final bool isReorderable;
  final String filePath;
  String fileTitle;
  final String formattedFilePath;
  final int index;
  final BookFileWidgetCallback bookFileWidgetCallback;
  final double widgetHeight;
 

  TextEditingController _textController;

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
                constraints: BoxConstraints.expand(height: 36.0),
                padding: EdgeInsets.all(8.0),
                color: Colors.black12,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(formattedFilePath ?? fileTitle,
                      textAlign: TextAlign.right, style: TextStyle(color: TextColorBrightBackground.primary)),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: TextColorBrightBackground.tertiary,
                ),
                onPressed: () {
                  bookFileWidgetCallback.onRemoveFileClick(filePath: filePath, fileTitle: fileTitle);
                },
              ),
            ),
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
                    formattedFilePath != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 8.0),
                            child: Text(
                              formattedFilePath,
                              style: TextStyle(color: TextColorBrightBackground.tertiary, fontSize: 12.0),
                            ),
                          )
                        : Container(
                            height: 0.0,
                            width: 0.0,
                          ),
                    TextField(
                      maxLengthEnforced: true,
                      controller: _textController,
                      maxLength: Constants.MAX_TITLE_LENGTH,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onChanged: (String title) {
                        fileTitle = title.trim();
                      },
                      style: TextStyle(color: TextColorBrightBackground.primary),
                      maxLines: 1,
                      decoration: InputDecoration(
                          fillColor: Colors.black12,
                          filled: true,
                          border: UnderlineInputBorder(),
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
            Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: formattedFilePath == null ? 18.0 : 0.0),
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: TextColorBrightBackground.tertiary,
                  ),
                  onPressed: () {
                    bookFileWidgetCallback.onRemoveFileClick(filePath: filePath, fileTitle: fileTitle);
                    _textController?.dispose();
                    _textController = null;
                  },
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(bottom: formattedFilePath == null ? 18.0 : 0.0),
                child: IconButton(
                  icon: Icon(
                    Icons.reorder,
                    color: TextColorBrightBackground.primary,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isComplete) return _noInputFileRepresentation();

    return _textInputFileRepresentation();
  }

  void cleanUp() {
    _textController?.dispose();
  }
}
