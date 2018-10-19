import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/flux/book_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/epub_parser.dart';
import 'package:epub/epub.dart' as epubLib;
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart' as pdfViwer;
import 'package:flutter_html/flutter_html.dart' as epubViwer;

// Displays PDF books
class BookPdfReadScreen extends StatefulWidget {
  BookPdfReadScreen(this._book);

  BookPdf _book;

  @override
  _BookPdfReadScreenState createState() => _BookPdfReadScreenState();
}

class _BookPdfReadScreenState extends State<BookPdfReadScreen> with StoreWatcherMixin {
  BookStore _bookStore;
  File _currentBookFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bookStore = listenToStore(bookStoreToken);
    downloadBookFileAction(widget._book);

    _bookStore.currentBookFileCompleter.future.then((File bookFile) {
      _currentBookFile = bookFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _currentBookFile == null
        ? Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 8.0, bottom: 8.0, right: 8.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    child: Text(
                      "no book detected",
                    ),
                  ),
                ),
              ),
            ),
          )
        : pdfViwer.PDFViewerScaffold(
            path: _currentBookFile.path,
          );
  }
}

// Displays Epub books
class BookEpubReadScreen extends StatefulWidget {
  BookEpubReadScreen(this._book);

  BookEpub _book;

  @override
  _BookEpubReadScreenState createState() => _BookEpubReadScreenState();
}

class _BookEpubReadScreenState extends State<BookEpubReadScreen> with StoreWatcherMixin {
  BookStore _bookStore;
  EpubParser _epubParser;
  Completer<String> _showingChapterHtml = Completer<String>();
  File _currentBookFile;

  @override
  void initState() {
    super.initState();

    _bookStore = listenToStore(bookStoreToken);
    downloadBookFileAction(widget._book);

    initializeBook();
  }

  Future<void> initializeBook() async {
    File bookFile = await _bookStore.currentBookFileCompleter.future;
    epubLib.EpubBook epubBook = await epubLib.EpubReader.readBook(bookFile.readAsBytesSync());
    _epubParser = EpubParser(epubBook);

    _showingChapterHtml.complete(_epubParser.readChapter(5));
  }

  //TODO change completer to a stream
  //See ways to navigate through the epub file

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _epubParser.extractTitle(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Container(
            child: FutureBuilder(
              future: _showingChapterHtml.future,
              builder: ((BuildContext buildContext, AsyncSnapshot<dynamic> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Text('Analyzing book...');
                  case ConnectionState.done:
                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                    return epubViwer.Html(
                      data: snapshot.data,
                      defaultTextStyle: TextStyle(color: TextColorDarkBackground.primary),
                      //style: TextStyle(color: Colors.white),
                    );
                }
                return null;
              }),
            ),
          ),
        ),
      ),
    );
  }
}
