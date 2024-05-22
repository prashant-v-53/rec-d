import 'dart:convert';

import 'package:recd/helpers/app_config.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RecdRepo {
  Future fetchRelatedRecs({String type, List ids}) async {
    String url =
        App.RECd_URL + 'api/v1/recommendation/get-multiple-recommendation-list';

    String itemType = "Movie";

    if (type == "movie") {
      itemType = "Movie";
    } else if (type == "tv") {
      itemType = "Tv Show";
    }
    Map data = {"recd_type": itemType, "id": ids};
    String body = json.encode(data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");

    final response = await http.post(url, body: body, headers: {
      "Content-Type": "application/json",
      "authorization": "$token"
    });
    return response;
  }
}
