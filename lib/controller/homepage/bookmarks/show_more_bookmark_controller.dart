import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/bookmark/bookmark.dart';
import 'package:http/http.dart' as http;
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/bookmark/bookmark_repo.dart';

class ShowMoreBookmarkController extends BaseController {
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  List<Bookmark> bookMarkData = [];
  bool isLoading = true;

  // ignore: missing_return
  Future<List<Bookmark>> getBookmarks() async {
    List<Bookmark> list = [];
    http.Response response = await BookMarkRepo().fetchBookmarks().catchError(
          (err) => err,
        );
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach(
            (val) {
              Bookmark bookmark = Bookmark(
                bookmarkId: val['_id'],
                bookmarkName: val['title'],
                numberOfReco: val['bookmarks'],
                bookmarkImg: val['bookmark_cover_path'],
              );
              setState(() => list.add(bookmark));
            },
          );
          return list;
        } catch (e) {
          return null;
        }
      } else if (response.statusCode == 422) {
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast("Something went wrong");
        return null;
      }
    } else {
      toast("Something went wrong");
      return null;
    }
  }
}
