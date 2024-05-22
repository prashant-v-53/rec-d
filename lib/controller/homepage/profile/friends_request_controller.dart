import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/profile/profile_repo.dart';

class FriendRequestController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController pageScroll = ScrollController();
  List<UserModel> friendsList = [];
  bool isFriendsLoading = false;
  bool isPaginationLoading = false;

  int page = 1;
  String searchData = "";
  String text = "Pending";

  Future<List<UserModel>> fetchAllFriends(
      {int page, String searchQuery}) async {
    List<UserModel> list = [];
    Response response = await ProfileRepo()
        .fetchNoFriendList(page: page, searchQuery: searchQuery)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach((val) {
            UserModel related = new UserModel(
              id: val['_id'],
              name: val['name'],
              username: val['userName'],
              profile: val['profile_path'],
              isRequestPending: val['is_request_pending'],
              isRespondPending: val['is_respond_pending'],
              flag: false,
            );
            setState(() => list.add(related));
          });
          return list;
        } catch (e) {
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        setState(() => isFriendsLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() => isFriendsLoading = false);
        toast("Something went wrong");
        return null;
      } else {
        setState(() => isFriendsLoading = false);
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() => isFriendsLoading = false);
      toast("Something went wrong");
      return null;
    }
  }

  Future<bool> sendFriendRequest(String id) async {
    Response response =
        await ProfileRepo().sendFriendRequest(id).catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 422) {
        setState(() => isFriendsLoading = false);
        toast("Something went wrong");
        return false;
      } else if (response.statusCode == 401) {
        setState(() => isFriendsLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() => isFriendsLoading = false);
        toast("Something went wrong");
        return false;
      } else {
        setState(() => isFriendsLoading = false);
        toast("Something went wrong");
        return false;
      }
    } else {
      setState(() => isFriendsLoading = false);
      toast("Something went wrong");
      return false;
    }
  }
}
