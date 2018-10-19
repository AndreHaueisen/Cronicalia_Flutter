import 'dart:typed_data';

import 'package:cronicalia_flutter/models/book.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:epub/epub.dart' as epubLib;

class EpubParser {
  EpubParser(this.epubBook);

  epubLib.EpubBook epubBook;

  String readChapter(int chapterNumber) {
    assert(epubBook != null, "EpubBook can not be null");
    try {
      // dom.Document document = parser.parse(epubBook.Chapters[chapterNumber].HtmlContent);
      // dom.Element bodyElement = document.getElementsByTagName('body').first;

      // return bodyElement.nodes.first.text;
      return epubBook.Chapters[chapterNumber].HtmlContent;
    } catch (error) {
      print('Error extracting chapter text');
      print(error);
      return null;
    }
  }

  Uint8List extractImage() {
    assert(epubBook != null, "EpubBook can not be null");
    return Uint8List.fromList(epubBook.Content.Images.values.first.Content);
  }

  String extractTitle() {
    assert(epubBook != null, "EpubBook can not be null");
    return epubBook.Title;
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
  List<dynamic> setLaunchDateOfLatestsChapters({BookEpub oldBook, BookEpub newBook}) {
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
  }
}
