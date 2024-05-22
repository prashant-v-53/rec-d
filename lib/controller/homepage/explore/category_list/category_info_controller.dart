import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/model/movie/view_movie.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/view/view_repo.dart';
import 'package:http/http.dart' as http;

class CategoryInfoController extends BaseController {
  final GlobalKey<ScaffoldState> scafffoldKey = GlobalKey<ScaffoldState>();

  int page = 1;
  String appBarTitle = "";

  bool isDataLoading = false;
  List<SeeAllData> info = [];

  ScrollController pageScroll = ScrollController();

  //* fetch category data
  Future<List<SeeAllData>> fetchCategoryData(
      {String type, String catId, int page}) async {
    List<SeeAllData> list = [];
    http.Response response = await ViewItemRepo()
        .fetchCategoryDataRepo(categoryId: catId, itemType: type, page: page);

    if (response != null) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);

        res['results'].forEach((val) {
          SeeAllData cat = SeeAllData(
            id: val['id'].toString(),
            image: val['poster_path'],
            title: type == "tv" ? val['original_name'] : val['title'],
            releaseDate: type == "tv"
                ? val.containsKey('first_air_date')
                    ? val['first_air_date']
                    : ""
                : val.containsKey('release_date')
                    ? val['release_date']
                    : "",
            category: val['genre_ids'],
            itemtype: type == "tv" ? "Tv Show" : "Movie",
          );
          setState(() => list.add(cat));
        });
        return list;
      } else if (response.statusCode == 400) {
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
