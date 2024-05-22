import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:recd/model/notification/notification.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/notification/notification_repo.dart';
import 'package:recd/elements/helper.dart';

class NotificationController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController pageScroll = ScrollController();
  int page = 1;
  bool isPaginationLoading = false;
  bool isRecsLoading = false;
  List<NotificationModel> notificationList = [];

  Future<List<NotificationModel>> fetchNotificationRecs(int page) async {
    List<NotificationModel> cList = [];
    Response response = await NotificationRepo()
        .fetchNotificationDetails(page)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        res['data'].forEach((res) {
          NotificationModel con = NotificationModel(
              id: res['_id'],
              notificationType: res['notification_type'],
              conversationId: res['conversation'] != null
                  ? res['conversation'].containsKey('_id')
                      ? res['conversation']['_id']
                      : "0"
                  : "0",
              conversationTitle: res['conversation'] != null
                  ? res['conversation'].containsKey('is_group')
                      ? res['conversation']['is_group'] == true
                          ? res['conversation']['group_name']
                          : res['conversation']['members']['name']
                      : "N/A"
                  : "N/A",
              isGroupCreatedByYou: res['conversation'] != null
                  ? res['conversation'].containsKey('isGroupCreatedByYou')
                      ? res['conversation']['isGroupCreatedByYou']
                      : false
                  : false,
              isGroup: res['conversation'] != null
                  ? res['conversation'].containsKey('is_group')
                      ? res['conversation']['is_group']
                      : false
                  : false,
              title: res['text'],
              profileImage: res['sender']['profile_path'],
              humanDate: res['createdAt'],
              userName: res['sender']['name'],
              userId: res['sender']['_id'],
              flag: false,
              itemType:
                  res['recd'] != null ? res['recd']['category']['name'] : "",
              isRequestPending: res['sender']['is_request_pending'],
              titleImage: res['recd'] != null
                  ? res['recd'].containsKey('listennotes_data')
                      ? res['recd']['listennotes_data']['image']
                      : res['recd'].containsKey('tmdb_data')
                          ? "${Global.tmdbImgBaseUrl}"
                              "${res['recd']['tmdb_data']['poster_path']}"
                          : res['recd'].containsKey('googlebooks_data')
                              ? res['recd']['googlebooks_data']['volumeInfo']
                                  ['imageLinks']['thumbnail']
                              : Global.staticRecdImageUrl
                  : Global.staticRecdImageUrl,
              itemId: res['recd'] != null
                  ? res['recd']['category']['name'] == "Movie" ||
                          res['recd']['category']['name'] == "Tv Show"
                      ? res['recd']['tmdb_data']['id'].toString()
                      : res['recd']['category']['name'] == "Book"
                          ? res['recd']['googlebooks_data']['id']
                          : res['recd']['category']['name'] == "Podcast"
                              ? res['recd']['listennotes_data']['id']
                              : "0"
                  : "0");
          setState(() => cList.add(con));
        });
        return cList;
      } else if (response.statusCode == 422) {
        setState(() => isRecsLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        toast("${App.unauthorized}");
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

  Future sendAcceptRejectRequest({String id, String type}) async {
    Response response = await NotificationRepo()
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
        setState(() => isRecsLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        toast("${App.unauthorized}");
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
}
