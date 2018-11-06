import 'package:cronicalia_flutter/login_screen/login_handler.dart';

class Constants {
  static const BOTTOM_NAV_TAG = 'app_bottom_nav';

  static const ROUTE_LOGIN_SCREEN = '/loginScreen';
  static const ROUTE_EDIT_BOOK_SCREEN = '/editBookScreen';
  static const ROUTE_SUGGESTIONS_SCREEN = '/suggestionsScreen';
  static const ROUTE_SEARCH_SCREEN = '/searchScreen';
  static const ROUTE_BOOKMARKS_SCREEN = '/bookmarksScreen';
  static const ROUTE_MY_BOOKS_SCREEN = '/myBooksScreen';
  static const ROUTE_PROFILE_SCREEN = '/profileScreen';

  static const DOCUMENT_UID_MAPPINGS = "UID_mappings";
  static const DOCUMENT_MESSAGE_TOKENS = "Message_tokens";
  static const DOCUMENT_EMAIL_UID = "UID";

  static const COLLECTION_USERS = "Users";
  static const COLLECTION_CREDENTIALS = "Credentials";
  static const COLLECTION_BOOKS_ENGLISH = "English_Books";
  static const COLLECTION_BOOKS_PORTUGUESE = "Portuguese_Books";
  static const COLLECTION_BOOKS_DEUTSCH = "Deutsch_Books";
  static const COLLECTION_BOOK_OPINIONS = "Book_Opinions";
  static const COLLECTION_USER_OPINIONS = "User_Opinions";

  static const STORAGE_ENGLISH_BOOKS = "english_books";
  static const STORAGE_PORTUGUESE_BOOKS = "portuguese_books";
  static const STORAGE_DEUTSCH_BOOKS = "deutsch_books";
  static const STORAGE_CHAPTERS_FILES = "chapters";
  static const STORAGE_USERS = "users";

  static const METADATA_TITLE_IMAGE_TYPE = "imageType";
  static const METADATA_PROPERTY_IMAGE_TYPE_COVER = "cover";
  static const METADATA_PROPERTY_IMAGE_TYPE_PROFILE = "profile";
  static const METADATA_PROPERTY_IMAGE_TYPE_BACKGROUND = "background";
  static const METADATA_CHAPTER_NUMBER = "chapter_number";

  static const FILE_NAME_BOOK_COVER = "cover.jpg";
  static const FILE_NAME_PROFILE_PICTURE = "profile_picture.jpg";
  static const FILE_NAME_BACKGROUND_PICTURE = "background_picture.jpg";
  static const FILE_NAME_SUFFIX_COVER_PICTURE = "cover.jpg";
  static const FILE_NAME_TEMP_COVER_PICTURE = "temp_cover.jpg";
  static const FOLDER_NAME_PROFILE = "profile";
  static const FOLDER_NAME_BOOKS = "books";
  static const FOLDER_NAME_MY_READINGS = "my_readings";

  static const PDF_ADD_CODE = 400;
  static const PDF_REQUEST_CODE = 500;
  static const PDF_EDIT_CODE = 600;
  static const LOGIN_REQUEST_CODE = 700;

  static const UPLOAD_STATUS_OK = 100;
  static const UPLOAD_STATUS_FAIL = -1;

