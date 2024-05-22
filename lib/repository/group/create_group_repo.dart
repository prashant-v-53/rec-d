import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:recd/model/category_model.dart';
import 'package:recd/model/usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupRepo {
  Future getAllUser({int page, String queryData}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url =
        "${App.RECd_URL}api/v1/user/get-user-friends-list/${prefs.getString(PrefsKey.USER_ID)}/?page=$page&search=$queryData";

    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response =
        await http.get(url, headers: {"${PrefsKey.RECD_HEADER}": "$token"});
    return response;
  }

  Future getRemainingMember({String groupId, int page}) async {
    String url = "${App.RECd_URL}${API.REMAINING_MEMBER}/$groupId?page=$page";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response =
        await http.get(url, headers: {"${PrefsKey.RECD_HEADER}": "$token"});
    return response;
  }

  Future getGroupMember(String id) async {
    String url = "${App.RECd_URL}${API.GROUP_INFO}$id";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response =
        await http.get(url, headers: {"${PrefsKey.RECD_HEADER}": "$token"});
    return response;
  }

  Future addOrRemovePersonFromGroup(
      {String type, String groupId, List<String> memberId}) async {
    String url = App.RECd_URL + '${API.ADD_REMOVE_USER_FROM_GROUP}';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(url,
        body: json
            .encode({"action": type, "group_id": groupId, "members": memberId}),
        headers: {
          "Content-Type": "application/json",
          "authorization": "$token"
        });
    return response;
  }

  Future leavePersonFromGroup({String groupId}) async {
    String url = App.RECd_URL + 'api/v1/recommendation/leave-the-group';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(url,
        body: json.encode({"group_id": groupId}),
        headers: {
          "Content-Type": "application/json",
          "authorization": "$token"
        });
    return response;
  }

  Future<Response> createGroup(
      {File fileData, String name, List<UserInfo> ids}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString(PrefsKey.ACCESS_TOKEN);
      String url = "${App.RECd_URL}${API.CREATE_GROUP}";
      Dio dio = Dio();
      var uri = Uri.parse(url);
      List list = [];
      for (var i = 0; i < ids.length; i++) {
        list.add(ids[i].userid);
      }
      if (fileData == null) {
        Response response = await dio.post("$uri",
            options: Options(headers: {
              "authorization": "$accessToken",
              HttpHeaders.contentTypeHeader: "application/json"
            }),
            data: FormData.fromMap({"name": "$name", "members": list}));
        return response;
      } else {
        Response response = await dio.post("$uri",
            options: Options(headers: {"authorization": "$accessToken"}),
            data: FormData.fromMap({
              "cover": MultipartFile.fromFileSync(fileData.path,
                  filename: path.basename(fileData.path)),
              "name": "$name",
              "members": list
            }));
        return response;
      }
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future<Response> updateGroup(
      {String groupId, File fileData, String name, List<UserModel> ids}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString(PrefsKey.ACCESS_TOKEN);
      String url = "${App.RECd_URL}${API.UPDATE_GROUP}$groupId";
      Dio dio = Dio();
      var uri = Uri.parse(url);
      List list = [];
      for (var i = 0; i < ids.length; i++) {
        list.add(ids[i].id);
      }
      if (fileData == null) {
        Response response = await dio.post("$uri",
            options: Options(headers: {
              "authorization": "$accessToken",
              HttpHeaders.contentTypeHeader: "application/json"
            }),
            data: FormData.fromMap({"name": "$name", "members": list}));
        return response;
      } else {
        Response response = await dio.post("$uri",
            options: Options(headers: {"authorization": "$accessToken"}),
            data: FormData.fromMap({
              "cover": MultipartFile.fromFileSync(fileData.path,
                  filename: path.basename(fileData.path)),
              "name": "$name",
              "members": list
            }));
        return response;
      }
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
