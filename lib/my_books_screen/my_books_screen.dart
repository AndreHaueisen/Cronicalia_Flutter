import 'package:cronicalia_flutter/custom_widgets/my_book_widget.dart';
import 'package:cronicalia_flutter/custom_widgets/persistent_bottom_bar.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/my_books_screen/create_my_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
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
          child: new Stack(children: [
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => new CreateMyBookScreen()));
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ]),
        ),
        PersistentBottomBar(
          selectedItemIdex: 3,
        ),
      ]),
    );
  }
}
