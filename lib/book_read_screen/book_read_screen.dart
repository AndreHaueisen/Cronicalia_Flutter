import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/flux/book_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart' as pdfViwer;
import 'package:flutter_html/flutter_html.dart' as epubViwer;

// Displays PDF books
class BookPdfReadScreen extends StatefulWidget {
  BookPdfReadScreen(this._book);

  final BookPdf _book;

  @override
  _BookPdfReadScreenState createState() => _BookPdfReadScreenState();
}

class _BookPdfReadScreenState extends State<BookPdfReadScreen>
    with StoreWatcherMixin {
  BookStore _bookStore;

  @override
  void initState() {
    super.initState();

    _bookStore = listenToStore(bookStoreToken);

    Completer bookReadyCompleter = Completer();
    downloadBookFileAction([widget._book, bookReadyCompleter]);

    bookReadyCompleter.future.then((_) {
      generateNavMapAction(widget._book);
    });
  }

  @override
  void dispose() {
    disposeBookAction();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bookStore.showingFileData == null
        ? Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(
                  top: 24.0, left: 8.0, bottom: 8.0, right: 8.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "No book detected",
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : pdfViwer.PDFViewerScaffold(
            appBar: AppBar(
              title: Text(widget._book.chapterTitles[0]),
            ),
            path: _bookStore.showingFileData,
          );
  }
}

// Displays Epub books
class BookEpubReadScreen extends StatefulWidget {
  BookEpubReadScreen(this._book);

  final BookEpub _book;

  @override
  _BookEpubReadScreenState createState() => _BookEpubReadScreenState();
}

class _BookEpubReadScreenState extends State<BookEpubReadScreen>
    with StoreWatcherMixin {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  BookStore _bookStore;
  double _textSize;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _bookStore = listenToStore(bookStoreToken);
    Completer bookReadyCompleter = Completer();
    downloadBookFileAction([widget._book, bookReadyCompleter]);

    _initializeTextSize();

    bookReadyCompleter.future.then((_) {
      generateNavMapAction(widget._book);
    });
  }

  @override
  void dispose() {
    disposeBookAction();
    super.dispose();
  }

  bool _isBookContentOnDisplay = false;

  ScrollController _scrollController = ScrollController();

  Future<void> _initializeTextSize() async{
    _textSize = await _prefs.then((SharedPreferences prefs) {
      return (prefs.getDouble(Constants.SHARED_PREFERENCES_TEXT_SIZE_KEY) ?? 14.0);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _bookStore.epubParser != null
              ? _bookStore.epubParser.extractTitle()
              : "Loading Book...",
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          child: _bookStore.navigationMap == null
              ? Center(
                  child: LinearProgressIndicator(),
                )
              : AnimatedCrossFade(
                  crossFadeState: _isBookContentOnDisplay
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Duration(seconds: 1),
                  firstChild: _buildNavigationMapWidget(),
                  secondChild: _buildBookContentWidget(),
                ),
        ),
      ),
    );
  }

  Widget _buildNavigationMapWidget() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _bookStore.navigationMap.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Text(_bookStore.navigationMap.keys.elementAt(index)),
            onTap: () {
              navigateToChapterAction([widget._book, index]);
              _isBookContentOnDisplay = true;
            },
          );
        });
  }

  PersistentBottomSheetController _bottomSheetController;

  Widget _buildBookContentWidget() {
    try {
      return InkWell(
        splashColor: AppThemeColors.primaryColorLight,
        highlightColor: AppThemeColors.primaryColorLight,
        onLongPress: () {
          if (_bottomSheetController == null) {
            _bottomSheetController =
                _scaffoldKey.currentState.showBottomSheet((context) {
              return _buildBottomSheetWidget();
            });
            _bottomSheetController.closed.whenComplete(() {
              _bottomSheetController = null;
            });
          }
        },
        onTap: () {
          _bottomSheetController?.close();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: epubViwer.Html(
            data: _bookStore.showingFileData,
            backgroundColor: Colors.transparent,
            defaultTextStyle:
                TextStyle(color: Colors.white, fontSize: _textSize),
          ),
        ),
      );
    } catch (error) {
      Timer(Duration(seconds: 2), () {
        setState(() {
          _isBookContentOnDisplay = false;
        });
      });

      return Center(
        child: Text("Section data not suported"),
      );
    }
  }

  Widget _buildBottomSheetWidget() {
    return Container(
      decoration: BoxDecoration(
          color: AppThemeColors.cardColor,
          borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavigationButtons(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Divider(
              height: 2.0,
              color: AppThemeColors.primaryColor,
            ),
          ),
          _buildTextSizeWidget(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton.icon(
              onPressed: () {
                backwardChapterAction(widget._book);
                _scrollController.animateTo(0.0,
                    duration: Duration(seconds: 2), curve: Curves.decelerate);
              },
              icon: Icon(Icons.arrow_left),
              label: Text("BACK"),
            ),
            FlatButton.icon(
              onPressed: () {
                setState(() {
                  _isBookContentOnDisplay = false;
                });
              },
              icon: Icon(
                Icons.navigation,
                size: 12.0,
              ),
              label: Text("CONTENTS"),
            ),
            FlatButton.icon(
              onPressed: () {
                forwardChapterAction(widget._book);
                _scrollController.animateTo(0.0,
                    duration: Duration(seconds: 2), curve: Curves.decelerate);
              },
              icon: Icon(Icons.arrow_right),
              label: Text("FORWARD"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextSizeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              "Text Size",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: IconButton(
              icon: Icon(Icons.keyboard_arrow_up),
              onPressed: () {
                if (_textSize < MAX_TEXT_SIZE) {
                  setState(() {
                    _textSize++;
                    _prefs.then((SharedPreferences sharedPreferences){
                      sharedPreferences.setDouble(Constants.SHARED_PREFERENCES_TEXT_SIZE_KEY, _textSize);
                    });
                  });
                }
              }),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: () {
                  if (_textSize > MIN_TEXT_SIZE) {
                    setState(() {
                      _textSize--;
                      _prefs.then((SharedPreferences sharedPreferences){
                        sharedPreferences.setDouble(Constants.SHARED_PREFERENCES_TEXT_SIZE_KEY, _textSize);
                      });
                    });
                  }
                }),
          ),
        )
      ],
    );
  }
}

const double MAX_TEXT_SIZE = 24.0;
const double MIN_TEXT_SIZE = 12.0;
