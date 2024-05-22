import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/auth/auth_repo.dart';
import 'package:recd/repository/notification/notification_repo.dart';
import 'package:recd/repository/profile/profile_repo.dart';

class ViewProfileController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserModel viewProfileList;
  bool isLoading = false;
  bool isRequestLoading = false;
  bool addFriendFlag = false;
  bool afterSentFriendRequest = false;

  Future getUserDetails(String id) async {
    setState(() => isLoading = true);
    http.Response response =
        await AuthRepo().getUserProfile(id).catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          if (res['data'] != null) {
            return new UserModel(
                id: res['data']['_id'].toString(),
                name: res['data']['name'].toString(),
                username: res['data']['userName'].toString(),
                profile: res['data']['profile_path'].toString(),
                recs: res['data']['recs'].toString(),
                friends: res['data']['friends'].toString(),
                groups: res['data']['groups'].toString(),
                isMyFriend: res['data']['is_my_friend'],
                isRequestPending: res['data']['is_request_pending'],
                isRequestSendedByMe: res['data']['is_request_sended_by_me'],
                flag: false,
                bio: res['data']['bio'] == null
                    ? ' '
                    : res['data']['bio'].toString());
          }
          return null;
        } catch (e) {
          setState(() => isLoading = false);
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        setState(() => isLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() => isLoading = false);
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() => isLoading = false);
      toast("Something went wrong");
      return null;
    }
  }

  Future sendAcceptRejectRequest({String id, String type}) async {
    http.Response response = await NotificationRepo()
        .acceptRejectRequest(id: id, type: type)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        if (res['message'] == "Friend request rejected") {
          return false;
        } else if (res['message'] == "Friend request accepted") {
          return true;
        } else {
          return true;
        }
      } else if (response.statusCode == 422) {
        setState(() => isRequestLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isRequestLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() => isRequestLoading = false);
        toast("Something went wrong");
        return null;
      } else {
        setState(() => isRequestLoading = false);
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() => isRequestLoading = false);
      toast("Something went wrong");
      return null;
    }
  }

  Future<bool> sendFriendRequest(String id) async {
    http.Response response =
        await ProfileRepo().sendFriendRequest(id).catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 422) {
        setState(() => addFriendFlag = false);
        toast("Something went wrong");
        return false;
      } else if (response.statusCode == 401) {
        setState(() => addFriendFlag = false);
        toast("${App.unauthorized}");
        return false;
      } else if (response.statusCode == 500) {
        setState(() => addFriendFlag = false);
        toast("Something went wrong");
        return false;
      } else {
        setState(() => addFriendFlag = false);
        toast("Something went wrong");
        return false;
      }
    } else {
      setState(() => addFriendFlag = false);
      toast("Something went wrong");
      return false;
    }
  }
}
