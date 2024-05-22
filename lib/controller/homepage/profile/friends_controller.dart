import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/profile/profile_repo.dart';

class FriendsController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController pageScroll = ScrollController();
  List<UserModel> friendsList = [];
  bool isFriendsLoading = false;
  bool isPaginationLoading = false;
  bool isPageLoadingStop = false;

  int page = 1;
  String searchData = "";

  Future<List<UserModel>> fetchAllFriends(
      {int page, String searchQuery, String userId}) async {
    List<UserModel> list = [];

    Response response = await ProfileRepo()
        .fetchFriendsDetails(
            page: page, searchQuery: searchQuery, userId: userId)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach((val) {
            UserModel related = new UserModel(
                id: val['members']['_id'],
                name: val['members']['name'],
                username: val['members']['userName'],
                profile: val['members']['profile_path']);
            setState(() => list.add(related));
          });
          if (res['data'] == null || res['data'].length == 0)
            setState(() => isPageLoadingStop = true);
          return list;
        } catch (e) {
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        setState(() {
          isFriendsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        setState(() {
          isFriendsLoading = false;
          isPageLoadingStop = true;
        });
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() {
          isFriendsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      } else {
        setState(() {
          isFriendsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() {
        isFriendsLoading = false;
        isPageLoadingStop = true;
      });
      toast("Something went wrong");
      return null;
    }
  }
}
