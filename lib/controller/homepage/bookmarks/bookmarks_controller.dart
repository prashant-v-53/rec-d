import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:recd/model/bookmark/bookmark.dart';
import 'package:recd/model/bookmark/bookmark_details_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/bookmark/bookmark_repo.dart';
import 'package:http/http.dart' as http;

class BookMarksController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<BookMarkDetails> allBookMarks = [];
  List<Bookmark> bookmarkData = [];
  ScrollController pageScroller = ScrollController();

  bool isAllDataLoading = true;
  bool removeLoading = false;
  bool isPageLoading = false;

  int page = 1;
  int index = 0;
  String searchData = "";

  Future<List<BookMarkDetails>> getAllBookmarks(
      {int page, String search}) async {
    List<BookMarkDetails> list = [];
    http.Response response = await BookMarkRepo()
        .fetchAllBookmarks(page: page, searchQuery: search)
        .catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach(
            (val) {
              var bookmarImage, typeId;
              if (val['bookmark']['category']['name'] == 'Movie' ||
                  val['bookmark']['category']['name'] == 'Tv Show') {
                bookmarImage = val['bookmark']['tmdb_data'] != null
                    ? val['bookmark']['tmdb_data']['poster_path']
                    : Global.staticRecdImageUrl;
                typeId = val['bookmark']['tmdb_data'] != null
                    ? val['bookmark']['tmdb_data']['id'].toString()
                    : "0";
              } else if (val['bookmark']['category']['name'] == 'Podcast') {
                bookmarImage = val['bookmark']['listennotes_data'] != null
                    ? val['bookmark']['listennotes_data']['image']
                    : Global.staticRecdImageUrl;
                typeId = val['bookmark']['listennotes_data'] != null
                    ? val['bookmark']['listennotes_data']['id']
                    : "0";
              } else if (val['bookmark']['category']['name'] == 'Book') {
                bookmarImage = val['bookmark']['googlebooks_data'] != null
                    ? val['bookmark']['googlebooks_data']['volumeInfo']
                        ['imageLinks']['thumbnail']
                    : Global.staticRecdImageUrl;
                typeId = val['bookmark']['googlebooks_data'] != null
                    ? val['bookmark']['googlebooks_data']['id']
                    : "0";
              }

              BookMarkDetails bookmark = BookMarkDetails(
                id: val['_id'],
                bookmarkName: val['bookmark']['title'],
                bookmarkImage: bookmarImage,
                type: val['bookmark']['category']['name'],
                typeId: typeId,
                recdBy: val['recd_by']['data'],
                totalUsers: val['recd_by']['totalData'],
              );

              setState(() => list.add(bookmark));
            },
          );
          return list;
        } catch (e) {
          setState(() {
            isAllDataLoading = false;
            isPageLoading = true;
          });
          toast("Something went wrong");
          return null;
        }
      } else if (response.statusCode == 422) {
        setState(() {
          isAllDataLoading = false;
          isPageLoading = true;
        });
        return null;
      } else if (response.statusCode == 401) {
        setState(() {
          isAllDataLoading = false;
          isPageLoading = true;
        });
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() {
          isAllDataLoading = false;
          isPageLoading = true;
        });
        return null;
      } else {
        setState(() {
          isAllDataLoading = false;
          isPageLoading = true;
        });
        return null;
      }
    } else {
      setState(() {
        isAllDataLoading = false;
        isPageLoading = true;
      });
      return null;
    }
  }

  Future<List<BookMarkDetails>> removeBookMark(
      {String bookmarkId, int index}) async {
    List<BookMarkDetails> list = [];
    http.Response response = await BookMarkRepo()
        .removeUnCategorizedBookmark(bookmarkId)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          if (res['status'] == 1) {
            setState(() {
              removeLoading = false;
              allBookMarks.removeAt(index);
            });
          }
          return list;
        } catch (e) {
          toast("Something went wrong");
          setState(() => isAllDataLoading = false);
          return null;
        }
      } else if (response.statusCode == 422) {
        toast("Something went wrong");
        setState(() => isAllDataLoading = false);
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isAllDataLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast("Something went wrong");
        setState(() => isAllDataLoading = false);
        return null;
      } else {
        toast("Something went wrong");
        setState(() => isAllDataLoading = false);
        return null;
      }
    } else {
      toast("Something went wrong");
      setState(() => isAllDataLoading = false);
      return null;
    }
  }

  Future<List<BookMarkDetails>> removeBookMarkList(
      {String bookmarkId, int index}) async {
    List<BookMarkDetails> list = [];
    http.Response response =
        await BookMarkRepo().removeBList(bookmarkId).catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          if (res['status'] == 1) {
            setState(() {
              removeLoading = false;
              bookmarkData.removeAt(index);
            });
          }
          return list;
        } catch (e) {
          toast("Something went wrong");
          setState(() => isAllDataLoading = false);
          return null;
        }
      } else if (response.statusCode == 422) {
        toast("Something went wrong");
        setState(() => isAllDataLoading = false);
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isAllDataLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast("Something went wrong");
        setState(() => isAllDataLoading = false);
        return null;
      } else {
        toast("Something went wrong");
        setState(() => isAllDataLoading = false);
        return null;
      }
    } else {
      toast("Something went wrong");
      setState(() => isAllDataLoading = false);
      return null;
    }
  }

  Future<List<Bookmark>> getBookmarks() async {
    List<Bookmark> list = [];
    http.Response response =
        await BookMarkRepo().fetchBookmarks().catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
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
}
