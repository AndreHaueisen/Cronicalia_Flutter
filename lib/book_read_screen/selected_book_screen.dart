import 'package:cronicalia_flutter/book_read_screen/book_read_screen.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:flutter/material.dart';

class SelectedBookScreen extends StatelessWidget {
  SelectedBookScreen(this._book);

  final Book _book;

  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: new Stack(children: [
        Image(
          image: NetworkImage(_book.remotePosterUri),
          alignment: Alignment.topCenter,
          fit: BoxFit.fill,
          color: currentOrientation == Orientation.portrait ? null : const Color(0xBB000000),
          colorBlendMode: BlendMode.darken,
          width: MediaQuery.of(context).size.width,
          height: currentOrientation == Orientation.portrait ? 200.0 : MediaQuery.of(context).size.height,
        ),
        _coverPicture(currentOrientation),
        Center(
          child: SingleChildScrollView(
            padding: new EdgeInsets.only(top: 220.0, bottom: 50.0),
            child: new Column(
              children: <Widget>[
                new Stack(
                  children: [
                    _buildBookInfoCard(),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _buildPersistentButton(context)),
      ]),
    );
  }

  Widget _buildPersistentButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 12.0),
      child: RaisedButton(
        textColor: TextColorBrightBackground.primary,
        child: Text("READ"),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => BookReadScreen(_book),
            ),
          );
        },
        color: AppThemeColors.accentColor,
      ),
    );
  }

  Widget _coverPicture(Orientation currentOrientation) {
    return Center(
      child: FractionalTranslation(
        translation: Offset(0.0, currentOrientation == Orientation.portrait ? -0.60 : -0.20),
        child: Container(
          constraints: BoxConstraints.tight(Size(135.0, 180.0)),
          child: Image(
            image: NetworkImage(_book.remoteCoverUri),
            fit: BoxFit.fill,
          ),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black, offset: Offset(0.25, 0.25), blurRadius: 8.0, spreadRadius: 0.0)],
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfoCard() {
    return new FractionallySizedBox(
      widthFactor: 0.95,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
            child: new Text(
              _book.title,
              style: TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: new Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: new Text(
                "By ${_book.authorName}",
                style: TextStyle(color: TextColorDarkBackground.secondary),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: new Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
              child: new Text(
                _book.authorTwitterProfile,
                style: TextStyle(color: TextColorDarkBackground.secondary),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
            child: new Text(
              _book.synopsis,
              style: TextStyle(color: TextColorDarkBackground.secondary),
              textAlign: TextAlign.justify,
              overflow: TextOverflow.ellipsis,
              maxLines: 8,
            ),
          ),
          _bookStatsWidget()
        ],
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
                child: Icon(
                  Icons.remove_red_eye,
                  color: TextColorDarkBackground.tertiary,
                ),
              ),
              Text(_book.readingsNumber.toString(),
                  style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 6.0),
                child: Icon(Icons.star, color: TextColorDarkBackground.tertiary),
              ),
              Text(_book.rating.toString(),
                  style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.attach_money, color: TextColorDarkBackground.tertiary),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(_book.income.toString(),
                    style: TextStyle(color: TextColorDarkBackground.secondary, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }
}
