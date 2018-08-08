import 'dart:async';
import 'dart:math';

import 'package:cronicalia_flutter/custom_widgets/book_file_widget.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/my_books_screen/my_book_image_picker.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:documents_picker/documents_picker.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_flux/flutter_flux.dart';

enum ImageType { POSTER, COVER }
enum ImageOrigin { CAMERA, GALLERY }

class EditMyBookScreen extends StatefulWidget {
  final String bookUID;

  EditMyBookScreen(this.bookUID);

  @override
  State createState() {
    return new EditMyBookScreenState();
  }
}

class EditMyBookScreenState extends State<EditMyBookScreen>
    with TickerProviderStateMixin, StoreWatcherMixin<EditMyBookScreen>
    implements UserInputCallback {
  UserStore _userStore;
  bool _isEditModeOn = false;
  Book _book;
  AnimationController _wiggleController;
  Animation<double> _wiggleAnimation;
  TextEditingController _textController;
  ScrollController _scrollController;

  @override
  void initState() {
    _textController = new TextEditingController();
    _scrollController = new ScrollController();
    _userStore = listenToStore(userStoreToken);

    _book = _userStore.user.books[widget.bookUID];
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
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: _buildPersistentButtons(context),
      body: new Stack(children: [
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
        Center(
          child: SingleChildScrollView(
            padding: new EdgeInsets.only(top: 125.0, bottom: 16.0),
            child: new Column(
              children: <Widget>[
                new Stack(
                  children: [
                    _buildBookInfoCard(),
                    _coverPicture(),
                  ],
                ),
                _buildCompletionStatusButton(),
                _buildPeriodicityDropdownButton(),
                _buildFilesListCard(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  final List<String> _newFilePaths = List<String>();
  final List<String> _newFileTitles = List<String>();

  List<Widget> _buildPersistentButtons(BuildContext context) {
    return <Widget>[
      FlatButton(
        textColor: TextColorDarkBackground.secondary,
        child: Text("ADD FILE"),
        onPressed: () {
          
        },
      ),
      FlatButton(
        child: Text("SAVE"),
        onPressed: () {
          if (_validateInformation()) {
            
          }
        },
      ),
    ];
  }

  bool _validateInformation() {
    return (_validateNewChapterTitles());
  }

  bool _validateNewChapterTitles() {
    for (var counter = 0; counter < _newFileTitles.length; counter++) {
      String title = _newFileTitles[counter];
      if (title == null || title.isEmpty) {
        FlushbarHelper
            .createError(
                title: "Title error",
                message: "Your chapter title number ${counter + 1} is missing",
                duration: Duration(seconds: 3))
            .show(context);
        return false;
      }
    }

    return true;
  }

  Future<List<String>> _getPdfPaths() async {
    List<dynamic> documentPaths = await DocumentsPicker.pickDocuments;

    return documentPaths.map((dynamic path) {
      return path.toString();
    }).toList();
  }

  Widget _buildBookInfoCard() {
    return Card(
      child: new FractionallySizedBox(
        widthFactor: 0.90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildEditButton(
                buttonTitle: "CHANGE POSTER",
                onClick: () {
                  _showImageOriginDialog(ImageType.POSTER);
                },
                padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 16.0)),
            _buildEditButton(
                buttonTitle: "CHANGE COVER",
                onClick: () {
                  _showImageOriginDialog(ImageType.COVER);
                }),
            _buildEditButton(
              buttonTitle: "CHANGE TEXTS",
              onClick: () {
                _isEditModeOn = !_isEditModeOn;
                if (_isEditModeOn) {
                  _wiggleController.forward();
                }
              },
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
    );
  }

  Widget _buildEditButton(
      {@required String buttonTitle,
      @required Function onClick,
      EdgeInsets padding = const EdgeInsets.only(left: 8.0, right: 16.0)}) {
    return new Align(
      alignment: Alignment.centerRight,
      child: new Padding(
        padding: padding,
        child: ButtonTheme(
          minWidth: 130.0,
          child: OutlineButton(
            child: Text(
              buttonTitle,
              style: TextStyle(fontSize: 12.0),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            onPressed: onClick,
            textColor: AppThemeColors.accentColor,
            borderSide: BorderSide(color: Colors.grey[500], width: 1.5),
            highlightColor: Colors.grey[500],
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _coverPicture() {
    return FractionalTranslation(
      translation: Offset(0.15, -0.15),
      child: Container(
        constraints: BoxConstraints.tight(Size(135.0, 180.0)),
        child: Image(
          image: MyBookImagePicker.getProfileImageProvider(_book.localCoverUri, _book.remoteCoverUri),
        ),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0.5, 1.0), blurRadius: 2.0, spreadRadius: 2.0)],
          border: Border.all(style: BorderStyle.solid, color: Colors.white, width: 1.0),
          shape: BoxShape.rectangle,
        ),
      ),
    );
  }

  Widget _buildCompletionStatusButton() {
    return AnimatedSize(
      vsync: this,
      curve: Curves.bounceOut,
      alignment: Alignment.centerLeft,
      duration: Duration(milliseconds: 500),
      child: new FlatButton.icon(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.white, width: 1.0),
        ),
        highlightColor: AppThemeColors.primaryColorLight,
        icon: _book.isCurrentlyComplete ? Icon(Icons.done) : Icon(Icons.build),
        label: _book.isCurrentlyComplete ? Text("Book marked as complete") : Text("Book in development"),
        onPressed: () {
          updateBookCompletionStatusAction([_book.uID, !_book.isCurrentlyComplete]);
        },
      ),
    );
  }

  Widget _buildPeriodicityDropdownButton() {
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: AnimatedCrossFade(
          duration: Duration(milliseconds: 800),
          crossFadeState: _book.isLaunchedComplete ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Container(
            height: 0.0,
            width: 0.0,
          ),
          secondChild: AnimatedOpacity(
            duration: Duration(microseconds: 800),
            opacity: _book.isCurrentlyComplete ? 0.0 : 1.0,
            curve: Curves.easeIn,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Change chapter launch periodicity",
                  style: TextStyle(color: TextColorDarkBackground.secondary),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DropdownButton<ChapterPeriodicity>(
                    style: TextStyle(color: TextColorDarkBackground.secondary),
                    value: _book.periodicity == ChapterPeriodicity.NONE ? null : _book.periodicity,
                    items: ChapterPeriodicity.values
                        .map((ChapterPeriodicity periodicity) {
                          if (periodicity != ChapterPeriodicity.NONE) return _buildPeriodicityDropdownItem(periodicity);
                        })
                        .toList()
                        .sublist(1),
                    hint: Text("Change chapter launch periodicity"),
                    onChanged: (newPeriodicity) {
                      updateBookChapterPeriodicityAction([_book.uID, newPeriodicity]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<ChapterPeriodicity> _buildPeriodicityDropdownItem(ChapterPeriodicity chapterPeriodicity) {
    String periodicityTitle = Book.convertPeriodicityToString(chapterPeriodicity);

    return DropdownMenuItem<ChapterPeriodicity>(
      child: SizedBox(
        child: Text(periodicityTitle),
        width: MediaQuery.of(context).size.width - 64.0,
      ),
      value: chapterPeriodicity,
    );
  }

//TODO implement this correctly after reordering list is ready
  Widget _buildFilesListCard() {
//TODO change by reordering list after flutter feature is ready
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 16.0,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "Book Files",
                style: TextStyle(fontSize: 24.0, color: TextColorBrightBackground.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: new ListView.builder(
                physics: new ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return BookFileWidget(
                    _book.isCurrentlyComplete,
                    _book.remoteChapterUris[index],
                    index,
                    this
                  );
                },
                shrinkWrap: true,
                itemExtent: 118.0,
                itemCount: _book.remoteChapterUris.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onInputReady(String input, int index) {
    // TODO: implement onInputReady
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
        MyBookImagePicker.pickImageFromCamera(imageType, _userStore.user, widget.bookUID);
        break;
      case ImageOrigin.GALLERY:
        MyBookImagePicker.pickImageFromGallery(imageType, _userStore.user, widget.bookUID);
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
      updateBookTitleAction([_book.uID, userInput]);
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
      updateBookSynopsisAction([_book.uID, userInput]);
    }
  }
}
