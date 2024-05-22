import 'package:recd/elements/helper.dart';

import 'package:http/http.dart' as http;

class ViewItemRepo {
  Future fetchCategoryDataRepo(
      {String itemType, String categoryId, int page}) async {
    try {
      String url = Global.tmdbApiBaseUrl +
          "/3/discover/$itemType?api_key=${Global.apiKey}&with_genres=$categoryId&page=$page";

      final response = await http.get(url);
      return response;
    } catch (e) {
      return null;
    }
  }
}