  static const PARCELABLE_USER = "parcelable_user";
  static const PARCELABLE_BOOK = "parcelable_book";
  static const PARCELABLE_SELECTED_BOOK = "parcelable_selected_book";
  static const PARCELABLE_BOOK_OPINIONS = "parcelable_book_opinions";
  static const PARCELABLE_IS_SAVE_BUTTON_SHOWING = "parcelable_is_save_button_showing";
  static const PARCELABLE_FILES_TO_BE_DELETED = "parcelable_files_to_be_deleted";
  static const PARCELABLE_IS_CHANGE_FILE_ADDITION = "parcelable_is_change_file_addition";
  static const PARCELABLE_URI_KEYS = "parcelable_uri_keys";
  static const PARCELABLE_TITLE_VALUES = "parcelable_title_values";
  static const PARCELABLE_LAYOUT_MANAGER = "parcelable_layout_manager";
  static const PARCELABLE_BOOK_KEY = "parcelable_book_key";
  static const PARCELABLE_IMAGE_DESTINATION = "parcelable_image_destination";
  static const PARCELABLE_ACTION_BOOK_LIST = "parcelable_action_book_list";
  static const PARCELABLE_ADVENTURE_BOOK_LIST = "parcelable_adventure_book_list";
  static const PARCELABLE_COMEDY_BOOK_LIST = "parcelable_comedy_book_list";
  static const PARCELABLE_DRAMA_BOOK_LIST = "parcelable_drama_book_list";
  static const PARCELABLE_FANTASY_BOOK_LIST = "parcelable_fantasy_book_list";
  static const PARCELABLE_FICTION_BOOK_LIST = "parcelable_fiction_book_list";
  static const PARCELABLE_HORROR_BOOK_LIST = "parcelable_horror_book_list";
  static const PARCELABLE_MYTHOLOGY_BOOK_LIST = "parcelable_mythology_book_list";
  static const PARCELABLE_ROMANCE_BOOK_LIST = "parcelable_romance_book_list";
  static const PARCELABLE_SATIRE_BOOK_LIST = "parcelable_satire_book_list";
  static const PARCELABLE_LAYOUT_POSITION = "parcelable_layout_position";
  static const PARCELABLE_SELECTED_BOOK_GENRE = "parcelable_selected_book_genre";
  static const PARCELABLE_SELECTED_BOOK_KEY = "parcelable_selected_book_key";

  static const SHARED_PREFERENCES = "com_andre_haueisen_shared_pref";
  static const SHARED_MESSAGE_TOKEN = "message_token";

  static const INTENT_CALLING_ACTIVITY = "intent_calling_activity";

  static const FRAGMENT_EDIT_CREATION_TAG = "fragment_edit_creation_tag";
  static const FRAGMENT_BOOK_SELECTED_TAG = "fragment_book_selected";
  static const FRAGMENT_FEATURED_BOOKS_TAG = "fragment_featured_books_tag";
  static const DIALOG_DELETE_BOOK_TAG = "dialog_delete_book_tag";
  static const BACK_STACK_CREATIONS_TO_EDIT_TAG = "back_stack_creations_to_edit_tag";
  static const BACK_STACK_FEATURED_TO_SELECTED_TAG = "back_stack_featured_to_selected_tag";

  static const BAR_DURATION_LONG = 3000.0;
  static const BOOK_QUERY_MINIMUM_VAL = -1.0;
  static const ONE_MB_IN_BYTES = 1000000;

  static const MAX_TITLE_LENGTH = 90;
  static const MAX_SYNOPSIS_LENGTH = 1500;
  static const MIN_SYNOPSIS_LENGTH = 100;
  static const BOOK_COVER_DEFAULT_HEIGHT = 180.0;
  static const BOOK_COVER_DEFAULT_WIDTH = 135.0;

  static const GOOGLE_ID_TOKEN = "idToken";
  static const GOOGLE_ACCESS_TOKEN = "accessToken";
  static const TWITTER_CONSUMER_KEY = "consumerKey";
  static const TWITTER_CONSUMER_SECRET = "consumerSecret";

  static const CONTENT_TYPE_IMAGE = "image/jpg";
  static const CONTENT_TYPE_PDF = "application/pdf";
  static const CONTENT_TYPE_TXT = "text/plain";
  static const CONTENT_TYPE_EPUB = "application/epub+zip";

  static const SHARED_PREFERENCES_TEXT_SIZE_KEY = "text_size_key";
  static const SHARED_PREFERENCES_BOOKMARK_INFO_MAP_KEY = "bookmark_info_map_key";

  static const HERO_TAG_BOOK_COVER = "book_cover_tag";

  static const PROVIDER_OPTIONS = <ProviderOptions, String>{
    ProviderOptions.GOOGLE: "google.com",
    ProviderOptions.FACEBOOK: "facebook.com",
    ProviderOptions.TWITTER: "twitter.com",
    ProviderOptions.PASSWORD: "password"
  };
}
