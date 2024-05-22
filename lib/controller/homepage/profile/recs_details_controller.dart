import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:recd/model/group/group.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/profile/profile_repo.dart';
import 'package:recd/elements/helper.dart';

class RecsDetailsController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController pageScroll = ScrollController();
  List<RecsDetailsModel> recsList = [];
  int page = 1;
  bool isRecsLoading = false;
  bool isPaginationLoading = false;
  bool isPageLoadingStop = false;

  Future<List<RecsDetailsModel>> fetchAllRecs(int page) async {
    List<RecsDetailsModel> cList = [];
    Response response =
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
          if (res['data'] == null || res['data'].length == 0)
            setState(() => isPageLoadingStop = true);
          return cList;
        } catch (e) {
          setState(() {
            isRecsLoading = false;
            isPageLoadingStop = true;
          });
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        setState(() {
          isRecsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() {
          isRecsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      } else {
        setState(() {
          isRecsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() {
        isRecsLoading = false;
        isPageLoadingStop = true;
      });
      toast("Something went wrong");
      return null;
    }
  }
}
