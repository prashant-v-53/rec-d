import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepo {
  Future fetchNotificationDetails(int page) async {
    String url = App.RECd_URL + API.GET_NOTIFICATION + "?page=$page";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    http.Response response = await http.get(url, headers: {
      "${PrefsKey.RECD_HEADER}": "$token",
    });
    return response;
  }

  Future acceptRejectRequest({String id, String type}) async {
    String url = App.RECd_URL + "api/v1/user/respond-to-friend-request";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    http.Response response = await http.post(url,
        body: {"user": "$id", "type": "$type"},
        headers: {"Accept": "application/json", "authorization": "$token"});
    return response;
  }
}
