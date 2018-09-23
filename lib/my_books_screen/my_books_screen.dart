import 'dart:async';

import 'package:cronicalia_flutter/custom_widgets/my_book_widget.dart';
import 'package:cronicalia_flutter/custom_widgets/persistent_bottom_bar.dart';
import 'package:cronicalia_flutter/custom_widgets/rounded_button_widget.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/my_books_screen/create_epub_my_book_screen.dart';
import 'package:cronicalia_flutter/my_books_screen/create_pdf_my_book_screen.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

class MyBooksScreen extends StatefulWidget {
  MyBooksScreen();

  @override
  State createState() {
    return MyBooksScreenState();
  }
}

class MyBooksScreenState extends State<MyBooksScreen> with StoreWatcherMixin<MyBooksScreen> {
  UserStore _userStore;

  @override
  void initState() {
    super.initState();

    _userStore = listenToStore(userStoreToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
            child: (_userStore.isLoggedIn && (_userStore.user.booksPdf.isNotEmpty || _userStore.user.booksEpub.isNotEmpty)) ? _buildBooksScreen() : _buildNoBookScreen()),
        PersistentBottomBar(
          selectedItemIdex: 3,
        ),
      ]),
    );
  }

  Widget _buildNoBookScreen() {
    return Stack(children: <Widget>[
      Image.asset(
        MediaQuery.of(context).orientation == Orientation.portrait
            ? "images/empty_book_list_port.png"
            : "images/empty_book_list_land.png",
        fit: BoxFit.fill,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
      Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                "Uoh! No books here",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 72.0,
                  color: const Color(0xD0FFFFFF),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: RoundedButton(
              elevation: 4.0,
              color: AppThemeColors.accentColor,
              textColor: TextColorBrightBackground.primary,
              onPressed: () {
                if (_userStore.isLoggedIn) {
                  print("User logged in");
                  _showFileFormatDialog();
                } else {
                  Navigator.of(context).pushNamed(Constants.ROUTE_LOGIN_SCREEN);
                }
              },
              child: Text("CREATE NEW BOOK"),
            ),
          )
        ],
      ),
    ]);
  }

  Widget _buildBooksScreen() {
    return new Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemExtent: MediaQuery.of(context).size.width,
          scrollDirection: Axis.horizontal,
          itemCount: _userStore.user.booksPdf.length,
          itemBuilder: (context, index) {
            return MyBookWidget(_userStore.user.booksPdf.values.elementAt(index), _userStore.user.booksPdf.keys.elementAt(index),
                index, _userStore.user.booksPdf.length);
          },
        ),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 16.0),
          child: FloatingActionButton(
            onPressed: () {
              _showFileFormatDialog();
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    ]);
  }

  Future<Null> _showFileFormatDialog() async {
    switch (await showDialog<BookFileFormat>(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: const Text('Book file format'),
            children: <Widget>[
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, BookFileFormat.EPUB);
                },
                child: const Text('EPUB'),
              ),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, BookFileFormat.PDF);
                },
                child: const Text('PDF'),
              ),
            ],
          );
        })) {
      case BookFileFormat.EPUB:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => new CreateEpubMyBookScreen(), maintainState: false));
        break;
      case BookFileFormat.PDF:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => new CreatePdfMyBookScreen(), maintainState: false));
        break;
    }
  }
}

enum BookFileFormat {EPUB, PDF}