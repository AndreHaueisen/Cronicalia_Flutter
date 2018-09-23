enum BookUploadStatus { SUCCESS, FAILED }

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

class UtilityBook{
  static String convertPeriodicityToString(ChapterPeriodicity chapterPeriodicity) {
    switch (chapterPeriodicity) {
      case ChapterPeriodicity.NONE:
        return "None";
      case ChapterPeriodicity.EVERY_DAY:
        return "Every day";
      case ChapterPeriodicity.EVERY_3_DAYS:
        return "Every three days";
      case ChapterPeriodicity.EVERY_7_DAYS:
        return "Every week";
      case ChapterPeriodicity.EVERY_14_DAYS:
        return "Every two weaks";
      case ChapterPeriodicity.EVERY_30_DAYS:
        return "Every month";
      case ChapterPeriodicity.EVERY_42_DAYS:
        return "Every 42 days";
      default:
        return "Every day";
    }
  }

  static String convertGenreToString(BookGenre bookGenre) {
    switch (bookGenre) {
      case BookGenre.ACTION:
        return "Action";
      case BookGenre.ADVENTURE:
        return "Adventure";
      case BookGenre.COMEDY:
        return "Comedy";
      case BookGenre.DRAMA:
        return "Drama";
      case BookGenre.FANTASY:
        return "Fantasy";
      case BookGenre.FICTION:
        return "Fiction";
      case BookGenre.HORROR:
        return "Horror";
      case BookGenre.MYTHOLOGY:
        return "Mythology";
      case BookGenre.ROMANCE:
        return "Romance";
      case BookGenre.SATIRE:
        return "Satire";
      default:
        return "Undefined";
    }
  }

  static String convertLanguageToString(BookLanguage bookLanguage) {
    switch (bookLanguage) {
      case BookLanguage.ENGLISH:
        return "English";
      case BookLanguage.PORTUGUESE:
        return "Portuguese";
      case BookLanguage.DEUTSCH:
        return "German";
      default:
        return "Undefined";
    }
  }
}