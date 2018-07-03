import 'dart:collection';

enum BookGenre { UNDEFINED, ACTION, ADVENTURE, COMEDY, DRAMA, FANTASY, FICTION, HORROR, MYTHOLOGY, ROMANCE, SATIRE }

enum BookLanguage { UNDEFINED, ENGLISH, PORTUGUESE, DEUTSCH }

enum ChapterPeriodicity {
  NONE,
  EVERY_DAY,
  EVERY_3_DAYS,
  EVERY_7_DAYS,
  EVERY_14_DAYS,
  EVERY_30_DAYS,
  EVERY_42_DAYS,
}

class Book {
  String title;
  String uID;
  String authorName;
  String authorEmailId;
  String authorTwitterProfile;
  int publicationDate;
  BookGenre genre;
  int bookPosition;
  double rating;
  int ratingCounter;
  double income;
  int readingsNumber;
  BookLanguage language;
  String localFullBookUri;
  String remoteFullBookUri;
  List<dynamic> remoteChapterTitles = List();
  List<dynamic> remoteChapterUris = List();
  List<dynamic> chaptersLaunchDates = List();
  String localCoverUri;
  String localPosterUri;
  String remoteCoverUri;
  String remotePosterUri;
  bool isLaunchedComplete;
  bool isCurrentlyComplete;
  ChapterPeriodicity periodicity;
  String synopsis;

  Book(
      {this.title,
      this.uID,
      this.authorName,
      this.authorEmailId,
      this.authorTwitterProfile,
      this.publicationDate,
      this.genre,
      this.bookPosition,
      this.rating,
      this.ratingCounter,
      this.income,
      this.readingsNumber,
      this.language,
      this.localFullBookUri,
      this.remoteFullBookUri,
      this.localCoverUri,
      this.localPosterUri,
      this.remoteCoverUri,
      this.remotePosterUri,
      this.isLaunchedComplete,
      this.isCurrentlyComplete,
      this.periodicity,
      this.synopsis});

  String generateBookKey(){
    return "${authorEmailId}_${uID}_$language";
  }

  Book.fromLinkedMap(LinkedHashMap linkedMap) {
    this.rating = linkedMap['rating'];
    this.authorTwitterProfile = linkedMap['authorTwitterProfile'];
    this.isCurrentlyComplete = linkedMap['currentlyComplete'];
    this.remotePosterUri = linkedMap['remotePosterUri'];
    this.publicationDate = linkedMap['publicationDate'];
    this.uID = linkedMap['uID'];
    this.income = linkedMap['income'];
    this.localPosterUri = linkedMap['localPosterUri'];
    this.ratingCounter = linkedMap['ratingCounter'];
    this.authorName = linkedMap['authorName'];
    this.remoteCoverUri = linkedMap['remoteCoverUri'];
    this.isLaunchedComplete = linkedMap['launchedComplete'];
    this.authorEmailId = linkedMap['authorEmailId'];
    this.localFullBookUri = linkedMap['localFullBookUri'];
    this.title = linkedMap['title'];
    this.readingsNumber = linkedMap['readingsNumber'];
    this.bookPosition = linkedMap['bookPosition'];
    this.remoteFullBookUri = linkedMap['remoteFullBookUri'];
    this.localCoverUri = linkedMap['localCoverUri'];
    this.synopsis = linkedMap['synopsis'];
    this.chaptersLaunchDates.addAll(linkedMap['chaptersLaunchDates']);
    this.remoteChapterUris.addAll(linkedMap['remoteChapterUris']);
    this.remoteChapterTitles.addAll(linkedMap['remoteChapterTitles']);

    this.periodicity = ChapterPeriodicity.values.firstWhere((periodicity) {
      return periodicity.toString() == "ChapterPeriodicity.${linkedMap['periodicity']}";
    }, orElse: ()=> null);
    this.genre = BookGenre.values.firstWhere((genre) {
      return genre.toString() == "BookGenre.${linkedMap['genre']}";
    }, orElse: ()=> null);
    this.language = BookLanguage.values.firstWhere((bookLanguage){
      return bookLanguage.toString() == "BookLanguage.${linkedMap['language']}";
    }, orElse: ()=> null);
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    }
    if (other == null || this.runtimeType != other.runtimeType) {
      return false;
    }

    var that = other as Book;
    return uID == that.uID;
  }

  @override
  int get hashCode {
    return title.hashCode +
        uID.hashCode +
        authorName.hashCode +
        authorEmailId.hashCode +
        authorTwitterProfile.hashCode +
        publicationDate.hashCode +
        genre.hashCode +
        bookPosition.hashCode +
        rating.hashCode +
        ratingCounter.hashCode +
        income.hashCode +
        readingsNumber.hashCode +
        language.hashCode +
        localFullBookUri.hashCode +
        remoteFullBookUri.hashCode +
        remoteChapterTitles.hashCode +
        remoteChapterUris.hashCode +
        chaptersLaunchDates.hashCode +
        localCoverUri.hashCode +
        localPosterUri.hashCode +
        remoteCoverUri.hashCode +
        remotePosterUri.hashCode +
        isLaunchedComplete.hashCode +
        isCurrentlyComplete.hashCode +
        periodicity.hashCode +
        synopsis.hashCode;
  }
}
