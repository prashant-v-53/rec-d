class API {
  //* authentication API's
  static const String Login_URL = "api/v1/user/login";
  static const String SingUp_URL = "api/v1/user/signup";
  static const String FORGOT_PASSWORD_MAIL_SENT =
      "api/v1/user/forgot-password-mail-sent";
  static const String FORGOT_PASSWORD_OTP_VERIFY =
      "api/v1/user/forgot-password-otp-verify";
  static const String FORGOT_PASSWORD_UPDATE =
      "api/v1/user/forgot-password-update";
  static const String SET_UPDATE_PROFILE = "api/v1/user/set-profile-picture";
  static const String UPDATE_BIO = "api/v1/user/update-bio";
  static const String PROFILE_DATA = "api/v1/user/profile";
  static const String UPDATE_PROFILE = "api/v1/user/update-profile";

  // Bookmark API
  static const String CREATE_BOOKMARK = "api/v1/bookmark/create-bookmark-list";
  static const String UPDATE_BOOKMARK = "api/v1/bookmark/update-bookmark-list";

  static const String ADD_BOOKMARK_TO_COLLECTION =
      "api/v1/bookmark/add-recd-to-bookmark-list";
  static const String UNCATEGORIZEDBOOKMARK =
      "api/v1/bookmark/add-recd-to-individual-bookmark";
  static const String BOOKMARK_LIST =
      "api/v1/bookmark/get-bookmark-list-by-user";
  static const String BOOKMARK_LIST1 =
      "api/v1/bookmark/get-bookmark-collection-with-status";
  static const String BOOKMARK_DETAIL_ID =
      "api/v1/bookmark/get-recd-of-bookmark-list";
  static const String BOOKMARK_ALL_LIST =
      "api/v1/bookmark/get-individual-bookmarks";
  static const String BOOKMARK_REMOVE =
      "api/v1/bookmark/remove-individual-bookmark/";
  static const String REMOVE_BOOKMARK_LIST =
      "api/v1/bookmark/delete-bookmark-list/";

  static const String BOOKMARK_REMOVE_LIST =
      "api/v1/bookmark/remove-recd-from-bookmark-list";

  // Podcast API
  static const String BEST_PODCAST = "api/v2/best_podcasts?";
  static const String PODCAST_CATEGORY = "api/v2/genres?top_level_only=1";

  static const String VIEW_PODCAST = "api/v2/podcasts/";
  static const String PODCAST_RECO = "api/v2/podcasts/";

  //rate
  static const String RATE_FIELD = "api/v1/rating/get-rating-stars-value";
  static const String ADD_RATEING = "api/v1/rating/add-ratings";
  static const String GET_RATEING = "api/v1/rating/get-ratings-by-type";

  // User APIs

  static const String ALL_USER = "api/v1/user/get-all";
  static const String CREATE_GROUP = "api/v1/recommendation/create-group";
  static const String UPDATE_GROUP = "api/v1/recommendation/update-group/";
  static const String GROUP_INFO = "api/v1/recommendation/get-group-detail/";
  static const String ADD_REMOVE_USER_FROM_GROUP =
      "api/v1/recommendation/add-remove-member-from-group";
  static const String REMAINING_MEMBER =
      "api/v1/recommendation/get-users-list-not-in-group";

  static const String GET_RECS = "api/v1/user/get-user-recds-list";
  static const String GET_FRIENDS = "api/v1/user/get-user-friends-list";
  static const String GET_GROUPS = "api/v1/user/get-user-group-list";
  static const String GET_NOTIFICATION =
      "api/v1/notification/get-user-notification";
  static const String GET_VIEW_PROFILE = "api/v1/user/get-user-detail";
  static const String GET_RECD_FRIENDS_LIST =
      "api/v1/recommendation/get-recommendation-full-list";

  static const String APP_LINKS = "api/v1/appconfig/get-app-config";
}
