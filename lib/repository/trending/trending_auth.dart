import 'package:recd/elements/helper.dart';


import 'package:http/http.dart' as http;

class TrendingRepo {
  Future getTrendingMovie({String type, String trendingType, int page}) async {
    String url = Global.tmdbApiBaseUrl +
        "/3/trending/$type/$trendingType?api_key=${Global.apiKey}&page=$page";
    final response = await http.get(url);
    return response;
  }

  Future getTrendingTvShow(
      {String type, String trendingType, int tvShowPage}) async {
    String url = Global.tmdbApiBaseUrl +
        "/3/trending/tv/$trendingType?api_key=${Global.apiKey}&page=$tvShowPage";

    final response = await http.get(url);
    return response;
  }
}
