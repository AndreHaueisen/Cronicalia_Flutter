import 'dart:async';
import 'dart:math';

import 'package:cronicalia_flutter/custom_widgets/outsider_button_widget.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/my_books_screen/my_book_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_flux/flutter_flux.dart';

enum ImageType { POSTER, COVER }
enum ImageOrigin { CAMERA, GALLERY }

class EditMyBookScreen extends StatefulWidget {
  String bookKey;
  
  EditMyBookScreen(this.bookKey);

  @override
  State createState() {
    return new EditMyBookScreenState();
  }
}

class EditMyBookScreenState extends State<EditMyBookScreen>
    with TickerProviderStateMixin, StoreWatcherMixin<EditMyBookScreen> {
  UserStore _userStore;
  bool _isEditModeOn = false;
  Book _book;
  AnimationController _wiggleController;
  Animation<double> _wiggleAnimation;
  TextEditingController _textController;

  @override
  void initState() {
    _textController = new TextEditingController();
    _userStore = listenToStore(userStoreToken);

    _book = _userStore.user.books[widget.bookKey];
    _wiggleController = new AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _wiggleAnimation = new Tween(begin: -pi / 60, end: pi / 60).animate(_wiggleController)
      ..addListener(() {
        setState(() {});
      });

    _wiggleController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          {
            if (_isEditModeOn) {
              _wiggleController.reverse();
            } else {
              _wiggleController.reset();
            }
            break;
          }
        case AnimationStatus.dismissed:
          {
            if (_isEditModeOn) {
              _wiggleController.forward();
            } else {
              _wiggleController.reset();
            }
            break;
          }
        default:
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(children: [
      new Container(
        height: double.infinity,
        child: Image(
          image: MyBookImagePicker.getPosterImageProvider(_book.localPosterUri, _book.remotePosterUri),
          alignment: Alignment.topCenter,
        ),
        foregroundDecoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppThemeColors.primaryColor, AppThemeColors.canvasColor],
          ),
        ),
      ),
      new Center(
        child: new SingleChildScrollView(
          padding: new EdgeInsets.only(top: 125.0, bottom: 16.0),
          child: new Stack(children: [
            Card(
              child: new FractionallySizedBox(
                widthFactor: 0.90,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Align(
                      child: new Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                        child: MaterialButton(
                          minWidth: 140.0,
                          child: Text(
                            "CHANGE POSTER",
                            style: TextStyle(fontSize: 13.0),
                          ),
                          onPressed: () {
                            _showImageOriginDialog(ImageType.POSTER);
                          },
                          textColor: Theme.of(context).accentTextTheme.button.color,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                    ),
                    new Align(
                      child: new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          minWidth: 140.0,
                          child: Text(
                            "CHANGE COVER",
                            style: TextStyle(fontSize: 13.0),
                          ),
                          onPressed: () {
                            _showImageOriginDialog(ImageType.COVER);
                          },
                          textColor: Theme.of(context).accentTextTheme.button.color,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: new GestureDetector(
                        onTap: () {
                          if (_isEditModeOn) {
                            _showTitleTextInputDialog();
                            _isEditModeOn = false;
                          }
                        },
                        child: new Transform.rotate(
                          angle: (_isEditModeOn == true) ? _wiggleAnimation.value : 0.0,
                          child: new Text(
                            _book.title,
                            style: TextStyle(fontSize: 24.0),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                      child: new GestureDetector(
                        onTap: () {
                          if (_isEditModeOn) {
                            _showSynopsisTextInputDialog();
                            _isEditModeOn = false;
                          }
                        },
                        child: new Transform.rotate(
                          angle: (_isEditModeOn == true) ? _wiggleAnimation.value : 0.0,
                          child: new Text(
                            _book.synopsis,
                            style: TextStyle(color: TextColorDarkBackground.secondary),
                            textAlign: TextAlign.justify,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 8,
                          ),
                        ),
                      ),
                    ),
                    _bookStatsWidget(context)
                  ],
                ),
              ),
            ),
            _coverPicture(),
            _outsiderButton(context),
          ]),
        ),
      ),
    ]);
  }

  Widget _coverPicture() {
    return FractionalTranslation(
      translation: Offset(0.15, -0.50),
      child: Container(
        constraints: BoxConstraints.tight(Size(135.0, 180.0)),
        child: Image(
          image: MyBookImagePicker.getProfileImageProvider(_book.localCoverUri, _book.remoteCoverUri),
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black26, offset: Offset(0.5, 1.0), blurRadius: 2.0, spreadRadius: 2.0)
          ],
          border: Border.all(style: BorderStyle.solid, color: Colors.white, width: 1.0),
          shape: BoxShape.rectangle,
        ),
      ),
    );
  }

  Future<Null> _showImageOriginDialog(ImageType imageType) async {
    switch (await showDialog<ImageOrigin>(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: const Text('Select image from?'),
            children: <Widget>[
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageOrigin.CAMERA);
                },
                child: const Text('CAMERA'),
              ),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageOrigin.GALLERY);
                },
                child: const Text('GALLERY'),
              ),
            ],
          );
        })) {
      case ImageOrigin.CAMERA:
        MyBookImagePicker.pickImageFromCamera(imageType, _userStore.user, widget.bookKey, _book.uID);
        break;
      case ImageOrigin.GALLERY:
        MyBookImagePicker.pickImageFromGallery(imageType, _userStore.user, widget.bookKey, _book.uID);
        break;
    }
  }

  Widget _bookStatsWidget(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.remove_red_eye),
              ),
              Text(
                _book.readingsNumber.toString(),
                style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16.0),
              ),
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.star),
              ),
              Text(
                _book.rating.toString(),
                style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16.0),
              ),
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
                child: Icon(Icons.attach_money),
              ),
              new Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  _book.income.toString(),
                  style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16.0),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<Null> _showTitleTextInputDialog() async {
    _textController.text = _book.title;

    const Text title = Text(
      "Edit book title",
      style: const TextStyle(fontSize: 20.0),
    );
    TextFormField textFormField = TextFormField(
      controller: _textController,
      maxLength: 40,
      maxLengthEnforced: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: "Book title", helperText: "3 characters minimum"),
      onFieldSubmitted: (value) {
        if (value.length >= 3) {
          Navigator.pop(context, value);
        }
      },
    );

    String userInput = (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: title,
                ),
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: textFormField,
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("CANCEL"),
                        textColor: AppThemeColors.accentColor,
                      ),
                      new FlatButton(
                        onPressed: () {
                          if (_textController.text.length >= 3) {
                            Navigator.pop(context, _textController.text);
                          }
                        },
                        child: Text("SUBMIT"),
                        textColor: AppThemeColors.accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }));

    if (userInput != null && userInput.length >= 3) {
      updateBookTitleAction([_book.generateBookKey(), userInput]);
    }
  }

  Future<Null> _showSynopsisTextInputDialog() async {
    _textController.text = _book.synopsis;

    const Text title = Text(
      "Edit book synopsis",
      style: const TextStyle(fontSize: 20.0),
    );
    TextFormField textFormField = TextFormField(
      controller: _textController,
      maxLines: 8,
      maxLength: 3000,
      maxLengthEnforced: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: "Book synopsis"),
      onFieldSubmitted: (value) {
        if (value.length <= 3000) {
          Navigator.pop(context, value);
        }
      },
    );

    String userInput = (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new SingleChildScrollView(
            child: new Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: title,
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: textFormField,
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("CANCEL"),
                          textColor: AppThemeColors.accentColor,
                        ),
                        new FlatButton(
                          onPressed: () {
                            if (_textController.text.length <= 3000) {
                              Navigator.pop(context, _textController.text);
                            }
                          },
                          child: Text("SUBMIT"),
                          textColor: AppThemeColors.accentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }));

    if (userInput != null) {
      updateBookSynopsisAction([_book.generateBookKey(), userInput]);
    }
  }

  Widget _outsiderButton(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(2.7, -0.8),
      child: new OutsiderButton(
        icon: Icon(Icons.mode_edit),
        onPressed: () {
          _isEditModeOn = !_isEditModeOn;
          if (_isEditModeOn) {
            _wiggleController.forward();
          }
        },
      ),
    );
  }
}
