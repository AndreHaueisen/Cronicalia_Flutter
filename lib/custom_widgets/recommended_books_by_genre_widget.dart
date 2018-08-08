import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:flutter/material.dart';

class RecommendeBooksByGenreWidget extends StatelessWidget {
  RecommendeBooksByGenreWidget({@required this.recommendedBooks, @required this.currentGenre});

  final List<Book> recommendedBooks;
  final BookGenre currentGenre;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            Book.convertGenreToString(currentGenre).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppThemeColors.accentColor,
            ),
          ),
        ),
        SizedBox(
          height: 190.0,
          child: ListView.builder(
            itemCount: recommendedBooks.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext buildContext, int index) {
              return _buildBookPreview(context, recommendedBooks[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookPreview(BuildContext context, Book book) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: _buildBookFaceWithText(context, book),
      ),
    );
  }

  Widget _buildBookFaceWithText(BuildContext context, Book book) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.network(
              book.remoteCoverUri,
              fit: BoxFit.fill,
              height: 190.0,
            ),
          ),
        ),
        Expanded(
          flex: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0, right: 8.0),
                  child: Text(
                    book.title,
                    style: TextStyle(
                      color: TextColorDarkBackground.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                  child: Text(
                    book.authorName,
                    style: TextStyle(color: TextColorDarkBackground.secondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    book.synopsis,
                    style: TextStyle(
                      color: TextColorDarkBackground.secondary,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  ),
                ),
                _buildBookStats(book),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookStats(Book book) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
              Text(book.readingsNumber.toString(),
                  style: TextStyle(
                    color: TextColorDarkBackground.secondary,
                    fontWeight: FontWeight.bold,
                  ))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 6.0),
                child: Icon(Icons.star, color: TextColorDarkBackground.tertiary),
              ),
              Text(book.rating.toString(),
                  style: TextStyle(
                    color: TextColorDarkBackground.secondary,
                    fontWeight: FontWeight.bold,
                  ))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.attach_money, color: TextColorDarkBackground.tertiary),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Text(book.income.toString(),
                    style: TextStyle(
                      color: TextColorDarkBackground.secondary,
                      fontWeight: FontWeight.bold,
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}
