import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/category_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/group/create_group_repo.dart';
import 'package:http/http.dart' as http;

class AddFriendController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  bool isEmpty = true;
  int page = 1;
  List<UserModel> selectedPerson = [];
  List<UserModel> allSearchData = [];
  bool isPersonAdding = false;
  ScrollController pageScroll = ScrollController();

  bool isUserDataLoading = false;
  bool isPaginationLoading = false;
  FToast fToast;

  TextEditingController editingController = TextEditingController();

  List<UserModel> showItemList = [];
  List<UserModel> listdata = [];

  bool checked = false;

  addToNewList({String gId, BuildContext context}) async {
    List<String> mIds = [];
    for (var i = 0; i < showItemList.length; i++) {
      if (showItemList[i].flag == true) {
        mIds.add(showItemList[i].id);
        setState(() {
          selectedPerson.add(
            UserModel(
                id: showItemList[i].id,
                name: showItemList[i].name,
                profile: showItemList[i].profile,
                username: showItemList[i].username,
                flag: showItemList[i].flag),
          );
        });
      }
    }
    (selectedPerson.isNotEmpty)
        ? addPersonFromGroup(context: context, gId: gId, members: mIds)
        : toast("Please select at least one");
  }

  Future addPersonFromGroup(
      {String gId, List<String> members, BuildContext context}) async {
    String type = "add";
    setState(() => isPersonAdding = true);
    http.Response response = await GroupRepo().addOrRemovePersonFromGroup(
        type: type, groupId: gId, memberId: members);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        Navigator.pop(context, selectedPerson);
        setState(() => isPersonAdding = false);
      } else {
        setState(() => isPersonAdding = false);
      }
    } else if (response.statusCode == 400) {
      setState(() => isPersonAdding = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 422) {
      setState(() => isPersonAdding = false);
      toast("Something went wrong");
      return null;
    } else {
      setState(() => isPersonAdding = false);
      toast("Something went wrong");
      return null;
    }
  }

  filterSearch(String query) {
    List<UserModel> searchList = [];
    List<UserModel> fullSearchList = [];
    searchList.addAll(showItemList);
    fullSearchList.addAll(showItemList);

    if (query.isNotEmpty) {
      List<UserModel> resultListData = [];
      searchList.forEach((item) {
        if (item.name.contains(query)) {
          resultListData.add(item);
        }
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

  onSearch(String value) {
    showItemList = allSearchData
        .where((item) => item.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {});
  }

  Future<List<UserModel>> fetchAllUser(id) async {
    List<UserModel> list = [];
    Response response = await GroupRepo()
        .getRemainingMember(groupId: id, page: page)
        .catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          res['data'].forEach((val) {
            UserModel related = new UserModel(
              id: val['_id'],
              name: val['name'],
              username: val['userName'],
              profile: val['profile_path'],
              flag: false,
            );

            setState(() => list.add(related));
          });
          return list;
        } catch (e) {
          log('$e');
          return null;
        }
      } else if (response.statusCode == 422) {
        setState(() => isUserDataLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isUserDataLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() => isUserDataLoading = false);
        toast("Something went wrong");
        return null;
      } else {
        setState(() => isUserDataLoading = false);
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() => isUserDataLoading = false);
      toast("Something went wrong");
      return null;
    }
  }
}
