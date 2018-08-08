import 'package:cronicalia_flutter/custom_widgets/outsider_button_widget.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/my_books_screen/edit_my_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final DateFormat publicationDateFormat = DateFormat("MM/dd/yyyy");
    final String readableDate = publicationDateFormat.format(DateTime.fromMillisecondsSinceEpoch(_book.publicationDate));

    return Card(
      child: SizedBox(
        height: 215.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
              child: Text(
                _book.title,
                style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w700,),
                
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text(_book.synopsis,
                  style: TextStyle(color: TextColorDarkBackground.secondary),
                  textAlign: TextAlign.justify,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4),
            ),
            _bookStatsWidget(),
            Align(
              alignment: FractionalOffset.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
                child: Text(
                  "Publication  $readableDate",
                  style: TextStyle(fontSize: 12.0, color: TextColorDarkBackground.secondary),
                ),
              ),
            ),
            Align(
              alignment: FractionalOffset.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Text(
                  _book.isLaunchedComplete ? "Book complete" : "${_book.remoteChapterTitles.length} chapters",
                  style: TextStyle(fontSize: 12.0, color: TextColorDarkBackground.secondary),
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
                child: Icon(Icons.remove_red_eye, color: TextColorDarkBackground.tertiary,),
              ),
              Text(_book.readingsNumber.toString(), style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 6.0),
                child: Icon(Icons.star, color: TextColorDarkBackground.tertiary),
              ),
              Text(_book.rating.toString(), style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.attach_money, color: TextColorDarkBackground.tertiary),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(_book.income.toString(), style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold)),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildFloatingButton(
                        icon: Icons.edit,
                        onClick: () {
                          Navigator
                              .of(context)
                              .push(MaterialPageRoute(builder: (context) => new EditMyBookScreen(_bookKey), maintainState: false));
                          print("show edit mode");
                        },
                      ),
                      Image(
                        width: 135.0,
                        height: 180.0,
                        image: NetworkImage(_book.remoteCoverUri),
                      ),
                      _buildFloatingButton(
                        icon: Icons.chat_bubble_outline,
                        onClick: () {
                          print("show opinions");
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: _bookInfoCard(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildFloatingButton({@required IconData icon, @required Function onClick}) {
    return OutlineButton(
      onPressed: onClick,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
          color: TextColorDarkBackground.secondary,
        ),
      ),
      highlightColor: AppThemeColors.primaryColorLight,
      color: AppThemeColors.primaryColorLight,
      shape: CircleBorder(),
      borderSide: BorderSide(
        color: AppThemeColors.primaryColorLight,
        width: 2.0,
      ),
    );
  }
}
