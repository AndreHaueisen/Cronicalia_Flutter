import 'package:cronicalia_flutter/custom_widgets/book_stats_widget.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/my_books_screen/edit_my_epub_book_screen.dart';

import 'package:cronicalia_flutter/my_books_screen/edit_my_pdf_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyBookWidget extends StatelessWidget {
  final Book _book;
  final String _bookKey;
  final int _index;
  final int _totalBookNumber;

  MyBookWidget(this._book, this._bookKey, this._index, this._totalBookNumber);

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
                  child: _buildLateralButtonsAndCover(context),
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
        height: 233.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
              child: Text(
                _book.title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                ),
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
              alignment: FractionalOffset.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
                child: Text(
                  "Publication  $readableDate",
                  style: TextStyle(fontSize: 12.0, color: TextColorDarkBackground.secondary),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
                child: Text(
                  _book.isCurrentlyComplete ? "Completed" : "Under development",
                  style: TextStyle(fontSize: 12.0, color: TextColorDarkBackground.secondary),
                ),
              ),
            ),
            _book.isSingleLaunch
                ? Container(height: 0.0, width: 0.0)
                : Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                      child: Text(
                        "${_book.chapterTitles.length} chapters",
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
      child: BookStatsWidget(
        readingsNumber: _book.readingsNumber,
        rating: _book.rating,
        income: _book.income,
      ),
    );
  }

  Widget _buildLateralButtonsAndCover(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildNotificationButton(
          notification: _getChaperScheduleNotification(),
          icon: Icons.edit,
          onClick: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => _book is BookPdf ? EditMyPdfBookScreen(_bookKey) : EditMyEpubBookScreen(_bookKey), maintainState: false));
            print("show edit mode");
          },
        ),
        Container(
          constraints: BoxConstraints.tight(Size(135.0, 180.0)),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(2.0, 2.0), blurRadius: 6.0, spreadRadius: 1.0)],
            borderRadius: BorderRadius.circular(6.0),
            shape: BoxShape.rectangle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Image(
              image: NetworkImage(_book.remoteCoverUri),
              fit: BoxFit.fill,
            ),
          ),
        ),
        _buildNotificationButton(
          icon: Icons.chat_bubble_outline,
          //TODO detect new review
          //notification: "New reviews",
          onClick: () {
            print("show opinions");
          },
        ),
      ],
    );
  }

  String _getChaperScheduleNotification() {
    if (_book.isCurrentlyComplete) return null;

    final int dueDateInDays = _book.getDaysRemainingForNewChapterPublication();

    if (dueDateInDays == null || dueDateInDays >= 4) return null;

    if (dueDateInDays <= 0) {
      return "Late chapter";
    } else {
      return "Due in $dueDateInDays days";
    }
  }

  _buildNotificationButton({@required IconData icon, String notification, @required Function onClick}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        notification != null
            ? Container(
              constraints: BoxConstraints.loose(Size(84.0, 36.0)),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: AppThemeColors.accentColor),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    notification,
                    style: TextStyle(color: TextColorBrightBackground.primary, fontSize: 12.0),
                    maxLines: 2,
                  ),
                ),
              )
            : Container(
                height: 0.0,
                width: 0.0,
              ),
        OutlineButton(
      onPressed: onClick,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
              color: notification != null ? AppThemeColors.accentColor : TextColorDarkBackground.secondary,
        ),
      ),
      highlightColor: AppThemeColors.primaryColorLight,
      color: AppThemeColors.primaryColorLight,
      shape: CircleBorder(),
      borderSide: BorderSide(
            color: notification != null ? AppThemeColors.accentColor : TextColorDarkBackground.secondary,
            width: notification != null ? 5.0 : 1.2,
      ),
        )
      ],
    );
  }
}
