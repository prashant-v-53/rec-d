import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';

import 'package:recd/model/bookmark/bookmark.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/model/group/group.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/auth/auth_repo.dart';
import 'package:recd/repository/bookmark/bookmark_repo.dart';
import 'package:recd/repository/profile/profile_repo.dart';
import 'package:recd/elements/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  ScrollController pageScroll = ScrollController();

  List<RecsDetailsModel> recsList = [];
  List<Bookmark> bookmarkData = [];
  UserModel userData;
  int page = 1;
  bool isBookmarkLoading = true;
  bool isDataLoading = true;
  bool isRecsLoading = true;
  bool isPaginationLoading = true;
  bool isLogOutLoading = false;

  Future<List<Bookmark>> getBookmarks() async {
    List<Bookmark> list = [];
    http.Response response =
        await BookMarkRepo().fetchBookmarks().catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        res['data'].forEach(
          (val) {
            Bookmark bookmark = Bookmark(
              bookmarkId: val['_id'],
              bookmarkName: val['title'],
              numberOfReco: val['bookmarks'],
              bookmarkImg: val['bookmark_cover_path'],
            );
            setState(() => list.add(bookmark));
          },
        );
        return list;
      } else if (response.statusCode == 422) {
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast("Something went wrong");
        return null;
      } else {
        toast("Something went wrong");
        return null;
      }
    } else {
      toast("Something went wrong");
      return null;
    }
  }

  Future<List<RecsDetailsModel>> fetchAllRecs(int page) async {
    List<RecsDetailsModel> cList = [];
    var response =
        await ProfileRepo().fetchRecsDetails(page).catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach((res) {
            RecsDetailsModel con = RecsDetailsModel(
              id: res['_id'],
              recipientList: res['conversation'],
              image: res['message'].containsKey('listennotes_data')
                  ? res['message']['listennotes_data']['image']
                  : res['message'].containsKey('tmdb_data')
                      ? "${Global.tmdbImgBaseUrl}"
                          "${res['message']['tmdb_data']['poster_path']}"
                      : res['message'].containsKey('googlebooks_data')
                          ? res['message']['googlebooks_data']['volumeInfo']
                              ['imageLinks']['thumbnail']
                          : Global.staticRecdImageUrl,
              title: res['message']['title'],
              subtitle: res['message']['description'],
              humanDate: res['createdAt'],
              itemType: res['message']['category']['name'],
              itemId: res['message']['category']['name'] == "Movie" ||
                      res['message']['category']['name'] == "Tv Show"
                  ? res['message']['tmdb_data']['id'].toString()
                  : res['message']['category']['name'] == "Book"
                      ? res['message']['googlebooks_data']['id']
                      : res['message']['category']['name'] == "Podcast"
                          ? res['message']['listennotes_data']['id']
                          : "0",
              totalReco: res['TotalRecommndation'],
            );
            setState(() => cList.add(con));
          });
          return cList;
        } catch (e) {
          setState(() => isRecsLoading = false);
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        setState(() => isRecsLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isRecsLoading = false);
        toast("Unauthorized");
        return null;
      } else if (response.statusCode == 500) {
        setState(() => isRecsLoading = false);
        toast("Something went wrong");
        return null;
      } else {
        setState(() => isRecsLoading = false);
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() => isRecsLoading = false);
      toast("Something went wrong");
      return null;
    }
  }

  Future getUserDetails() async {
    http.Response response = await AuthRepo().userData().catchError(
          (err) => print(err),
        );
    print(response.statusCode);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          if (res['data'] != null) {
            return new UserModel(
              id: res['data']['_id'].toString(),
              name: res['data']['name'].toString(),
              email: res['data']['email'].toString(),
              mobile: res['data']['mobile'].toString(),
              username: res['data']['userName'].toString(),
              profile: res['data']['profile_path'].toString(),
              dob: res['data']['DOB'].toString(),
              recs: res['data']['recs'].toString(),
              friends: res['data']['friends'].toString(),
              groups: res['data']['groups'].toString(),
              bio: res['data']['bio'].toString() == "null" ||
                      res['data']['bio'].toString() == ""
                  ? ''
                  : res['data']['bio'].toString(),
            );
          }
          return null;
        } catch (e) {
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast("Something went wrong");
        return null;
      } else {
        toast("Something went wrong");
        return null;
      }
    } else {
      toast("Something went wrong");
      return null;
    }
  }

  logOut(context) async {
    setState(() => isLogOutLoading = true);
    SharedPreferences pref = await SharedPreferences.getInstance();
    http.Response response = await AuthRepo().logOutApi();
    if (response.statusCode == 200 || response.statusCode == 401) {
      setState(() => isLogOutLoading = false);
      pref.setString(PrefsKey.ACCESS_TOKEN, null);
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteKeys.SPLASH,
        (route) => false,
      );
    } else {
      setState(() => isLogOutLoading = false);
    }
  }
}
