import 'package:cronicalia_flutter/custom_widgets/persistent_bottom_bar.dart';
import 'package:cronicalia_flutter/custom_widgets/recommended_books_by_genre_widget.dart';
import 'package:cronicalia_flutter/flux/book_store.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

class SuggestionsScreen extends StatefulWidget {
  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> with StoreWatcherMixin<SuggestionsScreen> {
  UserStore _userStore;
  BookStore _bookStore;

  @override
  void initState() {
    super.initState();

    _userStore = listenToStore(userStoreToken);
    _userStore.isLoggedInAsync().then((isLoggedIn) {
      if (isLoggedIn) {
        getUserFromServerAction(_userStore.user);
      }
    });

    _bookStore = listenToStore(bookStoreToken);
    //TODO change ENGLISH to the chosen user languages
    loadBookRecomendationsAction(BookLanguage.ENGLISH);
  }

  static const int _GENRE_COUNT = 10;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: new Column(
        children: [
          Expanded(
            child: _bookStore.totalNumberOfBooks > 0
                ? ListView.builder(
                    itemCount: _GENRE_COUNT,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext buildContext, int index) {
                      List<Book> currentList = _getRecommendedBookListByIndex(index);

                      return currentList.isNotEmpty
                          ? RecommendeBooksByGenreWidget(
                              recommendedBooks: currentList,
                              currentGenre: _getRecommendedBookGenreByIndex(index),
                            )
                          : Container(
                              height: 0.0,
                              width: 0.0,
                            );
                    },
                  )
                : Container(
                    width: 0.0,
                    height: 0.0,
                  ),
          ),
          PersistentBottomBar(
            selectedItemIdex: 0,
          )
        ],
      ),
    );
  }

  List<Book> _getRecommendedBookListByIndex(int index) {
    switch (index) {
      case 0:
        return _bookStore.actionBooks;
      case 1:
        return _bookStore.adventureBooks;
      case 2:
        return _bookStore.comedyBooks;
      case 3:
        return _bookStore.dramaBooks;
      case 4:
        return _bookStore.fantasyBooks;
      case 5:
        return _bookStore.fictionBooks;
      case 6:
        return _bookStore.horrorBooks;
      case 7:
        return _bookStore.mythologyBooks;
      case 8:
        return _bookStore.romanceBooks;
      case 9:
        return _bookStore.satireBooks;
      default:
        return List<Book>();
    }
  }

  BookGenre _getRecommendedBookGenreByIndex(int index) {
    switch (index) {
      case 0:
        return BookGenre.ACTION;
      case 1:
        return BookGenre.ADVENTURE;
      case 2:
        return BookGenre.COMEDY;
      case 3:
        return BookGenre.DRAMA;
      case 4:
        return BookGenre.FANTASY;
      case 5:
        return BookGenre.FICTION;
      case 6:
        return BookGenre.HORROR;
      case 7:
        return BookGenre.MYTHOLOGY;
      case 8:
        return BookGenre.ROMANCE;
      case 9:
        return BookGenre.SATIRE;
      default:
        return BookGenre.UNDEFINED;
    }
  }
}
