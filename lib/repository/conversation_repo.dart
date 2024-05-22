import 'dart:convert';

import 'package:http/http.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ConversationRepo {
  static Future<Response> getContactListApi(String type, int page) async {
    String url =
        "${App.RECd_URL}api/v1/recommendation/get-conversations-list/$type?page=$page";

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");

    final response = await get(url, headers: {
      "${PrefsKey.RECD_HEADER}": "$token",
    });
    return response;
  }

  static Future<Response> getHomeConversations(int page, bool info) async {
    String url =
        "${App.RECd_URL}api/v1/recommendation/get-home-conversations-list?page=$page&recdby=$info";

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");

    final response = await get(url, headers: {
      "${PrefsKey.RECD_HEADER}": "$token",
    });
    return response;
  }

  static Future<Response> getConversationMessagesApi(
      String conversationId, int page) async {
    String url =
        "${App.RECd_URL}api/v1/recommendation/get-conversations-messages/$conversationId?page=$page";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await get(url, headers: {
      "${PrefsKey.RECD_HEADER}": "$token",
    });
    return response;
  }

  static Future<Response> sendRec(Map map) async {
    String url = "${App.RECd_URL}api/v1/recommendation/add-recommendation";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await post(
      url,
      headers: {
        "Content-Type": "application/json",
        "${PrefsKey.RECD_HEADER}": "$token",
      },
      body: jsonEncode(map),
    );
    return response;
  }
}
