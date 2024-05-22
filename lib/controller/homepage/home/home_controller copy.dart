import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';

import 'package:recd/model/group/group.dart';
import 'package:http/http.dart' as http;
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/conversation_repo.dart';
import 'package:recd/elements/helper.dart';

class NewHomeController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isInternet = false;
  bool isLoading = false;
  ScrollController pageController = ScrollController();
  List<ConversationModel> conList;
  int page = 1;

  Future<List<ConversationModel>> fetchConversation(page) async {
    try {
      List<ConversationModel> cList = [];
      http.Response response =
          await ConversationRepo.getHomeConversations(page, false);
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
                userName: res['lastMessage']['created_by']['name'],
                isGroupCreatedByYou: res['isGroupCreatedByMe'],
              );
              setState(() => cList.add(con));
            } else {
              ConversationModel con = ConversationModel(
                id: res['_id'],
                userId: res['conversation']['members']['_id'],
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
                userName: res['lastMessage']['created_by']['name'],
              );
              setState(() => cList.add(con));
            }
          });
        }
        return cList;
      } else if (response.statusCode == 400) {
        setState(() => isLoading = false);
        toast("Something went wrong");
        return null;
      } else {
        setState(() => isLoading = false);
        toast("Something went wrong");
        return null;
      }
    } catch (e) {
      setState(() => isLoading = false);
      toast("Something went wrong");
      log('$e');
      return null;
    }
  }
}
