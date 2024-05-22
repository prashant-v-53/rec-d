import 'dart:convert';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/homepage/bookmarks/bookmarks_screen.dart';
import 'package:recd/pages/homepage/explore/explore_screen.dart';
import 'package:recd/pages/homepage/home/home_screen.dart';
import 'package:recd/pages/homepage/profile/profile_screen.dart';
import 'package:recd/pages/homepage/trending/trending_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BottomBarController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  bool internet = true;

  final List<Widget> children = [
    HomeScreen(),
    TrendingScreen(),
    ExploreScreen(),
    BookMarksScreen(),
    ProfileScreen()
  ];

  void setIndex(i) => setState(() => index = i);

  void changeTabValue(value) => setState(() => index = value);

  void checkInternet(BuildContext context) async {
    bool net = await _isInternet();
    net
        ? setState(() => internet = true)
        : scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("No Internet !!!"),
                  Icon(
                    Icons.error,
                  ),
                ],
              ),
            ),
          );
  }

  List<Category> movieCategoryList = [];

  Future<List<Category>> fetchCategory(String type) async {
    try {
      List<Category> mylist = [];
      String url = Global.tmdbApiBaseUrl +
          '/3/genre/$type/list?api_key=${Global.apiKey}';
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        res['genres'].forEach((value) {
          Category cat = Category(
              categoryId: value['id'],
              categoryName: value['name'],
              categoryImage: "imagepath");
          setState(() => mylist.add(cat));
        });

        return mylist;
      } else if (response.statusCode == 400) {
        toast('Something went wrong');

        return null;
      } else {
        toast('Something went wrong');
        return null;
      }
    } catch (e) {
      toast('Something went wrong');
      log('$e');
      return null;
    }
  }

  Future<List<Category>> fecthPodcastCategory() async {
    try {
      List<Category> mylist = [];
      String url = "${Global.podcastApiBaseUrl}${API.PODCAST_CATEGORY}";
      final response = await http.get(url,
          headers: {"${PrefsKey.PODCAST_HEADER}": "${Global.podcastToken}"});
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        print(response.body);
        res['genres'].forEach((value) {
          Category cat = Category(
              categoryId: value['id'],
              categoryName: value['name'],
              categoryImage: "imagepath");
          setState(() => mylist.add(cat));
        });
        return mylist;
      } else if (response.statusCode == 400) {
        toast('Something went wrong');
        return null;
      } else {
        // toast('Something went wrong');
        return null;
      }
    } catch (e) {
      toast('Something went wrong');
      log('$e');
      return null;
    }
  }

  Future<bool> _isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (await DataConnectionChecker().hasConnection) {
        return Future<bool>.value(true);
      } else {
        return Future<bool>.value(false);
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (await DataConnectionChecker().hasConnection) {
        return Future<bool>.value(true);
      } else {
        return Future<bool>.value(false);
      }
    } else {
      return Future<bool>.value(false);
    }
  }
}

setSP(SharedPreferences prefs) {
  prefs.setString(General.ANDROID_LINK, "https://play.google.com/store/apps");
  prefs.setString(General.IOS_LINK, "https://www.apple.com/app-store/");
}
