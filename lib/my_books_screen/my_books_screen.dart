import 'package:cronicalia_flutter/custom_widgets/my_book_widget.dart';
import 'package:cronicalia_flutter/custom_widgets/persistent_bottom_bar.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/my_books_screen/create_my_book_screen.dart';
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

  Widget _buildNoBookScreen() {
    return Stack(children: <Widget>[
      Image.asset(
        MediaQuery.of(context).orientation == Orientation.portrait ? "images/empty_book_list_port.png" : "images/empty_book_list_land.png",
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
            child: RaisedButton(
              color: AppThemeColors.accentColor,
              textColor: TextColorBrightBackground.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              onPressed: () {
                if (_userStore.isLoggedIn) {
                  print("User logged in");
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => new CreateMyBookScreen(), maintainState: false));
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
          itemCount: _userStore.user.books.length,
          itemBuilder: (context, index) {
            return MyBookWidget(_userStore.user.books.values.elementAt(index), _userStore.user.books.keys.elementAt(index), index,
                _userStore.user.books.length);
          },
        ),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 16.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => new CreateMyBookScreen(), maintainState: false));
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(child: (_userStore.isLoggedIn && _userStore.user.books.isNotEmpty) ? _buildBooksScreen() : _buildNoBookScreen()),
        PersistentBottomBar(
          selectedItemIdex: 3,
        ),
      ]),
    );
  }
}
