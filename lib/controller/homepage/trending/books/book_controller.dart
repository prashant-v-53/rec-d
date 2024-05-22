import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/model/books/books.dart';
import 'package:http/http.dart' as http;
import 'package:recd/model/group/group.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isRated = false;

  int total = 0;
  List<RelatedRecsModel> relatedRec = [];

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0);

  BookModel bookDetails;
  FToast fToast;

  final where =
      "https://www.eastbaytimes.com/wp-content/uploads/2017/01/netflix_logo_digitalvideo_0701.jpg";

  iniFunc({dynamic value, BuildContext context}) async {
    isInternet().then((internet) {
      if (internet) {
        viewBook(value).then((details) {
          getStatusFunction(value).then((val) {
            setState(() {
              bookDetails = details;
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
      body: {"recd_type": "Book", "id": "$podcastId"},
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
  Future viewBook(String bookId) async {
    String url = "https://www.googleapis.com/books/v1/volumes/$bookId";
    http.Response response = await http.get(url);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);

          BookModel d = BookModel(
            id: res['id'].toString(),
            title: res['volumeInfo']['title'].toString(),
            image: res['volumeInfo'].containsKey('imageLinks')
                ? res['volumeInfo']['imageLinks'].containsKey('medium')
                    ? res['volumeInfo']['imageLinks']['medium'].toString()
                    : res['volumeInfo']['imageLinks'].containsKey('thumbnail')
                        ? res['volumeInfo']['imageLinks']['thumbnail']
                            .toString()
                        : Global.staticRecdImageUrl
                : Global.staticRecdImageUrl,
            desc: res['volumeInfo'].containsKey('description')
                ? res['volumeInfo']['description']
                : "",
          );

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
      body: {"recd_type": "Book", "id": "$movieId"},
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
