import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/model/movie/view_movie.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/search/serach_repo.dart';

class SearchController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<NavigatorState> key = GlobalKey();

  bool isLoading = false;
  int page = 0;
  int bookPage = 0;
  int podcastPage = 0;

  var searchController = TextEditingController(text: "");
  List<SeeAllData> searchList = [];
  bool isInternet = false;
  bool isDataLoaded = false;
  bool isPageLoadingStop = false;
  bool isBookPageLoading = false;
  bool isPageLoading = false;

  ScrollController pageController = ScrollController();
  int filter = 1;
  String filterType;
  bool searchVisible = true;

  Future<List<SeeAllData>> fetchData({
    String searchData,
    String type,
    int page,
  }) async {
    List<SeeAllData> mList = [];
    http.Response response = await SearchItemRepo()
        .searchData(type: "$type", searchQuery: searchData, page: page);

    if (response != null) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);

        if (type == "movie" || type == "tv") {
          if (res['results'] != null && res['results'].length > 0)
            res['results'].forEach((val) {
              SeeAllData search = SeeAllData(
                  id: val['id'].toString(),
                  title: (type == "tv")
                      ? val['original_name']
                      : val.containsKey('title')
                          ? val['title']
                          : val['original_title'],
                  category: val['genre_ids'],
                  desc: val['overview'],
                  itemtype: type == "movie"
                      ? "Movie"
                      : type == "tv"
                          ? "Tv Show"
                          : "",
                  image: val.containsKey('poster_path')
                      ? val['poster_path'] != null
                          ? "${Global.tmdbImgBaseUrl}${val['poster_path']}"
                          : Global.staticRecdImageUrl
                      : Global.staticRecdImageUrl);

              setState(() {
                mList.add(search);
              });
            });
        } else if (type == "Podcast") {
          if (res['results'] != null)
            res['results'].forEach((val) {
              SeeAllData search = SeeAllData(
                id: val['id'],
                title: val['title_original'],
                itemtype: "Podcast",
                category: val['genre_ids'],
                desc: val['description_original'],
                image: val['image'],
              );
              setState(() {
                mList.add(search);
              });
            });
        } else if (type == "Book") {
          if (res['items'] != null)
            res['items'].forEach((val) {
              SeeAllData search = SeeAllData(
                  id: val['id'],
                  title: val['volumeInfo']['title'],
                  desc: val['volumeInfo']['description'],
                  itemtype: "Book",
                  category: val['volumeInfo'].containsKey('categories')
                      ? val['volumeInfo']['categories']
                      : [],
                  image: val['volumeInfo'].containsKey('imageLinks')
                      ? val['volumeInfo']['imageLinks'].containsKey('medium')
                          ? val['volumeInfo']['imageLinks']['medium'].toString()
                          : val['volumeInfo']['imageLinks']
                                  .containsKey('thumbnail')
                              ? val['volumeInfo']['imageLinks']['thumbnail']
                                  .toString()
                              : Global.staticRecdImageUrl
                      : Global.staticRecdImageUrl,
                  bookPublishedDate:
                      val['volumeInfo'].containsKey('publishedDate')
                          ? val['volumeInfo']['publishedDate']
                          : "");
              setState(() {
                mList.add(search);
              });
            });
        }
        if (res['results'] == null || res['results'].length == 0)
          setState(() => isPageLoading = false);
        return mList.toSet().toList();
      } else if (response.statusCode == 400) {
        toast("Something went wrong");
        setState(() => isLoading = false);
        return null;
      } else {
        toast("Something went wrong");
        setState(() => isLoading = false);
        return null;
      }
    } else {
      setState(() => isLoading = false);
      toast("Something went wrong");
      return null;
    }
  }
}
