import 'dart:developer';

import 'package:recd/elements/helper.dart';
import 'package:http/http.dart' as http;

class TvShowRepo {
  Future fetchMovieDetails(int movieId) async {
    try {
      String url = Global.tmdbApiBaseUrl +
          "/3/tv/$movieId?api_key=${Global.apiKey}&language=en-US";
      final response = await http.get(url);
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future fetchRelatedMovies(int movieId) async {
    try {
      String url =
          "${Global.tmdbApiBaseUrl}/3/tv/$movieId/similar?api_key=${Global.apiKey}&language=en-US&page=1";
      final response = await http.get(url);
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
