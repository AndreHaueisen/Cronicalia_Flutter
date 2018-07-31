import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/custom_widgets/book_file_widget.dart';
import 'package:cronicalia_flutter/flux/user_store.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/my_books_screen/edit_my_book_screen.dart';
import 'package:cronicalia_flutter/my_books_screen/my_book_image_picker.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:documents_picker/documents_picker.dart';

import 'package:flutter_flux/flutter_flux.dart';

class CreateMyBookScreen extends StatefulWidget {
  CreateMyBookScreen();

  @override
  State createState() {
    return new _CreateMyBookScreenState();
  }
}

class _CreateMyBookScreenState extends State<CreateMyBookScreen> with StoreWatcherMixin<CreateMyBookScreen> implements UserInputCallback {
  final Book _book = Book();
  final List<String> _filePaths = List<String>();
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
            _buildInputForm(),
            _buildFullBookRadioButton(),
            _buildIncompleteBookRadioButton(),
            _buildPeriodicityDropdownButton(),
            _buildGenreDropdownButton(),
            _buildLanguageDropdownButton(),
            _buildResumePhrase(),
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

  Future<List<String>> _getPdfPaths() async {
    List<dynamic> documentPaths = await DocumentsPicker.pickDocuments;

    return documentPaths.map((dynamic path) {
      return path.toString();
    }).toList();
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
              _scrollController.animateTo(MediaQuery.of(context).size.height, duration: Duration(seconds: 2), curve: Curves.decelerate);
            }
          });
        },
      ),
      FlatButton(
        child: Text("CREATE BOOK"),
        onPressed: () {
          if (_validateInformation()) {
            UserStore userStore = listenToStore(userStoreToken);
            _book.authorName = userStore.user.name;
            _book.authorEmailId = userStore.user.encodedEmail;
            _book.authorTwitterProfile = userStore.user.twitterProfile;
            _book.publicationDate = DateTime.now().millisecondsSinceEpoch;
            _book.bookPosition = userStore.user.books.length;

            if (_book.isLaunchedComplete) {
              _book.localFullBookUri = _filePaths[0];
              createCompleteBookAction(_book);
            } else {
              _filePaths.forEach((_) {
                _book.chaptersLaunchDates.add(_book.publicationDate);
              });
              _fileTitles.forEach((String fileTitle) {
                _book.remoteChapterTitles.add(fileTitle);
              });
              createIncompleteBookAction([_book, _filePaths, _fileTitles]);
            }
            _showProgressFlushbar();
            print("Uploading book data");
          }
        },
      ),
    ];
  }

  void _showProgressFlushbar() {
    UserStore userStore = listenToStore(userStoreToken);

    Flushbar progressFlushbar = FlushbarHelper.createLoading(
      title: "Uploading files",
      message: "Wait while we create your new masterpiece",
      linearProgressIndicator: LinearProgressIndicator(
        backgroundColor: AppThemeColors.primaryColorDark,
      ),
      duration: null,
    )
      ..onStatusChanged = (FlushbarStatus status) {
        switch (status) {
          case FlushbarStatus.DISMISSED:
            {
              Navigator.of(context).pop();
              break;
            }
          default:
            {}
        }
      }
      ..show(context);

    if (userStore.getProgressStream() != null) {
      userStore.getProgressStream().controller.stream.listen((progress) {}, onDone: () {
        progressFlushbar.dismiss();
      }, onError: (error) {
        FlushbarHelper.createError(title: "Upload failed", message: "One or more files failed. Try again");
      }, cancelOnError: true);
    }
  }

  bool _validateInformation() {
    return (_validatePoster() &&
        _validateCover() &&
        _validateInputForm() &&
        _validateGenre() &&
        _validateLanguage() &&
        _validatePeriodicity() &&
        _validateFiles());
  }

  bool _validatePoster() {
    if (_book.localPosterUri != null) {
      return true;
    } else {
      FlushbarHelper
          .createError(
            title: "Poster missing",
            message: "Choose a book poster to attract readers",
            duration: (Duration(seconds: 3)),
          )
          .show(context);
      return false;
    }
  }

  bool _validateCover() {
    if (_book.localCoverUri != null) {
      return true;
    } else {
      FlushbarHelper
          .createError(
            title: "Cover missing",
            message: "Choose a book cover to attract readers",
            duration: (Duration(seconds: 3)),
          )
          .show(context);
      return false;
    }
  }

  bool _validateInputForm() {
    if (_formKey.currentState.validate()) {
      _book.title = _titleController.value.text;
      _book.synopsis = _synopsisController.value.text;
      return true;
    } else {
      setState(() {
        _isAutoValidating = true;
      });
      FlushbarHelper
          .createError(
            title: "Title or synopsis invalid",
            message: "Check your book title and synopsis",
            duration: (Duration(seconds: 3)),
          )
          .show(context);
      return false;
    }
  }

  bool _validateFiles() {
    if (_filePaths.length > 0) {
      return true;
    } else {
      FlushbarHelper
          .createError(
            title: "File missing",
            message: "Choose at least one PDF for your book",
            duration: (Duration(seconds: 3)),
          )
          .show(context);
      return false;
    }
  }

  bool _validateGenre() {
    if (_book.genre != null && _book.genre != BookGenre.UNDEFINED) {
      return true;
    } else {
      FlushbarHelper
          .createError(
            title: "Genre missing",
            message: "What is your book's genre?",
            duration: (Duration(seconds: 3)),
          )
          .show(context);
      return false;
    }
  }

  bool _validateLanguage() {
    if (_book.language != null && _book.language != BookLanguage.UNDEFINED) {
      return true;
    } else {
      FlushbarHelper
          .createError(
            title: "Language missing",
            message: "In what language your book is written?",
            duration: (Duration(seconds: 3)),
          )
          .show(context);
      return false;
    }
  }

  bool _validatePeriodicity() {
    if (_book.isLaunchedComplete) return true;

    if ((_book.periodicity != null && _book.periodicity != ChapterPeriodicity.NONE)) {
      return true;
    } else {
      FlushbarHelper
          .createError(
            title: "Chapter launch schedule missing",
            message: "What is the interval between your chapter launches?",
            duration: (Duration(seconds: 3)),
          )
          .show(context);
      return false;
    }
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
        MyBookImagePicker.pickImageFromCameraForNewBook(imageType).then((filePath) {
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
        MyBookImagePicker.pickImageFromGalleryForNewBook(imageType).then((filePath) {
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

  bool _isAutoValidating = false;

  Widget _buildInputForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        autovalidate: _isAutoValidating,
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
      ),
    );
  }

  Widget _buildFullBookRadioButton() {
    return new RadioListTile<bool>(
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
    );
  }

  Widget _buildIncompleteBookRadioButton() {
    return new RadioListTile<bool>(
      title: const Text('Launch by chapter'),
      value: false,
      groupValue: _book.isLaunchedComplete,
      onChanged: (bool value) {
        setState(() {
          _filePaths.clear();
          _fileTitles.clear();
          _book.isLaunchedComplete = value;
          _book.isCurrentlyComplete = value;
          if (value == true) {
            _book.periodicity = ChapterPeriodicity.NONE;
          }
        });
      },
    );
  }

  Widget _buildPeriodicityDropdownButton() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 800),
      crossFadeState: _book.isLaunchedComplete ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Container(
        height: 0.0,
        width: 0.0,
      ),
      secondChild: AnimatedOpacity(
        duration: Duration(microseconds: 800),
        opacity: _book.isLaunchedComplete ? 0.0 : 1.0,
        curve: Curves.easeIn,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: DropdownButton<ChapterPeriodicity>(
            value: _book.periodicity == ChapterPeriodicity.NONE ? null : _book.periodicity,
            items: ChapterPeriodicity.values
                .map((ChapterPeriodicity periodicity) {
                  if (periodicity != ChapterPeriodicity.NONE) return _buildPeriodicityDropdownItem(periodicity);
                })
                .toList()
                .sublist(1),
            hint: Text("Choose chapter launch periodicity"),
            onChanged: (value) {
              setState(() {
                _book.periodicity = value;
              });
            },
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

  Widget _buildGenreDropdownButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DropdownButton(
        value: _book.genre == BookGenre.UNDEFINED ? null : _book.genre,
        items: BookGenre.values
            .map((BookGenre genre) {
              if (genre != BookGenre.UNDEFINED) return _buildGenreDropdownItem(genre);
            })
            .toList()
            .sublist(1),
        hint: Text("Choose the genre"),
        onChanged: (value) {
          setState(() {
            _book.genre = value;
          });
        },
      ),
    );
  }

  DropdownMenuItem<BookGenre> _buildGenreDropdownItem(BookGenre genre) {
    String genreTitle = Book.convertGenreToString(genre);

    return DropdownMenuItem<BookGenre>(
      child: SizedBox(
        child: Text(genreTitle),
        width: MediaQuery.of(context).size.width - 64.0,
      ),
      value: genre,
    );
  }

  Widget _buildLanguageDropdownButton() {
    return DropdownButton(
      value: _book.language == BookLanguage.UNDEFINED ? null : _book.language,
      items: BookLanguage.values
          .map((BookLanguage language) {
            if (language != BookLanguage.UNDEFINED) return _buildLanguageDropdownItem(language);
          })
          .toList()
          .sublist(1),
      hint: Text("Choose language"),
      onChanged: (value) {
        setState(() {
          _book.language = value;
        });
      },
    );
  }

  DropdownMenuItem<BookLanguage> _buildLanguageDropdownItem(BookLanguage language) {
    String languageTitle = Book.convertLanguageToString(language);

    return DropdownMenuItem<BookLanguage>(
      child: SizedBox(
        child: Text(languageTitle),
        width: MediaQuery.of(context).size.width - 64.0,
      ),
      value: language,
    );
  }

  String _resumePhrase = "";

  Widget _buildResumePhrase() {
    String completionStatusSubstring =
        _book.isLaunchedComplete ? "You are launching a complete book. " : "You are launching an incomplete book. ";
    String genreStatusSubstring =
        _book.genre == BookGenre.UNDEFINED ? "" : "It is a(n) ${Book.convertGenreToString(_book.genre).toLowerCase()}. ";
    String languageStatusSubstring =
        _book.language == BookLanguage.UNDEFINED ? "" : "It is written in ${Book.convertLanguageToString(_book.language).toLowerCase()}. ";
    String chapterNumberSubstring = _book.isLaunchedComplete ? "" : "It has ${_filePaths.length} chapter(s). ";
    String periodicityStatusSubstring =
        (_book.isLaunchedComplete || (!_book.isLaunchedComplete && _book.periodicity == ChapterPeriodicity.NONE))
            ? ""
            : "You intend to launch a new chapter ${Book.convertPeriodicityToString(_book.periodicity).toLowerCase()}. ";

    _resumePhrase =
        completionStatusSubstring + genreStatusSubstring + languageStatusSubstring + chapterNumberSubstring + periodicityStatusSubstring;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0, right: 16.0, left: 16.0),
      child: Text(_resumePhrase),
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
                style: TextStyle(fontSize: 24.0, color: TextColorBrightBackground.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: new ListView.builder(
                physics: new ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return BookFileWidget(_book.isLaunchedComplete, _filePaths[index], index, this);
                },
                shrinkWrap: true,
                itemExtent: 118.0,
                itemCount: _filePaths.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
