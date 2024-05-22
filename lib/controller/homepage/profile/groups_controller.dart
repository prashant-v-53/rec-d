import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/contact_user_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/profile/profile_repo.dart';

class GroupsController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController pageScroll = ScrollController();
  List<GroupItemModel> groupItemList = [];
  int page = 1;
  bool isGroupsLoading = false;
  bool isPaginationLoading = false;
  bool isPageLoadingStop = false;
  String searchData = "";

  Future<List<GroupItemModel>> fetchAllGroups(
      {int page, String searchQuery}) async {
    List<GroupItemModel> list = [];

    Response response = await ProfileRepo()
        .fetchGroupsDetails(page: page, searchQuery: searchQuery)
        .catchError((err) => err);
    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach((val) {
            List<String> imagesList = [];
            if (val['members'] != null)
              val['members']
                  .forEach((img) => imagesList.add(img['profile_path']));

            GroupItemModel related = new GroupItemModel(
                id: val['_id'],
                name: val['group_name'],
                image: val['group_cover_path'],
                groupImageList: imagesList);
            setState(() => list.add(related));
          });
          if (res['data'] == null || res['data'].length == 0)
            setState(() => isPageLoadingStop = true);
          return list;
        } catch (e) {
          setState(() {
            isGroupsLoading = false;
            isPageLoadingStop = true;
          });
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        setState(() {
          isGroupsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        setState(() {
          isGroupsLoading = false;
          isPageLoadingStop = true;
        });
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() {
          isGroupsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      } else {
        setState(() {
          isGroupsLoading = false;
          isPageLoadingStop = true;
        });
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() {
        isGroupsLoading = false;
        isPageLoadingStop = true;
      });
      toast("Something went wrong");
      return null;
    }
  }
}
