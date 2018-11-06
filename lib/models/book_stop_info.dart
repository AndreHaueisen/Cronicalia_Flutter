import 'dart:convert';

import 'package:cronicalia_flutter/utils/constants.dart';
import 'package:meta/meta.dart';


class BookStopInfo{

  BookStopInfo(this._bookUid, this.lastChapterIndex, this.scrollPosition);

  String get bookUid => _bookUid;

  BookStopInfo.fromJson( String encodedBookmark ){

    Map<String, dynamic> bookmarkMap = json.decode(encodedBookmark);
    this._bookUid = bookmarkMap['bookUid'];
    this.lastChapterIndex = bookmarkMap['lastChapterIndex'];
    this.scrollPosition = bookmarkMap['scrollPosition'];

  }

  static String staticToJson({@required String bookUid, @required int lastChapter, @required double scrollPosition}){
    return json.encode(BookStopInfo(bookUid, lastChapter, scrollPosition));
  }

  String toJson(){
    return json.encode(this, toEncodable: (_){
      return {
        'bookUid' : this.bookUid,
        'lastChapterIndex' : this.lastChapterIndex,
        'scrollPosition' : this.scrollPosition
      };
    });
  }

  static String generateSharedPreferencesKey(String bookUid){
    return Constants.SHARED_PREFERENCES_BOOKMARK_INFO_MAP_KEY + "_$bookUid";
  }

  String _bookUid;
  int lastChapterIndex;
  double scrollPosition;


}