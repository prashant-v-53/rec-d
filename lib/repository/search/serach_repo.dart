import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchItemRepo {
  //* search from movie, tvshow, book, podcast
  Future searchData({String type, String searchQuery, int page}) async {
    String url;
    http.Response response;

    if (type == "movie" || type == "tv") {
      url =
          "${Global.tmdbApiBaseUrl}/3/search/$type?api_key=${Global.apiKey}&language=en-US&query=$searchQuery&page=$page&include_adult=false";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      response =
          await http.get(url, headers: {"${PrefsKey.RECD_HEADER}": "$token"});
      return response;
    } else if (type == "Podcast") {
      url =
          "https://listen-api.listennotes.com/api/v2/search?q=$searchQuery&type=podcast&offset=${page == 1 ? 0 : page}&only_in=title&region=us";
      response = await http.get(url,
          headers: {"${PrefsKey.PODCAST_HEADER}": "${Global.podcastToken}"});
      return response;
    } else if (type == "Book") {
      url =
          "https://www.googleapis.com/books/v1/volumes?q=$searchQuery&maxResults=40&startIndex=$page";

      response = await http.get(url);
      return response;
    } else {
      return null;
    }
  }
}
