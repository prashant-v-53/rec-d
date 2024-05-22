import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/profile/profile_repo.dart';

class RecdByFriendsController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController pageScroll = ScrollController();
  List<UserModel> friendsList = [];
  int page = 1;
  bool isFriendsLoading = false;
  bool isPaginationLoading = false;

  // ignore: missing_return
  Future<List<UserModel>> fetchRecdyFriends(
      {String id, String type, int page}) async {
    List<UserModel> list = [];

    Response response = await ProfileRepo()
        .fetchRecdFriendsList(id: id, type: type, page: page)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach((val) {
            UserModel related = new UserModel(
                id: val['created_by']['_id'],
                name: val['created_by']['name'],
                username: val['created_by']['userName'],
                profile: val['created_by']['profile_path']);
            setState(() {
              list.add(related);
            });
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
      }
    } else {
      setState(() => isFriendsLoading = false);
      toast("Something went wrong");
      return null;
    }
  }
}
