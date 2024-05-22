import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/model/usermodel.dart';
import 'package:http/http.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/group/create_group_repo.dart';

class GroupSelectionController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  int page = 1;
  ScrollController pageScroll = ScrollController();
  String searchQuery = "";

  bool isEmpty = true;
  bool isUserDataLoading = false;
  bool isSearchDataLoading = false;
  bool isDataColleting = false;
  bool checked = false;
  bool isPaginationLoading = false;
  List<UserInfo> selectedPerson = [];
  List<UserInfo> showItemList = [];

  FToast fToast;

  TextEditingController editingController = TextEditingController();

  filterSearch(String query) {
    List<UserInfo> searchList = [];
    List<UserInfo> fullSearchList = [];
    searchList.addAll(showItemList);
    fullSearchList.addAll(showItemList);

    if (query.isNotEmpty) {
      List<UserInfo> resultListData = [];
      searchList.forEach((item) {
        if (item.name.contains(query)) resultListData.add(item);
      });
      setState(() {
        showItemList.clear();
        showItemList.addAll(resultListData);
      });
      return;
    } else {
      setState(() {
        showItemList.clear();
        showItemList.addAll(fullSearchList);
      });
    }
  }

  void addAndCheckGroupMember(BuildContext context) async {
    if (selectedPerson.length > 1) {
      var result;
      result = await Navigator.of(context).pushNamed(
        RouteKeys.CREATE_GROUP,
        arguments: RouteArgument(param: selectedPerson),
      );
      List<dynamic> str = result;
      if (str.isNotEmpty) {
        for (var i = 0; i < str.length; i++) {
          selectedPerson.removeWhere((item) => item.userid == str[i]);
        }
        setState(() => isUserDataLoading = true);
        fetchAllUser(query: "", searchPage: 1).then((value) {
          setState(() {
            showItemList = value;
            isUserDataLoading = false;
          });
        });
      }
    } else {
      setState(() => isDataColleting = false);
      toast("Group should have at least 2 members");
    }
  }

  Future<List<UserInfo>> fetchAllUser({int searchPage, String query}) async {
    List<UserInfo> list = [];
    Response response = await GroupRepo()
        .getAllUser(page: searchPage, queryData: query)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        res['data'].forEach((val) {
          UserInfo related = new UserInfo(
              userid: val['members']['_id'],
              name: val['members']['name'],
              username: val['members']['userName'],
              profileimage: val['members']['profile_path'],
              flag: false);
          setState(() => list.add(related));
        });
        return list;
      } else if (response.statusCode == 422) {
        setState(() => isUserDataLoading = false);
        toast("Something went wrong");

        return null;
      } else if (response.statusCode == 401) {
        setState(() => isUserDataLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        toast("Something went wrong");
        setState(() => isUserDataLoading = false);
        return null;
      } else {
        toast("Something went wrong");
        setState(() => isUserDataLoading = false);
        return null;
      }
    } else {
      toast("Something went wrong");
      setState(() => isUserDataLoading = false);
      return null;
    }
  }
}
