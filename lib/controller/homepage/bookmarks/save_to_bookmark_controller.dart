import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/bookmark/bookmark.dart';
import 'package:http/http.dart' as http;
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/bookmark/bookmark_repo.dart';

class SaveToBookmarkController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;
  bool isSaveLoading = false;
  bool isOnSkipLoading = false;
  bool checked = false;
  int selectedItem = 0;

  List<BookmarkList> bookMarkData = [];
  List<String> selectedIdList = [];

  String bookmarkType = '';
  String entityId = '';

  Future<List<Bookmark>> getBookmarks() async {
    List<Bookmark> list = [];
    http.Response response =
        await BookMarkRepo().fetchBookmarks().catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach(
            (val) {
              Bookmark bookmark = Bookmark(
                bookmarkId: val['_id'],
                bookmarkName: val['title'],
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
      } else {
        toast("Something went wrong");
        return null;
      }
    } else {
      toast("Something went wrong");
      return null;
    }
  }

  Future<List<BookmarkList>> getBookmarks1() async {
    List<BookmarkList> list = [];
    http.Response response = await BookMarkRepo()
        .fetchBookmarks1(type: '$bookmarkType', id: entityId)
        .catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);

          res['data'].forEach(
            (val) {
              BookmarkList bookmark = BookmarkList(
                bookmarkId: val['_id'],
                bookmarkTitle: val['title'],
                bookmarkDesc: val['description'],
                isBookmarked: val['is_bookmarked'],
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
      } else {
        toast("Something went wrong");
        return null;
      }
    } else {
      toast("Something went wrong");
      return null;
    }
  }

  checkClick(String id) {
    if (id != null) {
      if (selectedIdList.contains(id)) {
        selectedIdList.remove(id);
        selectedItem = selectedItem - 1;
      } else {
        selectedItem = selectedItem + 1;
        selectedIdList.add(id);
      }
    }

    setState(() {});
  }

  Future onSubmit({data}) async {
    setState(() => isSaveLoading = true);
    http.Response response = await BookMarkRepo()
        .saveBookmarkToCollection(map: data)
        .catchError((err) => err);

    if (response != null) {
      setState(() => isSaveLoading = false);
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        List list = res['data'];
        if (list.isEmpty) {
          return false;
        } else {
          return true;
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

  Future onSkip({data}) async {
    setState(() => isOnSkipLoading = true);
    http.Response response = await BookMarkRepo()
        .unCategorizedBookmark(map: data)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        var list = res['data'];
        setState(() => isOnSkipLoading = false);
        if (list.isEmpty) {
          return false;
        } else {
          return true;
        }
      } else if (response.statusCode == 422) {
        toast("Something went wrong");
        setState(() => isOnSkipLoading = false);
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isOnSkipLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast("Something went wrong");
        setState(() => isOnSkipLoading = false);
        return null;
      } else {
        toast("Something went wrong");
        setState(() => isOnSkipLoading = false);
        return null;
      }
    } else {
      toast("Something went wrong");
      setState(() => isOnSkipLoading = false);
      return null;
    }
  }
}
