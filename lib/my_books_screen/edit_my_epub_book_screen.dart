import 'dart:async';
import 'dart:io';

import 'package:cronicalia_flutter/custom_widgets/book_epub_file_widget.dart';
import 'package:cronicalia_flutter/custom_widgets/rounded_button_widget.dart';
import 'package:cronicalia_flutter/main.dart';
import 'package:cronicalia_flutter/models/book.dart';
import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:cronicalia_flutter/utils/custom_flushbar_helper.dart';
import 'package:cronicalia_flutter/utils/epub_parser.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:epub/epub.dart' as epubLib;
import 'package:cronicalia_flutter/flux/user_store.dart';

class EditMyEpubBookScreen extends StatefulWidget {
  final String bookUID;

  EditMyEpubBookScreen(this.bookUID);

  @override
  _EditMyEpubBookScreenState createState() => _EditMyEpubBookScreenState();
}

class _EditMyEpubBookScreenState extends State<EditMyEpubBookScreen>
    with SingleTickerProviderStateMixin, StoreWatcherMixin<EditMyEpubBookScreen> {
  UserStore _userStore;
  BookEpub _book;
  BookEpub _immutableBook;
  String _rawEpubBookPath;


  @override
  void initState() {
    _uploadProgressController = AnimationController(vsync: this, value: 0.0);
    _userStore = listenToStore(userStoreToken);

    _immutableBook = _userStore.user.booksEpub[widget.bookUID];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Epub book"),
      ),
      persistentFooterButtons: _buildPersistentButton(),
      body: _book == null ? _buildSelectEpubWidget() : _buildParsedBookWidget(),
    );
  }

  List<Widget> _buildPersistentButton() {
    return <Widget>[
      FlatButton(
        child: Text("UPDATE BOOK"),
        onPressed: _book != null ?() {
          
          if (_validateInformation()) {
            updateEpubBookAction(_book);

            _showProgressFlushbar();
            print("Uploading Epub book data");
          }
        } : null,
      ),
    ];
  }

  //do not dispose. Flushbar already randles it
  AnimationController _uploadProgressController;

  void _showProgressFlushbar() {
    UserStore userStore = listenToStore(userStoreToken);

    Flushbar progressFlushbar = FlushbarHelper.createLoading(
      message: "Wait while we update your book",
      indicatorBackgroundColor: Colors.blue[300],
      indicatorController: _uploadProgressController,
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
      userStore.getProgressStream().controller.stream.listen((progress) {
        _uploadProgressController.animateTo(progress, duration: Duration(milliseconds: 300));
      }, onDone: () {
        progressFlushbar.dismiss();
      }, onError: (error) {
        FlushbarHelper.createError(title: "Upload failed", message: "Check connection and try again");
      }, cancelOnError: true);
    }
  }

  bool _isEpubBeingAnalized = false;

  Widget _buildSelectEpubWidget() {

    Widget buildReleaseChapterStatusNotification(){
      int _daysUntilNextChapterRelease = _immutableBook.getDaysRemainingForNewChapterPublication();

      if(_daysUntilNextChapterRelease == null) return Container(height: 0.0, width: 0.0,);

      if(_daysUntilNextChapterRelease < 0){
        return Text("Chapter release is ${_daysUntilNextChapterRelease.abs()} day(s) late");
      } else if (_daysUntilNextChapterRelease <= 3){
        return Text("Chapter release in $_daysUntilNextChapterRelease day(s)");
      } else {
        return Text(" $_daysUntilNextChapterRelease days util next chapter release");
      }
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundedButton(
            child: Text(
              "SELECT UPDATED EPUB FILE",
            ),
            onPressed: _isEpubBeingAnalized
                ? null
                : () {
                    setState(() {
                      _isEpubBeingAnalized = true;
                    });

                    _getEpubFile().then((EpubParser epubParser) {
                      setState(() {
                        if (epubParser != null) {
                          _convertEpubBookToBookEpub(epubParser);
                          _isEpubBeingAnalized = false;
                        }
                      });
                    });
                  },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildReleaseChapterStatusNotification(),
          ),
        ],
      ),
    );
  }

  Future<EpubParser> _getEpubFile() async {
    Flushbar loadingBookFlushbar = FlushbarHelper.createInformation(message: "Analysing epub file...", duration: null);
    try {
      loadingBookFlushbar.show(context);

      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
          allowedFileExtensions: ["epub"],
          // allowedMimeType only works on Android. Check for IOS latter
          allowedMimeType: Constants.CONTENT_TYPE_EPUB);

      _rawEpubBookPath = await FlutterDocumentPicker.openDocument(params: params);
      File epubFile = File(_rawEpubBookPath);

      epubLib.EpubBook epubBook = await epubLib.EpubReader.readBook(await epubFile.readAsBytes());

      return EpubParser(epubBook);
    } catch (error) {
      print(error);
      FlushbarHelper.createError(message: "Upload an ePub file").show(context);
      return null;
    } finally {
      loadingBookFlushbar.dismiss().then((_) {
        FlushbarHelper.createSuccess(message: "Book loaded").show(context);
      });
    }
  }

  void _convertEpubBookToBookEpub(EpubParser epubParser) {
    _book = _immutableBook.copy();
    _book.coverData = epubParser.extractImage();
    _book.localFullBookUri = _rawEpubBookPath;
    _book.synopsis = epubParser.extractSynopsis();
    _book.chapterTitles = epubParser.extractChapterTitles();
    _book.chaptersLaunchDates = epubParser.setLaunchDateOfLatestsChapters(oldBook: _immutableBook, newBook: _book);
  }

  Widget _buildParsedBookWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCoverPicture(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            child: Text(_book.title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: _buildSynopsisInput(),
          ),
          _buildPeriodicityDropdownButton(),
          _buildChapterWidgets(),
        ],
      ),
    );
  }

  Widget _buildCoverPicture() {
    return Container(
      constraints: BoxConstraints.tight(Size(Constants.BOOK_COVER_DEFAULT_WIDTH, Constants.BOOK_COVER_DEFAULT_HEIGHT)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: Image.memory(
          _book.coverData,
          height: 160.0,
          width: 120.0,
        ),
      ),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(2.0, 2.0), blurRadius: 6.0, spreadRadius: 1.0)],
        borderRadius: BorderRadius.circular(6.0),
        shape: BoxShape.rectangle,
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _synopsisController = TextEditingController();
  bool _isAutoValidating = false;

  Widget _buildSynopsisInput() {
    _synopsisController.text = _book.synopsis;

    return Form(
      autovalidate: _isAutoValidating,
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
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
            textCapitalization: TextCapitalization.sentences,
            maxLengthEnforced: true,
            decoration: InputDecoration(
                fillColor: Colors.black26,
                filled: true,
                border: UnderlineInputBorder(),
                labelText: "Book Synopsis",
                labelStyle: TextStyle(color: Colors.grey)),
            onFieldSubmitted: (value) {
              _book.synopsis = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChapterWidgets() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Detected Files",
            style: TextStyle(color: TextColorDarkBackground.primary, fontSize: 24.0),
          ),
          SizedBox(
            height: ((_book.chapterTitles.length + 1) * FILE_WIDGET_HEIGHT),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemExtent: FILE_WIDGET_HEIGHT,
              itemCount: _book.chapterTitles.length,
              itemBuilder: (BuildContext listBuildContext, int index) {
                bool isOld = _immutableBook.chapterTitles.contains(_book.chapterTitles[index]);
                return BookEpubFileWidget(chapterTitle: _book.chapterTitles[index], chapterNumber: index, isOld: isOld);
              },
            ),
          )
        ],
      ),
    );
  }

  bool _validateInformation() {
    return (_validateCover() && _validateInputForm() && _validatePeriodicity() && _validateChapterTitles());
  }

  bool _validateCover() {
    if (_book.coverData == null) {
      FlushbarHelper.createError(
        title: "Cover Error",
        message: "We did not find a cover for the book. That is mandatory",
        duration: (Duration(seconds: 3)),
      ).show(context);
      return false;
    } else {
      return true;
    }
  }

  bool _validateInputForm() {
    if (_formKey.currentState.validate()) {
      _book.synopsis = _synopsisController.value.text;
      return true;
    } else {
      setState(() {
        _isAutoValidating = true;
      });
      FlushbarHelper.createError(
        title: "Synopsis invalid",
        message: "Check your book synopsis",
        duration: (Duration(seconds: 3)),
      ).show(context);
      return false;
    }
  }

  bool _validatePeriodicity() {
    if (_book.isSingleLaunch) return true;

    if ((_book.periodicity != null && _book.periodicity != ChapterPeriodicity.NONE)) {
      return true;
    } else {
      FlushbarHelper.createError(
        title: "Chapter launch schedule missing",
        message: "What is the interval between your chapter launches?",
        duration: (Duration(seconds: 3)),
      ).show(context);
      return false;
    }
  }

  bool _validateChapterTitles() {
    if (_book.chapterTitles.length > 0) {
      return true;
    } else {
      FlushbarHelper.createError(
        title: "File error",
        message: "We did not detect any content for you user to read",
        duration: (Duration(seconds: 3)),
      ).show(context);
      return false;
    }
  }

  Widget _buildPeriodicityDropdownButton() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 800),
      crossFadeState: _book.isSingleLaunch ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Container(
        height: 0.0,
        width: 0.0,
      ),
      secondChild: AnimatedOpacity(
        duration: Duration(microseconds: 800),
        opacity: _book.isSingleLaunch ? 0.0 : 1.0,
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

}

const double FILE_WIDGET_HEIGHT = 64.0;
