import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recd/controller/auth/base_controller.dart';

import 'package:recd/model/conversation_message_model.dart';
import 'package:recd/repository/conversation_repo.dart';
import 'package:recd/elements/helper.dart';

class GroupRecommendedController extends BaseController {
  int page = 1;
  String userId = "";
  bool isLoading = false;
  bool isPageLoading = false;
  List<ConversationMessageModel> messagList = [];
  ScrollController pageController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<ConversationMessageModel>> getConversationMessages(
      String conversationId, int page) async {
    List<ConversationMessageModel> list = [];

    Response response =
        await ConversationRepo.getConversationMessagesApi(conversationId, page);
    if (response != null) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        res['data'].forEach((val) {
          setState(() => userId = val['created_by']['_id']);

          ConversationMessageModel msgData = ConversationMessageModel(
              id: val['_id'].toString(),
              image: val['created_by']['profile_path'],
              isMyMsg: val['isMyRecd'],
              msgStarCount: '0',
              username: val['created_by']['name'],
              userId: val['created_by']['_id'],
              msgTitle: val['message']['title'],
              msgSubTitle: val['message']['description'],
              itemType: val['message']['category']['name'],
              msgTime: val['createdAt'],
              avgRating: val['ratings'] == null
                  ? 0
                  : num.parse(val['ratings'].toStringAsFixed(1)),
              itemId: val['message']['category']['name'] == "Movie" ||
                      val['message']['category']['name'] == "Tv Show"
                  ? val['message']['tmdb_data']['id'].toString()
                  : val['message']['category']['name'] == "Book"
                      ? val['message']['googlebooks_data']['id']
                      : val['message']['category']['name'] == "Podcast"
                          ? val['message']['listennotes_data']['id']
                          : "0",
              msgImage: val['message'].containsKey('listennotes_data')
                  ? val['message']['listennotes_data']['image']
                  : val['message'].containsKey('tmdb_data')
                      ? "${Global.tmdbImgBaseUrl}"
                          "${val['message']['tmdb_data']['poster_path']}"
                      : val['message'].containsKey('googlebooks_data')
                          ? val['message']['googlebooks_data']['volumeInfo']
                              ['imageLinks']['thumbnail']
                          : Global.staticRecdImageUrl);
          setState(() => list.add(msgData));
        });

        return list;
      } else {
        setState(() => isLoading = false);
        return null;
      }
    } else {
      setState(() => isLoading = false);
      return null;
    }
  }
}
