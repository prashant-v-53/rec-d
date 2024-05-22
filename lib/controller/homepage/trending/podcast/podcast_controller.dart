import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';

import 'package:recd/model/group/group.dart';
import 'package:recd/model/podcast/podcast_model.dart';
import 'package:http/http.dart' as http;
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/podcast_repo/podcast_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PodCastController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0);

  ViewPodCast podCastDetails;
  List<PodcastModel> relatedPodCast = [];
  FToast fToast;
  bool isRated = false;
  int total = 0;
  List<RelatedRecsModel> relatedRec = [];

  final where =
      "https://www.eastbaytimes.com/wp-content/uploads/2017/01/netflix_logo_digitalvideo_0701.jpg";

  iniFunc({dynamic value, BuildContext context}) async {
    isInternet().then((internet) {
      if (internet) {
        viewPodcast(value).then((details) {
          getStatusFunction(value).then((val) {
            fetchRelated(value).then((relatedMovie1) {
              setState(() {
                podCastDetails = details;
                relatedPodCast = relatedMovie1;
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

  Future getStatusFunction(podcastId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = "${App.RECd_URL}api/v1/bookmark/get-bookmark-status";
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "authorization": "$token",
      },
      body: {"recd_type": "Podcast", "id": "$podcastId"},
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
  Future viewPodcast(String podCastId) async {
    http.Response response = await PodcastRepo()
        .fetchPodCast(podCastId: podCastId)
        .catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          ViewPodCast d = ViewPodCast();
          d.podCastId = res['id'];
          d.podCastImage = res['image'];
          d.podCastOverview = res['description'];
          d.podCastName = res['title'];
          d.podCastCategory = res['genre_ids'];
          return d;
        } catch (e) {
          return null;
        }
      } else if (response.statusCode == 422) {
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        toast("Podcast currently unavailable ");
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

  // ignore: missing_return
  Future<List<PodcastModel>> fetchRelated(String id) async {
    List<PodcastModel> list = [];
    http.Response response = await PodcastRepo()
        .fetchRelatedPodcast(podCastId: id)
        .catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['recommendations'].forEach((val) {
            PodcastModel related = PodcastModel(
              podCastId: val['id'],
              podCastImage: val['thumbnail'],
              category: val['genre_ids'],
              podCastName: val['title'],
            );
            setState(() {
              list.add(related);
            });
          });
          return list;
        } catch (e) {
          log('$e');
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
      body: {"recd_type": "Podcast", "id": "$movieId"},
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
