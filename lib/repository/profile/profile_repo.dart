import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepo {
  Future fetchRecsDetails(int page) async {
    String url = App.RECd_URL + API.GET_RECS + "?page=$page";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response =
        await http.get(url, headers: {"${PrefsKey.RECD_HEADER}": "$token"});
    return response;
  }

  Future fetchFriendsDetails(
      {int page, String searchQuery, String userId}) async {
    String url = App.RECd_URL +
        API.GET_FRIENDS +
        "/$userId?page=$page&search=$searchQuery";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    http.Response response =
        await http.get(url, headers: {"${PrefsKey.RECD_HEADER}": "$token"});
    return response;
  }

  Future fetchNoFriendList({int page, String searchQuery}) async {
    String url = App.RECd_URL +
        "api/v1/user/get-users-list-without-friends?page=$page&search=$searchQuery";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    http.Response response =
        await http.get(url, headers: {"${PrefsKey.RECD_HEADER}": "$token"});
    return response;
  }

  Future sendFriendRequest(String id) async {
    String url = App.RECd_URL + "api/v1/user/send-friend-request";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    http.Response response = await http.post(url,
        body: {"user": "$id"},
        headers: {"Accept": "application/json", "authorization": "$token"});
    return response;
  }

  Future fetchGroupsDetails({int page, String searchQuery}) async {
    String url =
        App.RECd_URL + API.GET_GROUPS + "?page=$page&search=$searchQuery";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    http.Response response =
        await http.get(url, headers: {"${PrefsKey.RECD_HEADER}": "$token"});
    return response;
  }

  Future fetchRecdFriendsList({String type, String id, int page}) async {
    String url = App.RECd_URL + API.GET_RECD_FRIENDS_LIST + "?page=$page";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    http.Response response = await http.post(url,
        body: {"recd_type": "$type", "id": "$id"},
        headers: {"Accept": "application/json", "authorization": "$token"});
    return response;
  }
}
