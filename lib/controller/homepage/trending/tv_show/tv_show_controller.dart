import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:recd/model/group/group.dart';
import 'package:recd/model/tv_show/tv_show_model.dart';
import 'package:http/http.dart' as http;
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/tvshow_repo/tvshow_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TvShowController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0);
  int total = 0;
  bool isRated = false;
  ViewTvShow tvShowDetails;
  List<RelatedRecsModel> relatedRec = [];
  List<TvShows> relatedTvShows = [];
  FToast fToast;

  final where =
      "https://www.eastbaytimes.com/wp-content/uploads/2017/01/netflix_logo_digitalvideo_0701.jpg";

  iniFunc({dynamic value, BuildContext context}) async {
    isInternet().then((internet) {
      if (internet) {
        viewTvShow(value).then((details) {
          getStatusFunction(value).then((val) {
            fetchRelated(value).then((relatedMovie1) {
              setState(() {
                tvShowDetails = details;
                relatedTvShows = relatedMovie1;
              });
            });
          });
        });

        getRelatedRecd(value).then((details) {
          setState(() {
            relatedRec = details;
          });
        });
      } else {
        toast("No Internet !!!");
      }
    });
    fToast = FToast();
    fToast.init(context);
  }

  // ignore: missing_return
  Future viewTvShow(int tvShowId) async {
    http.Response response =
        await TvShowRepo().fetchMovieDetails(tvShowId).catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          ViewTvShow d = ViewTvShow();
          d.tvShowId = res['id'];
          d.tvShowImage = res['poster_path'];
          d.tvShowOverview = res['overview'];
          d.tvShowName = res['name'];
          d.tvShowCategory = res['genres'];
          return d;
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

  Future getStatusFunction(movieId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = "${App.RECd_URL}api/v1/bookmark/get-bookmark-status";
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "authorization": "$token",
      },
      body: {"recd_type": "Tv Show", "id": "$movieId"},
    );

    if (response.statusCode == 200) {
      var res = json.decode(response.body);

      setState(() {
        isRated = res['data']['rating'];
      });
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
  }

  // ignore: missing_return
  Future<List<TvShows>> fetchRelated(int id) async {
    List<TvShows> list = [];
    http.Response response =
        await TvShowRepo().fetchRelatedMovies(id).catchError(
              (err) => err,
            );
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['results'].forEach((val) {
            TvShows related = TvShows(
              id: val['id'],
              image: val['poster_path'],
              category: val['genre_ids'],
              name: val['original_title'],
            );
            setState(() {
              list.add(related);
            });
          });
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

  Future<List<RelatedRecsModel>> getRelatedRecd(movieId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = "${App.RECd_URL}api/v1/recommendation/get-recommendation-list";
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "authorization": "$token",
      },
      body: {"recd_type": "Tv Show", "id": "$movieId"},
    );
    List<RelatedRecsModel> cList = [];
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      setState(() {
        total = res['data']['totalRecd'];
      });
      res['data']['conversations'].forEach((res) {
        if (res != null) {
          RelatedRecsModel con = RelatedRecsModel(
            id: res['_id'],
            title: res['message']['conversation']['is_group'] == true
                ? res['message']['conversation']['group_name']
                : res['message']['conversation']['members']['name'],
            image: res['message']['conversation']['is_group'] == true
                ? res['message']['conversation']['group_cover_path']
                : res['message']['conversation']['members']['profile_path'],
          );
          setState(() {
            cList.add(con);
          });
        }
      });

      return cList;
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
  }
}
