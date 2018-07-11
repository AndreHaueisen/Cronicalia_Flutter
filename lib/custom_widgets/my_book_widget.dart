import 'package:cronicalia_flutter/custom_widgets/outsider_button_widget.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/my_books_screen/edit_my_book_screen.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class MyBookWidget extends StatelessWidget {
  final Book _book;
  final String _bookKey;
  final int _index;
  final int _totalBookNumber;


  MyBookWidget(this._book, this._bookKey, this._index, this._totalBookNumber);

  Widget _backLineWidget() {
    return Positioned(
      top: 120.0,
      left: 0.0,
      right: 0.0,
      child: Padding(
        padding: _getBackLinePadding(),
        child: Container(
          height: 2.0,
          color: AppThemeColors.accentColor,
        ),
      ),
    );
  }

  EdgeInsets _getBackLinePadding() {
    if (_totalBookNumber > 1) {
      if (_index == 0) {
        return const EdgeInsets.only(left: 48.0);
      } else if (_index == (_totalBookNumber - 1)) {
        return const EdgeInsets.only(right: 48.0);
      } else {
        return const EdgeInsets.all(0.0);
      }
    } else {
      return const EdgeInsets.only(right: 48.0, left: 48.0);
    }
  }

  Widget _bookInfoCard(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 215.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
              child: Text(
                _book.title,
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text(
                _book.synopsis,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
              ),
            ),
            _bookStatsWidget(),
            Align(
              alignment: FractionalOffset.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
                child: Text(
                  "Publication ${_book.publicationDate}",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            ),
            Align(
              alignment: FractionalOffset.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Text(
                  _book.isLaunchedComplete ? "Book complete" : "${_book.remoteChapterTitles.length} chapters",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookStatsWidget() {
    return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Icon(Icons.remove_red_eye),
                    ),
                    Text(_book.readingsNumber.toString())
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 6.0),
                      child: Icon(Icons.star),
                    ),
                    Text(_book.rating.toString())
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.attach_money),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(_book.income.toString()),
                    )
                  ],
                )
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 35.0),
      child: Stack(
        children: <Widget>[
          _backLineWidget(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 42.0, right: 8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Image(
                    width: 135.0,
                    height: 180.0,
                    image: NetworkImage(_book.remoteCoverUri),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: _bookInfoCard(context),
                ),
              ],
            ),
          ),
          FractionalTranslation(
            translation: Offset(0.2, 7.1),
            child: OutsiderButton(
              onPressed: () {
                Navigator
                    .of(context)
                    .push(MaterialPageRoute(builder: (context) => new EditMyBookScreen(_bookKey)));
                print("show edit mode");
              },
              icon: Icon(Icons.edit),
              position: OutsiderButtonPosition.BOTTOM,
            ),
          ),
          FractionalTranslation(
            translation: Offset(1.0, 7.1),
            child: OutsiderButton(
              onPressed: () {
                print("show opinions");
              },
              icon: Icon(Icons.chat_bubble_outline),
              position: OutsiderButtonPosition.BOTTOM,
            ),
          ),
        ],
      ),
    );
  }
}
