import 'package:cronicalia_flutter/book_read_screen/book_read_screen.dart';
import 'package:cronicalia_flutter/custom_widgets/book_stats_widget.dart';
import 'package:cronicalia_flutter/custom_widgets/rounded_button_widget.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book_pdf.dart';
import 'package:flutter/material.dart';

class SelectedBookScreen extends StatefulWidget {
  SelectedBookScreen(this._book);

  final BookPdf _book;

  @override
  _SelectedBookScreenState createState() => _SelectedBookScreenState();
}

class _SelectedBookScreenState extends State<SelectedBookScreen> with SingleTickerProviderStateMixin {
  Orientation _currentOrientation;
  double _coverPictureHeight;

  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _currentOrientation = MediaQuery.of(context).orientation;
    _coverPictureHeight = _currentOrientation == Orientation.portrait ? 200.0 : MediaQuery.of(context).size.height;

    return Scaffold(
      body: _buildBookInfoFront(context),
    );
  }

  Widget _buildBookInfoFront(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildCoverPicture(),
          _buildPanelSwitch(),
          _buildPanels(context),
        ],
      ),
    );
  }

  Widget _buildCoverPicture() {
    return Padding(
      padding: EdgeInsets.only(top: (_coverPictureHeight - 125.0)),
      child: Container(
        constraints: BoxConstraints.tight(Size(135.0, 180.0)),
        child: Image(
          image: NetworkImage(widget._book.remoteCoverUri),
          fit: BoxFit.fill,
        ),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black, offset: Offset(0.25, 0.25), blurRadius: 8.0, spreadRadius: 0.0)],
        ),
      ),
    );
  }

  Widget _buildPanelSwitch() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 1.0,
          indicatorColor: TextColorDarkBackground.secondary,
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.info_outline,
                color: TextColorDarkBackground.secondary,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.comment,
                color: TextColorDarkBackground.secondary,
              ),
            ),
          ],
        ),
        Divider(
          color: TextColorDarkBackground.tertiary,
          height: 0.0,
        ),
      ]),
    );
  }

  Widget _buildPanels(BuildContext context) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[_buildBookBasicInfoPanel(), Icon(Icons.cloud_circle)],
      ),
    );
  }

  Widget _buildBookBasicInfoPanel() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: new Text(
                  widget._book.title,
                  style: TextStyle(fontSize: 24.0),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: new Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new Text(
                    "By ${widget._book.authorName}",
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
                  padding: const EdgeInsets.only(top: 4.0),
                  child: new Text(
                    widget._book.authorTwitterProfile,
                    style: TextStyle(color: TextColorDarkBackground.secondary),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: new Text(
                  widget._book.synopsis,
                  style: TextStyle(color: TextColorDarkBackground.secondary),
                  textAlign: TextAlign.justify,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 8,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 64.0),
                child: _buildBookStatsWidget(),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _buildReadButton(context),
        ),
      ],
    );
  }

  Widget _buildBookStatsWidget() {
    return BookStatsWidget(
      readingsNumber: widget._book.readingsNumber,
      rating: widget._book.rating,
      income: widget._book.income,
    );
  }

  Widget _buildReadButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RoundedButton(
        elevation: 4.0,
        textColor: TextColorBrightBackground.primary,
        child: Text("READ"),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => BookReadScreen(widget._book),
            ),
          );
        },
        color: AppThemeColors.accentColor,
        highlightColor: Colors.amber[200],
      ),
    );
  }
}
