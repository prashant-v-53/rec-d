import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/model/movie/view_movie.dart';
import 'package:http/http.dart' as http;
import 'package:recd/model/related_recd.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/recd_repo/recd_repo.dart';

class SeeAllController extends BaseController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int page = 1;

  bool isInternet;
  bool isLoading = false;
  bool isDataLoaded = true;
  bool isRecdByLoading = true;
  bool isPageLoading = true;
  bool isRecdByLazyLoading = true;

  String type = "movie";
  String trendingType = "day";

  List<SeeAllData> movieList = [];
  List<RelatedRecs> recdBy = [];

  ScrollController movieScrollController = ScrollController();

  Future<List<SeeAllData>> fetchMovie(dynamic pram) async {
    List<SeeAllData> mList = [];
    setState(() => isLoading = true);
    String url =
        "${Global.tmdbApiBaseUrl}/3/${pram[1]}/${pram[2]}?api_key=${Global.apiKey}&language=en-US&page=$page";
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      setState(() => isLoading = false);
      res['results'].forEach((val) {
        SeeAllData movie = SeeAllData(
            id: val['id'].toString(),
            title: pram[1] == "tv" ? val['name'] : val['title'],
            category: val['genre_ids'],
            image: val['poster_path'],
            isRecdLoading: true);
        setState(() => mList.add(movie));
      });
      setState(() => page++);
      return mList;
    } else if (response.statusCode == 400) {
      toast("Something went wrong");
      setState(() => isLoading = false);
      return null;
    } else {
      setState(() => isLoading = false);
      toast("Something went wrong");
      return null;
    }
  }

  lazyLoadingListner(dynamic param) {
    movieScrollController.addListener(() {
      if (movieScrollController.position.pixels ==
          movieScrollController.position.maxScrollExtent) {
        setState(() => isPageLoading = true);

        fetchMovie(param).then((value) {
          setState(() {
            isRecdByLazyLoading = true;
            movieList.addAll(value);
          });
          getRelatedRecs(info: value, type: param[1]).then((val) {
            setState(() {
              recdBy.addAll(val);
              isRecdByLazyLoading = false;
            });
          });
          setState(() => isPageLoading = false);
        });
      }
    });
  }

  Future<List<RelatedRecs>> getRelatedRecs(
      {String type, List<SeeAllData> info}) async {
    List<RelatedRecs> relatedRECs = [];
    List itemIds = [];

    for (var i = 0; i < info.length; i++) {
      itemIds.add("${info[i].id}");
    }

    http.Response response =
        await RecdRepo().fetchRelatedRecs(type: "$type", ids: itemIds);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        res['data'].forEach((val) {
          RelatedRecs obj = RelatedRecs(
            recId: val['id'].toString(),
            recdUser: val['recds']['fewRecd'],
            totalRecs: val['recds']['totalRecd'],
            isLoading: true,
          );
          setState(() => relatedRECs.add(obj));
        });
        return relatedRECs;
      } else {
        setState(() => isRecdByLoading = false);
        toast("Something went wrong");
        return null;
      }
    } else if (response.statusCode == 400) {
      setState(() => isRecdByLoading = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 422) {
      setState(() => isRecdByLoading = false);
      toast("Something went wrong");
      return null;
    } else {
      setState(() => isRecdByLoading = false);
      toast("Something went wrong");
      return null;
    }
  }
}
