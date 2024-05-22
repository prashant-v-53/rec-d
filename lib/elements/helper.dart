import 'package:recd/model/category_model.dart';

class Global {
  static List<Category> movieCategory = [];
  static List<Category> podCastCategory = [];
  static List<Category> tvShowCategory = [];
  static String apiKey = "";
  static String podcastToken = "";
  static String tmdbApiBaseUrl = "";
  static String tmdbBackdropBaseUrl = "";
  static String tmdbImgBaseUrl = "";
  static String podcastApiBaseUrl = "";
  static String staticRecdImageUrl = "";
}

class TitleInfo {
  static const String TopRated = "Top Rated";
}

class IsInternetState {
  bool isInternet = true;
}

class NotificationNumber {
  static String notificationNumber = "";
}

bool isDate(String str) {
  try {
    DateTime.parse(str ?? '0000-00-00');
    return true;
  } catch (e) {
    return false;
  }
}

getUserImageListWidth(List list) {
  double w;
  if (list.length >= 3) {
    w = 75.0;
  } else if (list.length >= 2) {
    w = 55.0;
  } else if (list.length >= 1) {
    w = 35.0;
  } else {
    w = 0.0;
  }
  return w;
}

class TimeAgo {
  String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "Just now";
  }
}
