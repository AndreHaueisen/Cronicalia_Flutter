import 'package:cronicalia_flutter/custom_widgets/persistent_bottom_bar.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

class SuggestionsScreen extends StatefulWidget {
  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> with StoreWatcherMixin<SuggestionsScreen> {
  UserStore userStore;

  @override
  void initState() {
    super.initState();

    userStore = listenToStore(userStoreToken);
    userStore.isLoggedInAsync().then((isLoggedIn) {
      if (isLoggedIn) {
        getUserFromServerAction([userStore.userEmail, ""]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Column(
        children: [
          Expanded(child: new Text("Suggestions Screen")),
          PersistentBottomBar(
            selectedItemIdex: 0,
          )
        ],
      ),
    );
  }
}
