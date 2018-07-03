import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/login_screen/login_screen.dart';
import 'package:cronicalia_flutter/my_books_screen/edit_my_book_screen.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cronicalia_flutter/bookmarks_screen/bookmarks_screen.dart';
import 'package:cronicalia_flutter/my_books_screen/my_books_screen.dart';
import 'package:cronicalia_flutter/profile_screen/profile_screen.dart';
import 'package:cronicalia_flutter/search_screen/search_screen.dart';
import 'package:cronicalia_flutter/suggestions_screen/suggestions_screen.dart';

//Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_flux/flutter_flux.dart';


class TextColorDarkBackground {
  static final Color primary = Colors.white;
  static final Color secondary = Colors.grey[400];
  static final Color tertiary = Colors.grey[600];
}

class TextColorBrightBackground {
  static final Color primary = Colors.grey[900];
  static final Color secondary = Colors.grey[700];
  static final Color tertiary = Colors.grey[500];
}

class AppThemeColors {
  static final Color primaryColor = Colors.grey[850];
  static final Color primaryColorDark = Colors.black;
  static final Color primaryColorLight = Colors.grey[700];
  static final Color accentColor = Colors.amberAccent;
  static final Color errorColor = Colors.orange[700];
  static final Color backgroundColor = Colors.grey[850];
  static final Color canvasColor = Colors.grey[850];
  static final Color cardColor = Colors.grey[700];
}

void main() {
  runApp(new Cronicalia());
}

class Cronicalia extends StatefulWidget {
  @override
  CronicaliaState createState() => new CronicaliaState();
}

class CronicaliaState extends State<Cronicalia> with SingleTickerProviderStateMixin, StoreWatcherMixin<Cronicalia> {

  UserStore userStore;
  FirebaseStorage firebaseStorage;
  Firestore firestore;
  FirebaseAuth firebaseAuth;
  TabController _tabController;
  int _index = 0;

  Flushbar flushbar = Flushbar(
    backgroundColor: Colors.grey[600],
    shadowColor: Colors.grey[900],
  );

  @override
  void initState() {
    super.initState();

    _initializeFirebase();

    userStore = listenToStore(userStoreToken);
    userStore.isLoggedInAsync().then((isLoggedIn){
      if(isLoggedIn){
        getUserFromServerAction([userStore.userEmail, ""]);
      }
    });

    _tabController = new TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      _onChangeViewRequested(_tabController.index, false);
    });
  }

  
  final _bottomNavigationItems = [_starredItem, _searchItem, _bookmarksItem, _myBooksItem, _profileItem];

  static BottomNavigationBarItem _starredItem = new BottomNavigationBarItem(
      icon: new Icon(Icons.star), title: new Text("Starred"), backgroundColor: Colors.grey[850]);
  static BottomNavigationBarItem _searchItem = new BottomNavigationBarItem(
      icon: new Icon(Icons.search), title: new Text("Search"), backgroundColor: Colors.grey[850]);
  static BottomNavigationBarItem _bookmarksItem = new BottomNavigationBarItem(
      icon: new Icon(Icons.collections_bookmark), title: new Text("Bookmarks"), backgroundColor: Colors.grey[850]);
  static BottomNavigationBarItem _myBooksItem = new BottomNavigationBarItem(
      icon: new Icon(Icons.library_books), title: new Text("My Books"), backgroundColor: Colors.grey[850]);
  static BottomNavigationBarItem _profileItem = new BottomNavigationBarItem(
      icon: new Icon(Icons.person), title: new Text("Profile"), backgroundColor: Colors.grey[850]);

  void _onChangeViewRequested(int newIndex, bool shouldRequestViewChangeOnController) {
    setState(() {
      _index = newIndex;

      if (shouldRequestViewChangeOnController) _tabController.animateTo(_index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      routes: <String, WidgetBuilder>{
        Constants.ROUTE_LOGIN_SCREEN: (BuildContext context) =>
            new LoginScreen(firebaseAuth, firestore, flushbar, context)
      },
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppThemeColors.primaryColor,
        primaryColorDark: AppThemeColors.primaryColorDark,
        primaryColorLight: AppThemeColors.primaryColorLight,
        accentColor: AppThemeColors.accentColor,
        errorColor: AppThemeColors.errorColor,
        backgroundColor: AppThemeColors.backgroundColor,
        canvasColor: AppThemeColors.canvasColor,
        cardColor: AppThemeColors.cardColor,
        toggleableActiveColor: AppThemeColors.accentColor
      ),
      title: 'Cronicalia',
      home: new Scaffold(
        body: new TabBarView(children: <Widget>[
          new SuggestionsScreen(flushbar),
          new SearchScreen(flushbar),
          new BookmarksScreen(flushbar),
          new MyBooksScreen(flushbar),
          new ProfileScreen(flushbar)
        ], controller: _tabController),
        bottomNavigationBar: new BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            onTap: (int index) {
              _onChangeViewRequested(index, true);
            },
            items: _bottomNavigationItems,
            fixedColor: Colors.amberAccent,
            currentIndex: _index),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
