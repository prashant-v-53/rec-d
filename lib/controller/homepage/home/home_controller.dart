import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';

import 'package:recd/model/group/group.dart';
import 'package:http/http.dart' as http;
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/conversation_repo.dart';
import 'package:recd/elements/helper.dart';

class HomeController extends BaseController {
  GlobalKey<ScaffoldState> scaffoldKey;
  bool isInternet = false;
  bool isLoading = false;
  bool isPageLoadingStop = false;
  bool isPageLoading = false;
  ScrollController pageController;
  List<ConversationModel> conList;
  int page = 1;

  HomeController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    pageController = ScrollController();
  }

  Future<List<ConversationModel>> fetchConversation(page) async {
    List<ConversationModel> cList = [];
    http.Response response =
        await ConversationRepo.getHomeConversations(page, true);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        res['data'].forEach((res) {
          if (res['isGroup'] == true) {
            ConversationModel con = ConversationModel(
              id: res['_id'],
              isGroup: res['isGroup'],
              conImage: res['conversation']['group_cover_path'],
              title: res['conversation']['group_name'],
              lastMsgImage: res['lastMessage']['message']
                      .containsKey('listennotes_data')
                  ? res['lastMessage']['message']['listennotes_data']['image']
                  : res['lastMessage']['message'].containsKey('tmdb_data')
                      ? "${Global.tmdbImgBaseUrl}"
                          "${res['lastMessage']['message']['tmdb_data']['poster_path']}"
                      : res['lastMessage']['message']
                              .containsKey('googlebooks_data')
                          ? res['lastMessage']['message']['googlebooks_data']
                              ['volumeInfo']['imageLinks']['thumbnail']
                          : Global.staticRecdImageUrl,
              lastMsgTitle: res['lastMessage']['message']['title'],
              lastMsgSubTitle: res['lastMessage']['message']['description'],
              humanDate: res['lastMessage']['createdAt'],
              recdBy: res['recd_by'],
              isGroupCreatedByYou: res['isGroupCreatedByMe'],
              totalUsers: res['total_recd_by'],
              itemType: res['lastMessage']['message']['category']['name'],
              itemId: res['lastMessage']['message']['category']['name'] ==
                          "Movie" ||
                      res['lastMessage']['message']['category']['name'] ==
                          "Tv Show"
                  ? res['lastMessage']['message']['tmdb_data']['id'].toString()
                  : res['lastMessage']['message']['category']['name'] == "Book"
                      ? res['lastMessage']['message']['googlebooks_data']['id']
                      : res['lastMessage']['message']['category']['name'] ==
                              "Podcast"
                          ? res['lastMessage']['message']['listennotes_data']
                              ['id']
                          : "0",
            );
            setState(() => cList.add(con));
          } else {
            ConversationModel con = ConversationModel(
              id: res['_id'],
              userId: res['conversation']['members']['_id'],
              itemType: res['lastMessage']['message']['category']['name'],
              itemId: res['lastMessage']['message']['category']['name'] ==
                          "Movie" ||
                      res['lastMessage']['message']['category']['name'] ==
                          "Tv Show"
                  ? res['lastMessage']['message']['tmdb_data']['id'].toString()
                  : res['lastMessage']['message']['category']['name'] == "Book"
                      ? res['lastMessage']['message']['googlebooks_data']['id']
                      : res['lastMessage']['message']['category']['name'] ==
                              "Podcast"
                          ? res['lastMessage']['message']['listennotes_data']
                              ['id']
                          : "0",
              isGroup: res['isGroup'],
              isGroupCreatedByYou: res['isGroupCreatedByMe'],
              conImage: res['conversation']['members']['profile_path'],
              title: res['conversation']['members']['name'],
              lastMsgTitle: res['lastMessage']['message']['title'],
              lastMsgSubTitle: res['lastMessage']['message']['description'],
              humanDate: res['lastMessage']['createdAt'],
              lastMsgImage: res['lastMessage']['message']
                      .containsKey('listennotes_data')
                  ? res['lastMessage']['message']['listennotes_data']['image']
                  : res['lastMessage']['message'].containsKey('tmdb_data')
                      ? "${Global.tmdbImgBaseUrl}"
                          "${res['lastMessage']['message']['tmdb_data']['poster_path']}"
                      : res['lastMessage']['message']
                              .containsKey('googlebooks_data')
                          ? res['lastMessage']['message']['googlebooks_data']
                              ['volumeInfo']['imageLinks']['thumbnail']
                          : Global.staticRecdImageUrl,
            );
            setState(() => cList.add(con));
          }
        });
        if (res['data'] == null || res['data'].length == 0)
          setState(() => isPageLoadingStop = true);
      }
      return cList;
    } else if (response.statusCode == 400) {
      setState(() {
        isLoading = false;
        isPageLoadingStop = true;
      });
      toast("Something went wrong1");
      return null;
    } else if (response.statusCode == 401) {
      setState(() {
        isLoading = false;
        isPageLoadingStop = true;
      });
      toast("Unauthorized");
      return null;
    } else {
      setState(() {
        isLoading = false;
        isPageLoadingStop = true;
      });
      toast("Something went wrong2");
      return null;
    }
  }
}
