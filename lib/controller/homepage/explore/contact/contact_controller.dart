import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/contact_user_model.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/conversation_repo.dart';

class ContactController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  TabController controller;
  int topIndex = 0;
  int content = 1;
  ScrollController recentController = ScrollController();
  ScrollController friendsController = ScrollController();
  ScrollController groupController = ScrollController();
  int recentPage = 1, friendsPage = 1, groupPage = 1;
  bool isRecentLoading = false,
      isFriendsLoading = false,
      isGroupLoading = false;
  List<ContactItemModel> recentItemList = [];
  List<ContactItemModel> friendsItemList = [];
  List<ContactItemModel> groupItemList = [];
  List<String> selectedGroups = [];
  List<String> selectedFriends = [];
  List selectedList = [];
  var entityType;
  var entityObject;

  var recentScroll;

  changeTabValue(value) {
    setState(() {
      index = value;
    });
  }

  changeTopIndex(int value) {
    setState(() {
      topIndex = value;
    });
  }

  Future<List<ContactItemModel>> getRecentData(page) async {
    List<ContactItemModel> dataList = [];

    Response response =
        await ConversationRepo.getContactListApi('recent', page);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 1) {
        if (data['data'].isNotEmpty) {
          data['data'].forEach((item) {
            if (item['isGroup'] == true) {
              dataList.add(
                ContactItemModel(
                  email: "a@g.c",
                  name: item['conversation']['group_name'],
                  username: "user",
                  userid: item['conversation']['_id'],
                  isGroup: item['isGroup'],
                  profileimage: item['conversation']['group_cover_path'],
                ),
              );
            } else {
              dataList.add(
                ContactItemModel(
                  email: item['conversation']['members']['email'],
                  name: item['conversation']['members']['name'],
                  username: item['conversation']['members']['userName'],
                  userid: item['conversation']['members']['_id'],
                  isGroup: item['isGroup'],
                  profileimage: item['conversation']['members']['profile_path'],
                ),
              );
            }
          });
        }
      }
      setState(() => isRecentLoading = false);
      return dataList;
    } else {
      setState(() => isRecentLoading = false);
      toast('Something went wrong');
      return null;
    }
  }

  Future<List<ContactItemModel>> getFriendsData(page) async {
    List<ContactItemModel> dataList = [];

    Response response =
        await ConversationRepo.getContactListApi('friends', page);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 1) {
        if (data['data'].isNotEmpty) {
          data['data'].forEach((item) {
            dataList.add(ContactItemModel(
              email: item['email'],
              name: item['name'],
              username: item['userName'],
              userid: item['_id'],
              profileimage: item['profile_path'],
            ));
          });
        }
      }
      setState(() => isFriendsLoading = false);
      return dataList;
    } else {
      setState(() => isFriendsLoading = false);
      toast('Something went wrong');
      return null;
    }
  }

  Future<List<ContactItemModel>> getGroupData(page) async {
    List<ContactItemModel> dataList = [];
    setState(() => isFriendsLoading = true);
    Response response = await ConversationRepo.getContactListApi('group', page);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 1) {
        if (data['data'].isNotEmpty) {
          data['data'].forEach((item) {
            List<String> imagesList = [];
            if (item['members'] != null) {
              item['members'].forEach((img) {
                imagesList.add(img['profile_path']);
              });
            }
            dataList.add(ContactItemModel(
              userid: item['_id'],
              name: item['group_name'],
              groupImageList: imagesList,
              profileimage: item['group_cover_path'],
            ));
          });
        }
      }
      setState(() => isFriendsLoading = false);
      return dataList;
    } else {
      setState(() => isFriendsLoading = false);
      toast('Something went wrong');
      return null;
    }
  }

  sendButtonClicked(BuildContext context) {
    if (selectedFriends.isEmpty && selectedGroups.isEmpty) {
      toast('Please select at least one');
    } else {
      List<Map> conversations = [];
      List<Map> conversations2 = [];
      selectedFriends.forEach((id) {
        conversations.add({"type": "chat", "id": "$id"});
      });
      selectedGroups.forEach((id) {
        conversations2.add({"type": "group", "id": "$id"});
      });
      conversations.addAll(conversations2);
      Navigator.of(context).pushNamed(
        RouteKeys.SEND_RECO,
        arguments: RouteArgument(
          param: [entityType, entityObject, conversations],
        ),
      );
    }
  }
}
