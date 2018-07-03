import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/custom_widgets/book_file_widget.dart';
import 'package:cronicalia_flutter/custom_widgets/my_book_widget.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/my_books_screen/edit_my_book_screen.dart';
import 'package:cronicalia_flutter/my_books_screen/my_book_image_picker.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:documents_picker/documents_picker.dart';

import 'package:flutter_flux/flutter_flux.dart';

class CreateMyBookScreen extends StatefulWidget {
  Flushbar _flushbar;

  CreateMyBookScreen(this._flushbar);

  @override
  State createState() {
    return new _CreateMyBookScreenState();
  }
}

class _CreateMyBookScreenState extends State<CreateMyBookScreen>
    implements UserInputCallback {
  final Book _book = Book(isLaunchedComplete: true);
  final Set<dynamic> _filePaths = Set<dynamic>();
  final List<String> _fileTitles = List<String>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _titleController = new TextEditingController();
  final TextEditingController _synopsisController = new TextEditingController();

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new book"),
      ),
      persistentFooterButtons: _buildPersistentButtons(context),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildImages(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildInputForm(),
            ),
            new RadioListTile<bool>(
              title: const Text('Launch full book'),
              value: true,
              groupValue: _book.isLaunchedComplete,
              onChanged: (bool value) {
                setState(() {
                  _filePaths.clear();
                  _fileTitles.clear();
                  _book.isLaunchedComplete = value;
                  _book.isCurrentlyComplete = value;
                });
              },
            ),
            new RadioListTile<bool>(
              title: const Text('Launch by chapter'),
              value: false,
              groupValue: _book.isLaunchedComplete,
              onChanged: (bool value) {
                setState(() {
                  _filePaths.clear();
                  _fileTitles.clear();
                  _book.isLaunchedComplete = value;
                  _book.isCurrentlyComplete = value;
                });
              },
            ),
            (_filePaths.length == 0)
                ? Container(
                    width: 0.0,
                    height: 0.0,
                  )
                : _buildFilesListCard(),
          ],
        ),
      ),
    );
  }

  @override
  void onInputReady(String input, int index) {
    if (_fileTitles.length < index + 1) {
      _fileTitles.length = (index + 1);
    }
    _fileTitles[index] = input;
  }

  Future<List<dynamic>> _getPdfPaths() async {
    return DocumentsPicker.pickDocuments;
  }

  List<Widget> _buildPersistentButtons(BuildContext context) {
    return <Widget>[
      FlatButton(
        textColor: TextColorDarkBackground.secondary,
        child: Text("ADD FILE"),
        onPressed: () {
          _getPdfPaths().then((paths) {
            if (paths != null && paths.isNotEmpty) {
              if (_book.isLaunchedComplete) {
                _filePaths.clear();
                _filePaths.add(paths[0]);
              } else {
                _filePaths.addAll(paths);
              }
              setState(() {});
              _scrollController.animateTo(MediaQuery.of(context).size.height,
                  duration: Duration(seconds: 2), curve: Curves.decelerate);
            }
          });
        },
      ),
      FlatButton(
        child: Text("CREATE BOOK"),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _book.title = _titleController.value.text;
            _book.synopsis = _synopsisController.value.text;
            //TODO delete temporary pic files
            //TODO save book
            print("Book saved on database");
          }
        },
      ),
    ];
  }

  Widget _buildImages() {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            _showImageOriginDialog(ImageType.POSTER);
          },
          child: (_book.localPosterUri != null)
              ? Image.file(
                  File(_book.localPosterUri),
                  width: MediaQuery.of(context).size.width,
                  height: 250.0,
                )
              : Image.asset(
                  "images/poster_placeholder.png",
                  width: MediaQuery.of(context).size.width,
                  height: 250.0,
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 104.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                _showImageOriginDialog(ImageType.COVER);
              },
              child: (_book.localCoverUri != null)
                  ? Image.file(
                      File(_book.localCoverUri),
                      width: 135.0,
                      height: 180.0,
                    )
                  : Image.asset(
                      "images/cover_placeholder.png",
                      width: 135.0,
                      height: 180.0,
                    ),
            ),
          ),
        ),
      ],
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
        MyBookImagePicker
            .pickImageFromCameraForNewBook(imageType)
            .then((filePath) {
          if (filePath != null) {
            if (imageType == ImageType.POSTER) {
              setState(() {
                _book.localPosterUri = filePath;
              });
            } else {
              setState(() {
                _book.localCoverUri = filePath;
              });
            }
          }
        });
        break;
      case ImageOrigin.GALLERY:
        MyBookImagePicker
            .pickImageFromGalleryForNewBook(imageType)
            .then((filePath) {
          if (filePath != null) {
            if (imageType == ImageType.POSTER) {
              setState(() {
                _book.localPosterUri = filePath;
              });
            } else {
              setState(() {
                _book.localCoverUri = filePath;
              });
            }
          }
        });
        break;
    }
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _titleController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Your title is empty';
                } else if (value.length > Constants.MAX_TITLE_LENGTH) {
                  return 'Your title is too long';
                }
              },
              maxLength: Constants.MAX_TITLE_LENGTH,
              maxLines: 1,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                  fillColor: Colors.black26,
                  filled: true,
                  icon: Icon(
                    Icons.title,
                    color: Colors.grey[500],
                  ),
                  border: UnderlineInputBorder(),
                  labelText: "Book Title",
                  labelStyle: TextStyle(color: Colors.grey)),
              onFieldSubmitted: (value) {
                _book.title = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _synopsisController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Your synopsis is empty';
                } else if (value.length < Constants.MIN_SYNOPSIS_LENGTH) {
                  return '100 characters minimum';
                } else if (value.length > Constants.MAX_SYNOPSIS_LENGTH) {
                  return '3000 characters maximum';
                }
              },
              maxLength: Constants.MAX_SYNOPSIS_LENGTH,
              maxLines: 7,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                  fillColor: Colors.black26,
                  filled: true,
                  icon: Icon(
                    Icons.short_text,
                    color: Colors.grey[500],
                  ),
                  border: UnderlineInputBorder(),
                  labelText: "Book Synopsis",
                  labelStyle: TextStyle(color: Colors.grey)),
              onFieldSubmitted: (value) {
                _book.synopsis = value;
              },
            ),
          ),
        ],
      ),
    );
  }

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
                style: TextStyle(
                    fontSize: 24.0, color: TextColorBrightBackground.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: new ListView.builder(
                physics: new ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return BookFileWidget(_book.isLaunchedComplete,
                      _filePaths.elementAt(index), index, this);
                },
                shrinkWrap: true,
                itemExtent: 110.0,
                itemCount: _filePaths.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
