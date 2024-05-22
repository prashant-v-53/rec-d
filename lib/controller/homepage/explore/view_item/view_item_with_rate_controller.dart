import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:http/http.dart' as http;
import 'package:recd/model/group/group.dart';
import 'package:recd/model/movie/view_movie.dart';
import 'package:recd/model/trending/movie.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewItemWithRateController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool isBookMarked = false;
  bool isRated = false;

  String notFoundmsg = "";

  final where =
      "https://www.eastbaytimes.com/wp-content/uploads/2017/01/netflix_logo_digitalvideo_0701.jpg";

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0);
  ViewMovie movieDetails;
  List<Movie> relatedMovie = [];
  List<RelatedRecsModel> relatedRec = [];
  FToast fToast;

  int total = 0;

  iniFunc({dynamic value, BuildContext context}) async {
    isInternet().then((internet) {
      if (internet) {
        fetchMovieDetails(value).then((details) {
          //* bookmark status api
          getStatusFunction(value).then((val) {
            fetchRelated(value).then((relatedMovie1) {
              setState(() {
                movieDetails = details;
                relatedMovie = relatedMovie1;
                isLoading = false;
              });
            });
          });
        });
        getRelatedRecd(value).then((details) {
          setState(() => relatedRec = details);
        });
      } else {
        toast("No Internet !!!");
      }
    });
    fToast = FToast();
    fToast.init(context);
  }

  Future fetchMovieDetails(int movieId) async {
    try {
      String url = Global.tmdbApiBaseUrl +
          "/3/movie/$movieId?api_key=${Global.apiKey}&language=en-US";

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var res = json.decode(response.body);

        ViewMovie d = new ViewMovie();
        d.movieId = res['id'];
        d.movieImage = res['poster_path'];
        d.overview = res['overview'];
        d.movieName = res['original_title'];
        d.category = res['genres'];

        return d;
      } else if (response.statusCode == 401) {
        setState(() => isLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() => isLoading = false);
      } else if (response.statusCode == 401) {
        setState(() => isLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 404) {
        var res = json.decode(response.body);
        setState(() => notFoundmsg = res['status_message']);
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<List<Movie>> fetchRelated(int id) async {
    List<Movie> rList = [];
    String url =
        "${Global.tmdbApiBaseUrl}/3/movie/$id/similar?api_key=${Global.apiKey}&language=en-US&page=1";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      res['results'].forEach((val) {
        Movie related = Movie(
          movieId: val['id'],
          movieImage: val['backdrop_path'],
          movieCategory: val['genre_ids'],
          movieTitle: val['original_title'],
        );
        setState(() {
          rList.add(related);
        });
      });
      return rList;
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
      body: {"recd_type": "Movie", "id": "$movieId"},
    );

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      setState(() => isRated = res['data']['rating']);
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

  Future<List<RelatedRecsModel>> getRelatedRecd(int movieId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = "${App.RECd_URL}api/v1/recommendation/get-recommendation-list";
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "authorization": "$token",
      },
      body: {"recd_type": "Movie", "id": "$movieId"},
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
