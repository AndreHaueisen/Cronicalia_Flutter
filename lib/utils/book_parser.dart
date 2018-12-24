import 'dart:io';
import 'dart:typed_data';

import 'package:cronicalia_flutter/models/book.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:epub/epub.dart' as epubLib;

class PdfParser{

  PdfParser(this.book, this._currentPdfBookFiles){
    readChapter(0);
  }

  final BookPdf book;

  List<File> _currentPdfBookFiles;
  List<File> get currentPdfBookFiles => _currentPdfBookFiles;

  int _currentChapterIndex = 0;
  int get currentChapterIndex => _currentChapterIndex;

  String _showingFilePath;
  String get showingFilePath => _showingFilePath;

  void readNextChapter(){
    if(_currentChapterIndex < book.chapterTitles.length -1){
      _currentChapterIndex++;
      readChapter(_currentChapterIndex);
    }
  }

  void readPreviousChapter(){
    if(_currentChapterIndex > 0){
      _currentChapterIndex--;
      readChapter(_currentChapterIndex);
    }
  }

  void readChapter(int chapterIndex) {
    assert(currentPdfBookFiles.isNotEmpty, "EpubBook can not be null");
    try {

      if (!book.isSingleLaunch) {
        _showingFilePath = _currentPdfBookFiles[chapterIndex].path;
      } else {
        _showingFilePath = _currentPdfBookFiles[0].path;
      }

    } catch (error) {
      print('Error extracting chapter text');
      print(error);

    }
  }


}


class EpubParser {

  EpubParser(this.epubBook, {this.book});

  final epubLib.EpubBook epubBook;

  final BookEpub book;

  int _currentChapterIndex = 0;
  int get currentChapterIndex => _currentChapterIndex;

  // Contains the html raw data (for BookEpub)
  epubLib.EpubChapter _showingEpubChapter;

  final List<String> _loadedEpubData = [];
  List<String> get loadedEpubData => _loadedEpubData;

  // subChapters for the last displaying chapter
  // final List<String> _currentSubChapters = [];
  int _readingIndex = -1;


  Map<String, String> extractNavMap() {
    assert(epubBook != null, "EpubBook can not be null");

    Map<String, String> navigationMap = {};
    try {
      epubBook.Schema.Navigation.NavMap.Points.forEach((navigationPoint) {
        navigationMap[navigationPoint.Id] = navigationPoint.Content.Source;
      });

      return navigationMap;
    } catch (error) {
      print('Error extraction navigation map');
      return null;
    }
  }

  Future<List<String>> readNextChapter() async{
    if(_currentChapterIndex < book.chapterTitles.length -1){
      _currentChapterIndex++;
      return readChapter(_currentChapterIndex);
    }

    return null;
  }

  Future<List<String>> readPreviousChapter() async {
    if(_currentChapterIndex > 0){
      _currentChapterIndex--;
      return readChapter(_currentChapterIndex);
    }

    return null;
  }

  int _cachedChaptersCount;

  Future<List<String>> readChapter(int chapterNumber) async {
    assert(epubBook != null, "EpubBook can not be null");
    try {
      _showingEpubChapter = epubBook.Chapters[chapterNumber];
      _clearCachedChapter();
      _loadedEpubData.add(_showingEpubChapter.HtmlContent);
      await _cacheSubChapters(chapter: _showingEpubChapter);

      if(_loadedEpubData.length >=3) {
        _cachedChaptersCount = 3;
      }else {
        _cachedChaptersCount = _loadedEpubData.length;
      }

      return _loadedEpubData.sublist(_readingIndex, _readingIndex + _cachedChaptersCount);

    } catch (error) {
      print('Error extracting chapter text');
      print(error);
      return null;
    }
  }

  Future<void> _cacheSubChapters({epubLib.EpubChapter chapter}) async {
	  if (chapter.SubChapters != null && chapter.SubChapters.isNotEmpty) {
		  for (epubLib.EpubChapter subChapter in chapter.SubChapters) {
			  _loadedEpubData.add(subChapter.HtmlContent);
			  _cacheSubChapters(chapter: subChapter);
		  }
	  }
  }

//  Stream<String> _cacheSubChapters({epubLib.EpubChapter chapter}) async*{
//
//    if(chapter.SubChapters != null && chapter.SubChapters.isNotEmpty){
//
//      for(epubLib.EpubChapter subChapter in chapter.SubChapters){
//        yield subChapter.HtmlContent;
//        yield* _cacheSubChapters(chapter: subChapter);
//      }
//
////      Future.forEach(chapter.SubChapters, (epubLib.EpubChapter subChapter) async* {
////
////        yield subChapter.HtmlContent;
////        _currentSubChapters.add(subChapter.HtmlContent);
////
////        _cacheSubChapters(chapter: subChapter.SubChapters[index]);
////        index++;
////      });
//    }
//  }

