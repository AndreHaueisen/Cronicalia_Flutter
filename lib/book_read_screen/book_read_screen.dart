import 'package:cronicalia_flutter/flux/book_store.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

class BookReadScreen extends StatefulWidget {
  BookReadScreen(this._book);

  BookPdf _book;

  @override
  _BookReadScreenState createState() => _BookReadScreenState();
}

class _BookReadScreenState extends State<BookReadScreen> with StoreWatcherMixin {
  BookStore _bookStore;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bookStore = listenToStore(bookStoreToken);
    downloadBookFileAction("placeholderUid");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0, left: 8.0, bottom: 8.0, right: 8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              child: Text(
                _bookStore.currentFileText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
