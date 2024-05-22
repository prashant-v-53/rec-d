import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/bookmark/bookmark_details_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/bookmark/bookmark_repo.dart';

class BookMarkDetailController extends BaseController {
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  List<BookMarkDetails> bookMarkData = [];
  bool isLoading = true;
  bool removeLoading = false;
  bool isUpdated = false;
  bool isPageLoading = false;

  ScrollController pageScroll = ScrollController();

  int page = 1;
  String searchData = "";
  Widget appBarTitle;

  Future<List<BookMarkDetails>> getBookmarksbyId(
      {String bookmarkid, int page, String query}) async {
    List<BookMarkDetails> list = [];
    http.Response response = await BookMarkRepo()
        .fetchBookmarksById(id: bookmarkid, page: page, searchQuery: query)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data']['bookmarks'].forEach(
            (val) {
              var rectBy = val['recd_by'];
              val = val['bookmark'];
              BookMarkDetails bookmark = BookMarkDetails(
                id: val['_id'],
                bookmarkName: val['title'],
                recdBy: rectBy['data'],
                totalUsers: rectBy['totalData'],
                bookmarkImage: val.containsKey('listennotes_data')
                    ? val['listennotes_data']['image']
                    : val.containsKey('tmdb_data')
                        ? "${Global.tmdbImgBaseUrl}"
                            "${val['tmdb_data']['poster_path']}"
                        : val.containsKey('googlebooks_data')
                            ? val['googlebooks_data']['volumeInfo']
                                ['imageLinks']['thumbnail']
                            : Global.staticRecdImageUrl,
                type: val['category']['name'],
                typeId: val.containsKey('listennotes_data')
                    ? val['listennotes_data']['id']
                    : val.containsKey('tmdb_data')
                        ? val['tmdb_data']['id'].toString()
                        : val.containsKey('googlebooks_data')
                            ? val['googlebooks_data']['id']
                            : "0",
              );
              setState(() => list.add(bookmark));
            },
          );
          return list;
        } catch (e) {
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        toast('Something went wrong');
        return null;
      } else if (response.statusCode == 401) {
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast('Something went wrong');
        return null;
      } else {
        toast('Something went wrong');
        return null;
      }
    } else {
      toast('Something went wrong');
      return null;
    }
  }

  Future<List<BookMarkDetails>> removeBookMark(
      {String bookmarkId, String recDId, int index}) async {
    List<BookMarkDetails> list = [];
    http.Response response = await BookMarkRepo()
        .removeBM(
          bmId: bookmarkId,
          recdId: recDId,
        )
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          if (res['status'] == 1) {
            setState(() {
              isUpdated = true;
              removeLoading = false;
              bookMarkData.removeAt(index);
            });
          }
          return list;
        } catch (e) {
          setState(() => isLoading = false);
          return null;
        }
      } else if (response.statusCode == 422) {
        toast('Something went wrong');
        setState(() => isLoading = false);
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast('Something went wrong');
        setState(() => isLoading = false);
        return null;
      } else {
        toast('Something went wrong');
        setState(() => isLoading = false);
        return null;
      }
    } else {
      setState(() => isLoading = false);
      toast('Something went wrong');
      return null;
    }
  }

  Future<bool> willPop() {
    print('s');
    return Future.value(true);
  }

  Widget getAppTitle(String title) {
    return new Text("$title",
        style: TextStyle(
            fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.black));
  }
}
