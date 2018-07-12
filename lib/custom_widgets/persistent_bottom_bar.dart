import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

final List<IconData> itemIcons = [Icons.star, Icons.search, Icons.collections_bookmark, Icons.library_books, Icons.person];
final List<String> itemTitles = ["Starred", "Search", "Bookmarks", "My Books", "Profile"];

class PersistentBottomBar extends StatelessWidget {
  PersistentBottomBar({@required this.selectedItemIdex})
      : assert(itemIcons.length == itemTitles.length, "Icons and titles must have equal lenghts"),
        assert(selectedItemIdex < itemIcons.length, "Highlighted item index invalid");

  final int selectedItemIdex;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: Constants.BOTTOM_NAV_TAG,
      child: Container(
        height: 56.0,
        color: AppThemeColors.primaryColorDark,
        child: Row(
          children: composeItens(context),
        ),
      ),
    );
  }

  List<Widget> composeItens(BuildContext context) {
    List<Widget> fullItens = List();

    for (var index = 0; index < itemIcons.length; index++) {
      Color color = (selectedItemIdex == index) ? AppThemeColors.accentColor : AppThemeColors.primaryColorLight;

      Widget singleItem = Expanded(
        flex: 1,
        child: MaterialButton(
          padding: EdgeInsets.all(0.0),
          onPressed: () {
            if (index != selectedItemIdex) {
              routeToCorrectScreen(context, index);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(
                  itemIcons[index],
                  size: (selectedItemIdex == index) ? 24.0 : 22.0,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  itemTitles[index],
                  maxLines: 1,
                  style: TextStyle(color: color, fontSize: (selectedItemIdex == index) ? 13.0 : 12.0),
                ),
              )
            ],
          ),
        ),
      );

      fullItens.add(singleItem);
    }

    return fullItens;
  }

  void routeToCorrectScreen(BuildContext context, int buttonIndex) {
    switch (buttonIndex) {
      case 0:
        {
          Navigator.of(context).pushNamed(Constants.ROUTE_SUGGESTIONS_SCREEN);
          break;
        }
      case 1:
        {
          Navigator.of(context).pushNamed(Constants.ROUTE_SEARCH_SCREEN);
          break;
        }
      case 2:
        {
          Navigator.of(context).pushNamed(Constants.ROUTE_BOOKMARKS_SCREEN);
          break;
        }
      case 3:
        {
          Navigator.of(context).pushNamed(Constants.ROUTE_MY_BOOKS_SCREEN);
          break;
        }
      case 4:
        {
          Navigator.of(context).pushNamed(Constants.ROUTE_PROFILE_SCREEN);
          break;
        }
      default:
        break;
    }
  }
}
