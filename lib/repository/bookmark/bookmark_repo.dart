import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:path/path.dart' as path;

import 'package:shared_preferences/shared_preferences.dart';

class BookMarkRepo {
  Future<Response> createBookmarkRepo(
      {File fileData, String title, String desc}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString(PrefsKey.ACCESS_TOKEN);
      String url = "${App.RECd_URL}${API.CREATE_BOOKMARK}";
      Dio dio = Dio();
      var uri = Uri.parse(url);

      if (fileData == null) {
        Response response;

        response = await dio.post(
          "$uri",
          options: Options(headers: {"authorization": "$accessToken"}),
          data: FormData.fromMap({"title": title}),
        );

        return response;
      } else {
        Response response = await dio.post(
          "$uri",
          options: Options(headers: {"authorization": "$accessToken"}),
          data: FormData.fromMap(
            {
              "bookmark_cover": MultipartFile.fromFileSync(fileData.path,
                  filename: path.basename(fileData.path)),
              "title": title,
            },
          ),
        );
        return response;
      }
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future<Response> updateBookmarkRepo(
      {String id, File fileData, String title, String desc}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString(PrefsKey.ACCESS_TOKEN);
    String url = "${App.RECd_URL}${API.UPDATE_BOOKMARK}";
    Dio dio = Dio();
    var uri = Uri.parse(url);

    if (fileData == null) {
      Response response = await dio.post("$uri",
          options: Options(headers: {"authorization": "$accessToken"}),
          data: FormData.fromMap({
            "bookmark_id": id,
            "title": title,
          }));

      return response;
    } else {
      Response response = await dio.post("$uri",
          options: Options(headers: {"authorization": "$accessToken"}),
          data: FormData.fromMap({
            "bookmark_id": id,
            "bookmark_cover": MultipartFile.fromFileSync(fileData.path,
                filename: path.basename(fileData.path)),
            "title": title,
          }));
      return response;
    }
  }

  Future fetchBookmarks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = "${App.RECd_URL}${API.BOOKMARK_LIST}";
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response =
          await http.get(url, headers: {"authorization": "$token"});
      return response;
    } catch (e) {
      return null;
    }
  }

  Future fetchBookmarks1({String type, String id}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = "${App.RECd_URL}${API.BOOKMARK_LIST1}";
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "authorization": "$token"
          },
          body: jsonEncode({"recd_type": type, "id": id}));

      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future fetchBookmarksById({String id, String searchQuery, int page}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url =
          "${App.RECd_URL}${API.BOOKMARK_DETAIL_ID}/$id?page=$page&search=$searchQuery";
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response =
          await http.get(url, headers: {"authorization": "$token"});
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future saveBookmarkToCollection({map}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = "${App.RECd_URL}${API.ADD_BOOKMARK_TO_COLLECTION}";
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "authorization": "$token"
          },
          body: jsonEncode(map));
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future unCategorizedBookmark({map}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = "${App.RECd_URL}${API.UNCATEGORIZEDBOOKMARK}";
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "authorization": "$token"
          },
          body: jsonEncode(map));
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future fetchAllBookmarks({int page, String searchQuery}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url =
          "${App.RECd_URL}${API.BOOKMARK_ALL_LIST}?page=$page&search=$searchQuery";
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response =
          await http.get(url, headers: {"authorization": "$token"});
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future removeBM({String bmId, String recdId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = "${App.RECd_URL}${API.BOOKMARK_REMOVE_LIST}";
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "authorization": "$token"
        },
        body: jsonEncode({"bookmark_id": "$bmId", "recd_id": "$recdId"}),
      );
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future removeUnCategorizedBookmark(String bmId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = "${App.RECd_URL}${API.BOOKMARK_REMOVE}$bmId";

      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "authorization": "$token"
        },
      );
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future removeBList(String bookmarkListId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = "${App.RECd_URL}${API.REMOVE_BOOKMARK_LIST}$bookmarkListId";

      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
      http.Response response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "authorization": "$token"
        },
      );
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