  String getSubChapter(int index){
    _readingIndex = index + 1;
    // +1 because chapter main content is in the main position
    return loadedEpubData[_readingIndex];
  }

  // TODO fix this. put main chapter again. review replacing mechanism
  List<String> loadNextSubChapter(){

    if(canLoadNextSubChapter()){
      _readingIndex++;
      return loadedEpubData.sublist(_readingIndex, _readingIndex + _cachedChaptersCount);
    }

    return null;
  }

  List<String> loadPreviousSubChapter(){

    if(canLoadPreviousSubChapter()){
      _readingIndex--;
      return _loadedEpubData.sublist(_readingIndex, _readingIndex + _cachedChaptersCount);
    }

    return null;
  }

  bool canLoadPreviousSubChapter(){
    if(_readingIndex > 0) return true;
    return false;
  }

  bool canLoadNextSubChapter(){
    if(_readingIndex + _cachedChaptersCount < loadedEpubData.length) return true;
    return false;
  }

  void _clearCachedChapter(){
    _loadedEpubData.clear();
    _readingIndex = 0;
  }

  Uint8List extractImage() {
    assert(epubBook != null, "EpubBook can not be null");
    try {
      return Uint8List.fromList(epubBook.Content.Images.values.first.Content);
    } catch (error){
      print("No image was found");
      //TODO return a placeholder
      return null;
    }
  }

  String extractTitle() {
    assert(epubBook != null, "EpubBook can not be null");
    try {
	    if (epubBook.Title.isNotEmpty)
		    return epubBook.Title;
	    else {
		    return null;
	    }
    } catch (error){
    	print("Error extracting title");
    	return null;
    }
  }

  String extractSynopsis() {
    assert(epubBook != null, "EpubBook can not be null");
    try {
      dom.Document document = parser.parse(epubBook.Schema.Package.Metadata.Description);
      dom.Element bodyElement = document.getElementsByTagName('body').first;

      return bodyElement.nodes.first.text;
    } catch (error) {
      print('Error extracting synopsis');
      print(error);
      return null;
    }
  }

  List<String> extractChapterTitles() {
    assert(epubBook != null, "EpubBook can not be null");
    List<String> chapterTitles = List<String>();

    epubBook.Chapters.forEach((epubLib.EpubChapter chapter) {
      chapterTitles.add(chapter.Title);
    });

    return chapterTitles;
  }

  List<int> generateNewBookChapterLaunchDates() {
    assert(epubBook != null, "EpubBook can not be null");
    List<int> publicationDates = List<int>();
    for (var i = 0; i < epubBook.Chapters.length; i++) {
      publicationDates.add(DateTime.now().millisecondsSinceEpoch);
    }

    return publicationDates;
  }

  // adds Launch dates of the new chapters
  List<dynamic> setLaunchDateOfLatestChapters({BookEpub oldBook, BookEpub newBook}) {
    List<dynamic> newListWithUpdatedDates = List<dynamic>();

    newBook.chapterTitles.forEach((dynamic chapterTitle) {
      // file is old if true
      if (oldBook.chapterTitles.contains(chapterTitle)) {
        int index = oldBook.chapterTitles.indexOf(chapterTitle);
        newListWithUpdatedDates.add(oldBook.chaptersLaunchDates[index]);
      } else {
        newListWithUpdatedDates.add(DateTime.now().millisecondsSinceEpoch);
      }
    });

    return newListWithUpdatedDates;
  }

  BookLanguage extractLanguage() {
    assert(epubBook != null, "EpubBook can not be null");
    try {
      String language = epubBook.Schema.Package.Metadata.Languages.first.substring(0, 2);

      switch (language) {
        case "en":
          return BookLanguage.ENGLISH;
        case "pt":
          return BookLanguage.PORTUGUESE;
        case "de":
          return BookLanguage.DEUTSCH;
        default:
          return BookLanguage.UNDEFINED;
      }
    } catch (error) {
      print("Could not detect language");
      return BookLanguage.UNDEFINED;
    }
  }
}
