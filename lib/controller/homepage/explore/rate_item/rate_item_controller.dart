import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:recd/model/rate/rate_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateItemController extends BaseController {
  double count = 0.0;
  List<RateField> rateField = [];
  bool isDataLoading = true;
  bool isButtonLoading = false;

  bool totalmasterpiece = false;
  bool good = false;
  bool amazing = false;
  bool meh = false;
  bool yikes = false;

  void setData(String newvalue, BuildContext context) =>
      setState(() => count = int.parse(newvalue).toDouble());

  addRating({String type, String id, BuildContext context}) async {
    setState(() => isButtonLoading = true);
    String url = App.RECd_URL + '${API.ADD_RATEING}';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    final response = await http.post(url, body: {
      "rating": count.round().toString(),
      "recd_type": "$type",
      "id": "$id"
    }, headers: {
      "Accept": "application/json",
      "authorization": "$token"
    });

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        Navigator.of(context).pop("${count.toInt()}");
        setState(() => isButtonLoading = false);
      }
    } else if (response.statusCode == 400) {
      setState(() => isButtonLoading = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 422) {
      setState(() => isButtonLoading = false);
      toast("Something went wrong");
      return null;
    } else {
      setState(() => isButtonLoading = false);
      toast("Something went wrong");
      return null;
    }
  }

  Future<List<RateField>> fetchCategory(String type, String id) async {
    try {
      List<RateField> mylist = [];
      String url = App.RECd_URL + '${API.RATE_FIELD}';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");

      final response = await http.post(url,
          body: {"recd_type": "$type", "id": "$id"},
          headers: {"Accept": "application/json", "authorization": "$token"});
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        res['data'].forEach((value) {
          RateField cat = RateField(
              rateName: value['name'],
              rateStar: value['star'],
              isSelected: value['is_selected']);
          setState(() {
            if (value['is_selected'] == true)
              count = int.parse(value['star']).toDouble();
            mylist.add(cat);
          });
        });

        return mylist;
      } else if (response.statusCode == 400) {
        toast("Something went wrong");
        return null;
      } else {
        toast("Something went wrong");
        return null;
      }
    } catch (e) {
      toast("Something went wrong");
      log('$e');
      return null;
    }
  }
}
