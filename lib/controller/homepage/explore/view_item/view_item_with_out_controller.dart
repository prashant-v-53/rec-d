import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/group/group.dart';
import 'package:recd/model/rate/rate_model.dart';
import 'package:recd/model/view_item.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/book/book_repo.dart';
import 'package:recd/repository/podcast_repo/podcast_repo.dart';
import 'package:recd/repository/tvshow_repo/tvshow_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewItemWithOutController extends BaseController {
  AlignmentGeometry alignment = Alignment.bottomLeft;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0);
  String whereToWatchImage = "";

  int tabIndex = 0;
  int totalRecd = 0;

  String isRated = "";
  String str1Title1 = "";
  String str2Title2 = "";
  String str3Title3 = "";

  bool hasError = false;
  bool isBookMarked = false;
  bool isRatingLoading = true;
  bool isViewItemLoading = false;
  bool isRecdByLoading = false;
  bool isWhereToWatchAvailable = false;

  ViewItem viewItems;
  TabController controller;

  List<ViewItem> relatedItems = [];
  List<RateDetails> ratingDetails = [];
  List<RelatedRecsModel> relatedRec = [];
  List<String> whereToWatch = [];

  setTab(int i) {
    if (tabIndex != i) {
      setState(() {
        tabIndex = i;
        if (i == 0) {
          alignment = Alignment.centerLeft;
        } else if (i == 1) {
          alignment = Alignment.centerRight;
        }
      });
    }
  }

  bookmarkStatusUpdate(Object result) => result != "no"
      ? setState(() => isBookMarked = true)
      : setState(() => isBookMarked = false);

  ratingStatusUpdate({Object result, String type, String id}) {
    if (result != "no") {
      if (controller.index == 1) {
        setState(() => isRated = "$result/5");
        fetchRatings(type: type, id: id).then((value) {
          setState(() {
            ratingDetails = value;
            isRatingLoading = false;
          });
        });
      } else {
        setState(() => isRated = "$result/5");
      }
    }
  }

  tabListner(String type, String id) async {
    controller.addListener(() {
      if (controller.index == 1) {
        if (ratingDetails.isEmpty) {
          setState(() => isRatingLoading = true);

          fetchRatings(type: type, id: id).then((value) {
            setState(() {
              ratingDetails = value;
              isRatingLoading = false;
            });
          });
        } else {
          setState(() => isRatingLoading = false);
        }
      }
    });
  }

  Future<List<RateDetails>> fetchRatings({String type, String id}) async {
    List<RateDetails> mylist = [];

    setState(() => isRatingLoading = true);
    String url = App.RECd_URL + '${API.GET_RATEING}';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(url,
        body: {"recd_type": "$type", "id": "$id"},
        headers: {"Accept": "application/json", "authorization": "$token"});

    if (response.statusCode == 200) {
      try {
        var res = json.decode(response.body);
        res['data'].forEach((value) {
          if (value['rated_by'] != null) {
            RateDetails rate = new RateDetails(
                id: value['_id'],
                name: value['rated_by']['name'],
                profileImage: value['rated_by']['profile_path'],
                userId: value['rated_by']['_id'],
                totalRating: value['rating'],
                updatedDate: value['updatedAt']);
            setState(() => mylist.add(rate));
          }
        });
        return mylist;
      } catch (e) {
        setState(() => isRatingLoading = false);
        return null;
      }
    } else if (response.statusCode == 400) {
      setState(() => isRatingLoading = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 401) {
      setState(() => isRatingLoading = false);
      toast("${App.unauthorized}");
      return null;
    } else if (response.statusCode == 500) {
      setState(() => isRatingLoading = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 404) {
      setState(() => isRatingLoading = false);
      toast("Something went wrong");
      return null;
    } else {
      setState(() => isRatingLoading = false);
      toast("Something went wrong");
      return null;
    }
  }

  Future fetchItems({String id, String type}) async {
    String url;
    http.Response response;

    if (type == "Movie") {
      url = Global.tmdbApiBaseUrl +
          "/3/movie/$id?api_key=${Global.apiKey}&language=en-US";
      response = await http.get(url);
    } else if (type == "Tv Show") {
      url = Global.tmdbApiBaseUrl +
          "/3/tv/$id?api_key=${Global.apiKey}&language=en-US";

      response = await http.get(url);
    } else if (type == "Podcast") {
      response = await PodcastRepo()
          .fetchPodCast(podCastId: id)
          .catchError((err) => err);
    } else if (type == "Book") {
      response = await BookRepo().fetchBook(id: id).catchError((err) => err);
    }

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      ViewItem obj;
      if (type == "Movie") {
        obj = new ViewItem(
          id: res['id'].toString(),
          image: res['poster_path'] == null
              ? Global.staticRecdImageUrl
              : "${Global.tmdbImgBaseUrl}${res['poster_path']}",
          name: res.containsKey('title') ? res['title'] : res['original_title'],
          overview: res['overview'],
          category: res['genres'],
          str1: res['runtime'].toString(),
          str2: res.containsKey('release_date')
              ? res['release_date'].toString()
              : "",
          str3: res['revenue'].toString(),
        );
        setState(() {
          str1Title1 = "Runtime";
          str2Title2 = "Release Year";
          str3Title3 = "Revenue";
        });
      } else if (type == "Tv Show") {
        List data = res['created_by'];

        obj = new ViewItem(
          id: res['id'].toString(),
          image: res['poster_path'] == null
              ? Global.staticRecdImageUrl
              : "${Global.tmdbImgBaseUrl}${res['poster_path']}",
          name: res['name'],
          overview: res['overview'],
          category: res['genres'],
          str1: res.containsKey('created_by')
              ? data.isNotEmpty
                  ? res['created_by'][0]['name']
                  : ""
              : "",
          str2: res['first_air_date'],
          str3: res['tagline'],
        );

        setState(() {
          str1Title1 = "Director";
          str2Title2 = "Release Year";
          str3Title3 = "Tag Line";
        });
      } else if (type == "Podcast") {
        obj = new ViewItem(
          id: res['id'],
          image:
              res['image'] == null ? Global.staticRecdImageUrl : res['image'],
          name: res['title'],
          overview: res['description'],
          category: res['genre_ids'],
          str1: "",
          str2: res['language'],
          str3: res['publisher'],
        );

        setState(() {
          str1Title1 = "";
          str2Title2 = "Language";
          str3Title3 = "Publisher";
        });
      } else if (type == "Book") {
        obj = new ViewItem(
          id: res['id'].toString(),
          name: res['volumeInfo']['title'].toString(),
          image: res['volumeInfo'].containsKey('imageLinks')
              ? res['volumeInfo']['imageLinks'].containsKey('thumbnail')
                  ? res['volumeInfo']['imageLinks']['thumbnail']
                  : res['volumeInfo']['imageLinks'].containsKey('medium')
                      ? res['volumeInfo']['imageLinks']['medium']
                      : Global.staticRecdImageUrl
              : Global.staticRecdImageUrl,
          overview: res['volumeInfo'].containsKey('description')
              ? res['volumeInfo']['description']
              : "",
          bookAutherName: res['volumeInfo'].containsKey('authors')
              ? res['volumeInfo']['authors']
              : [""],
          str1: "",
          str2: res['volumeInfo']['publishedDate'],
          str3: res['volumeInfo']['publisher'],
        );

        setState(() {
          str1Title1 = "";
          str2Title2 = "Published Date";
          str3Title3 = "Publisher";
        });
      } else {
        setState(() => hasError = true);
      }

      return obj;
    } else if (response.statusCode == 400) {
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 401) {
      toast("${App.unauthorized}");
      return null;
    } else if (response.statusCode == 500) {
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 404) {
      toast("Something went wrong");
      return null;
    } else {
      toast("Something went wrong");
      return null;
    }
  }

  Future<List<ViewItem>> fetchRelated({String type, String id}) async {
    List<ViewItem> rList = [];
    String url;
    http.Response response;
    if (type == "Movie") {
      url = Global.tmdbApiBaseUrl +
          "/3/movie/$id/similar?api_key=${Global.apiKey}&language=en-US&page=1";

      response = await http.get(url);
    } else if (type == "Tv Show") {
      response = await TvShowRepo()
          .fetchRelatedMovies(int.parse(id))
          .catchError((err) => err);
    } else if (type == "Podcast") {
      response = await PodcastRepo()
          .fetchRelatedPodcast(podCastId: id)
          .catchError((err) => err);
    } else {
      setState(() => hasError = true);
    }

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (type == "Movie") {
        res['results'].forEach((res) {
          ViewItem related = ViewItem(
            id: res['id'].toString(),
            image: res['poster_path'] == null
                ? Global.staticRecdImageUrl
                : "${Global.tmdbBackdropBaseUrl}${res['backdrop_path']}",
            name: res['original_title'],
            overview: res['overview'],
            category: res['genre_ids'],
          );
          setState(() => rList.add(related));
        });
      } else if (type == "Tv Show") {
        res['results'].forEach((res) {
          ViewItem related = ViewItem(
              id: res['id'].toString(),
              image: res['poster_path'] == null
                  ? Global.staticRecdImageUrl
                  : "${Global.tmdbBackdropBaseUrl}${res['backdrop_path']}",
              name: res['name'],
              overview: res['overview'],
              category: res['genres']);
          setState(() => rList.add(related));
        });
      } else if (type == "Podcast") {
        res['recommendations'].forEach((res) {
          ViewItem related = ViewItem(
              id: res['id'],
              image: res['thumbnail'] == null
                  ? Global.staticRecdImageUrl
                  : res['thumbnail'],
              name: res['title'],
              overview: res['description'],
              category: res['genre_ids']);
          setState(() => rList.add(related));
        });
      }
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

  Future getStatusFunction({String id, String type}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = "${App.RECd_URL}api/v1/bookmark/get-bookmark-status";
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "authorization": "$token",
      },
      body: {"recd_type": "$type", "id": "$id"},
    );

    if (response.statusCode == 200) {
      var res = json.decode(response.body);

      String str = res['data']['rating'];

      setState(() {
        if (str.isNotEmpty) {
          isRated = "${res['data']['rating']}/5";
        }
        isBookMarked = res['data']['bookmark'];
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

  Future getWatchProvider({String id, String type}) async {
    String url =
        "${Global.tmdbApiBaseUrl}/3/$type/$id/watch/providers?api_key=${Global.apiKey}";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);

      if (res['results'].containsKey('US')) {
        if (res['results']['US'].containsKey('rent')) {
          res['results']['US']['rent'].forEach((val) {
            setState(() {
              whereToWatch
                  .add("${Global.tmdbBackdropBaseUrl}${val['logo_path']}");
              isWhereToWatchAvailable = true;
            });
          });
        } else if (res['results']['US'].containsKey('flatrate')) {
          res['results']['US']['flatrate'].forEach((val) {
            setState(() {
              whereToWatch
                  .add("${Global.tmdbBackdropBaseUrl}${val['logo_path']}");
              isWhereToWatchAvailable = true;
            });
          });
        }
      }
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

  Future<List<RelatedRecsModel>> getRelatedRecd(
      {String type, String id}) async {
    setState(() => isRecdByLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = "${App.RECd_URL}api/v1/recommendation/get-recommendation-list";
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "authorization": "$token",
      },
      body: {"recd_type": "$type", "id": "$id"},
    );
    List<RelatedRecsModel> cList = [];
    if (response.statusCode == 200) {
      try {
        var res = json.decode(response.body);

        setState(() => totalRecd = res['data']['totalRecd']);
        res['data']['conversations'].forEach((res) {
          if (res != null) {
            RelatedRecsModel con = RelatedRecsModel(
              id: res['_id'],
              title: res['created_by']['name'],
              image: res['created_by']['profile_path'],
            );
            setState(() => cList.add(con));
          }
        });

        return cList;
      } catch (e) {
        setState(() => isRecdByLoading = false);
        return null;
      }
    } else if (response.statusCode == 500) {
      setState(() => isRecdByLoading = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 400) {
      setState(() => isRecdByLoading = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 401) {
      setState(() => isRecdByLoading = false);
      toast("${App.unauthorized}");
      return null;
    } else if (response.statusCode == 404) {
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
