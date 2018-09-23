import 'package:cronicalia_flutter/book_read_screen/selected_book_screen.dart';
import 'package:cronicalia_flutter/custom_widgets/book_stats_widget.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book_pdf.dart';
import 'package:cronicalia_flutter/utils/utility_book.dart';
import 'package:flutter/material.dart';

class RecommendeBooksByGenreWidget extends StatelessWidget {
  RecommendeBooksByGenreWidget({@required this.recommendedBooks, @required this.currentGenre});

  final List<BookPdf> recommendedBooks;
  final BookGenre currentGenre;

  static const double _BOX_HEIGHT = 200.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Text(
            UtilityBook.convertGenreToString(currentGenre).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppThemeColors.accentColor,
            ),
          ),
        ),
        SizedBox(
          height: _BOX_HEIGHT,
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

  Widget _buildBookPreview(BuildContext context, BookPdf book) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => SelectedBookScreen(book),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.all(8.0),
          child: _buildBookFaceWithText(context, book),
        ),
      ),
    );
  }

  Widget _buildBookFaceWithText(BuildContext context, BookPdf book) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 140.0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topRight: Radius.circular(4.0), bottomRight: Radius.circular(4.0)),
              child: Image.network(
                book.remoteCoverUri,
                fit: BoxFit.fill,
                height: _BOX_HEIGHT,
              ),
            ),
          ),
        ),
        Expanded(
          flex: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0, right: 8.0),
                child: Text(
                  book.title,
                  style: TextStyle(color: TextColorDarkBackground.primary, fontWeight: FontWeight.w500, fontSize: 18.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                child: Text(
                  "By ${book.authorName}",
                  style: TextStyle(color: TextColorDarkBackground.secondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  book.synopsis,
                  style: TextStyle(color: TextColorDarkBackground.secondary, fontSize: 12.0),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),
              _buildBookStats(book),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookStats(BookPdf book) {
    return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
        child: BookStatsWidget(
          readingsNumber: book.readingsNumber,
          rating: book.rating,
          income: book.income,
        ));
  }
}
