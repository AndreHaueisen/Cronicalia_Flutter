import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cronicalia_flutter/models/book_stop_info.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:cronicalia_flutter/custom_widgets/rounded_button_widget.dart';
import 'package:cronicalia_flutter/flux/book_read_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart' as pdfViewer;
import 'package:flutter_html/flutter_html.dart' as epubViewer;

// Displays PDF books
class BookPdfReadScreen extends StatefulWidget {
  BookPdfReadScreen(this._book);

  final BookPdf _book;

  @override
  _BookPdfReadScreenState createState() => _BookPdfReadScreenState();
}

class _BookPdfReadScreenState extends State<BookPdfReadScreen> with StoreWatcherMixin {
  BookReadStore _bookReadStore;

  @override
  void initState() {
    super.initState();

    _bookReadStore = listenToStore(bookReadStoreToken);

    Completer bookReadyCompleter = Completer();
    downloadBookFileAction([widget._book, bookReadyCompleter]);

    bookReadyCompleter.future.then((_) {
      generateNavMapAction(widget._book);
    });
  }

  @override
  void dispose() {
    disposeBookAction();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bookReadStore.showingFileData == null
        ? Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 8.0,
                bottom: 8.0,
                right: 8.0,
              ),
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
        : pdfViewer.PDFViewerScaffold(
            appBar: AppBar(
              title: Text(widget._book.chapterTitles[0]),
            ),
            path: _bookReadStore.showingFileData,
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

class _BookEpubReadScreenState extends State<BookEpubReadScreen> with StoreWatcherMixin {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  BookReadStore _bookReadStore;
  double _textSize;
  BookStopInfo _bookStopInfo;
  bool _isFullScreen = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _bookReadStore = listenToStore(bookReadStoreToken);

    _bookStopInfo = BookStopInfo(widget._book.uID, _bookReadStore.currentChapterIndex, 0.0);

    Completer bookReadyCompleter = Completer();
    downloadBookFileAction([widget._book, bookReadyCompleter]);

    bookReadyCompleter.future.then((_) {
      generateNavMapAction(widget._book);
      _retrieveSharedPreferences();
    });
  }

  @override
  void dispose() {
    _saveBookPosition();
    disposeBookAction();
    super.dispose();
  }

  void _saveBookPosition() {
    _prefs.then((SharedPreferences prefs) {
      if (_bookStopInfo != null) {
        prefs.setString(BookStopInfo.generateSharedPreferencesKey(widget._book.uID), _bookStopInfo.toJson());
      }
    });
  }

  bool _isBookContentOnDisplay = false;

  ScrollController _scrollController = ScrollController();

  Future<void> _retrieveSharedPreferences() async {
    _textSize = await _prefs.then((SharedPreferences prefs) {
      if (prefs.getKeys().contains(BookStopInfo.generateSharedPreferencesKey(widget._book.uID))) {
        showReturnToLastPositionDialog(prefs);
      }
      return (prefs.getDouble(Constants.SHARED_PREFERENCES_TEXT_SIZE_KEY) ?? 14.0);
    });

    setState(() {});
  }

  void showReturnToLastPositionDialog(SharedPreferences prefs) {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return SimpleDialog(
            title: Text("Go to last location?"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("STAY"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SimpleDialogOption(
                child: Text("GO"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _bookStopInfo = BookStopInfo.fromJson(
                    prefs.getString(
                      BookStopInfo.generateSharedPreferencesKey(widget._book.uID),
                    ),
                  );
                  navigateToChapterAction([widget._book, _bookStopInfo.lastChapterIndex]);
                  _isBookContentOnDisplay = true;
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _scrollController.animateTo(
                      _bookStopInfo.scrollPosition,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _bookStopInfo.scrollPosition = _scrollController.offset;
        _bookStopInfo.lastChapterIndex = _bookReadStore.currentChapterIndex;
        return Future<bool>.value(true);
      },
      child: _bookReadStore.navigationList.isEmpty
          ? Hero(tag: Constants.HERO_TAG_BOOK_COVER, child: Image.network(widget._book.remoteCoverUri))
          : Scaffold(
              key: _scaffoldKey,
              appBar: _isFullScreen
                  ? null
                  : AppBar(
                      title: Text(
                        widget._book.title,
                      ),
                    ),
              body: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  child: AnimatedCrossFade(
                    crossFadeState: _isBookContentOnDisplay ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: Duration(seconds: 1),
                    firstChild: _buildNavigationMapWidget(),
                    secondChild: _buildBookContentWidget(),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNavigationMapWidget() {
    return Center(
      child: ListView.builder(
          physics: PageScrollPhysics(),
          shrinkWrap: true,
          itemCount: _bookReadStore.navigationList.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 64.0, left: 64.0),
              child: RoundedButton(
                color: AppThemeColors.primaryColorLight,
                onPressed: () {
                  navigateToChapterAction([widget._book, index]);
                  _isBookContentOnDisplay = true;
                },
                child: Text(
                  _bookReadStore.navigationList[index].toUpperCase(),
                ),
              ),
            );
          }),
    );
  }

  PersistentBottomSheetController _bottomSheetController;

  Widget _buildBookContentWidget() {
    try {
      return InkWell(
        splashColor: AppThemeColors.primaryColorLight,
        highlightColor: AppThemeColors.primaryColorLight,
        onLongPress: () {
          if (_bottomSheetController == null) {
            _bottomSheetController = _scaffoldKey.currentState.showBottomSheet((context) {
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
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: epubViewer.Html(
              data: _bookReadStore.showingFileData,
              backgroundColor: Colors.transparent,
              defaultTextStyle: TextStyle(color: Colors.white, fontSize: _textSize),
            ),
          ),
        ),
      );
    } catch (error) {
      print("HTML render failed");
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
      decoration: BoxDecoration(color: AppThemeColors.cardColor, borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavigationButtons(),
          _buildDivider(),
          _buildTextSizeWidget(),
          _buildDivider(),
          _buildFullScreenButton(),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Divider(
        height: 2.0,
        color: AppThemeColors.primaryColor,
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
                _scrollController.animateTo(0.0, duration: Duration(seconds: 2), curve: Curves.decelerate);
              },
              icon: Icon(Icons.arrow_left),
              label: Text("BACK"),
            ),
            FlatButton.icon(
              onPressed: () {
                setState(() {
                  _isBookContentOnDisplay = false;
                  _bottomSheetController?.close();
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
                _scrollController.animateTo(0.0, duration: Duration(seconds: 2), curve: Curves.decelerate);
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
                    _prefs.then((SharedPreferences sharedPreferences) {
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
                      _prefs.then((SharedPreferences sharedPreferences) {
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

  Widget _buildFullScreenButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Text(
            "Fullscreen",
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Switch(
              value: _isFullScreen,
              onChanged: (bool isFullScreen) {
                _isFullScreen = isFullScreen;
                if (isFullScreen) {
                  setState(() {
                    SystemChrome.setEnabledSystemUIOverlays([]);
                  });
                } else {
                  setState(() {
                    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                  });
                }

                _bottomSheetController?.close();
              }),
        )
      ],
    );
  }
}

const double MAX_TEXT_SIZE = 24.0;
const double MIN_TEXT_SIZE = 12.0;
