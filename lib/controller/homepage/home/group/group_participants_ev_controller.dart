import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:recd/model/group/edit_group.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/group/create_group_repo.dart';

class GroupParticipantsEVController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool flag = false;
  bool textBoxFlag = false;
  bool isPersonRemoving = false;
  bool isUserLeaveing = false;
  File file;
  EditGroup groupDetails = EditGroup();

  String groupLabel = "";
  String groupNameDisplay = "";

  TextEditingController groupNameController = TextEditingController();

  final picker = ImagePicker();

  Future selectPhoto() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        flag = true;
        file = File(pickedFile.path);
      });
    }
  }

  Future popDataAdd(BuildContext context) async {
    var result = await Navigator.of(context).pushNamed(RouteKeys.ADD_FRIENDS,
        arguments: RouteArgument(param: groupDetails.gid));
    if (result != null) {
      List<UserModel> userIfno = result;
      if (groupDetails.listOfUser.contains(userIfno)) {
      } else {
        setState(() => groupDetails.listOfUser.addAll(userIfno));
      }
    }
  }

  void editGname(String val) {
    setState(() {
      textBoxFlag = true;
      groupNameController.text = val;
      groupNameController.selection = TextSelection(
          baseOffset: 0, extentOffset: groupNameController.text.length);
    });
  }

  void groupnamevalidate() {
    if (groupNameController.text.isEmpty) {
      setState(() => groupNameDisplay = "Please enter group name");
    } else {
      setState(() => groupNameDisplay = "");
    }
  }

  Future fetchGroupMember(String id) async {
    setState(() => isLoading = true);

    EditGroup cList;
    http.Response response =
        await GroupRepo().getGroupMember(id).catchError((err) => err);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        var data = res['data'];
        List<UserModel> users = [];
        res['data']['members'].forEach((val) {
          UserModel user = UserModel(
            id: val['_id'],
            name: val['name'],
            profile: val['profile_path'],
          );
          users.add(user);

          EditGroup obj = new EditGroup(
              gid: data['_id'],
              gName: data['group_name'],
              gImage: data['group_cover_path'],
              listOfUser: users,
              createdBy: data['created_by'],
              isGroupCreatedByYou: data['isGroupCreatedByMe']);
          setState(() => cList = obj);
        });
      }

      return cList;
    } else if (response.statusCode == 400) {
      setState(() => isLoading = false);
      toast("Try after sometime");
      return null;
    } else if (response.statusCode == 401) {
      setState(() => isLoading = false);
      toast("${App.unauthorized}");
      return null;
    } else if (response.statusCode == 500) {
      setState(() => isLoading = false);
      toast("Try after sometime");
      return null;
    } else {
      toast("Try after sometime");
      setState(() => isLoading = false);
      return null;
    }
  }

  Future updateGroup({
    BuildContext context,
    String groupId,
  }) async {
    if (groupLabel.isNotEmpty && groupNameDisplay == "") {
      setState(() => isLoading = true);

      List<UserModel> userIds = groupDetails.listOfUser;
      Response response = await GroupRepo()
          .updateGroup(
              name: textBoxFlag ? groupNameController.text : groupLabel,
              groupId: groupId,
              fileData: file,
              ids: userIds)
          .catchError((err) => null);

      if (response.statusCode == 200) {
        setState(() => isLoading = false);
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteKeys.BOTTOMBAR,
          (route) => false,
          arguments: RouteArgument(param: 0),
        );
      } else if (response.statusCode == 400) {
        setState(() => isLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 422) {
        setState(() => isLoading = false);
        toast("Something went wrong");
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isLoading = false);
        toast("${App.unauthorized}");
        return null;
      } else if (response.statusCode == 500) {
        setState(() => isLoading = false);
        return null;
      } else {
        setState(() => isLoading = false);
        toast("Something went wrong");
        return null;
      }
    } else {
      setState(() => isLoading = false);
      return null;
    }
  }

  Future removePersonFromGroup(
      {String gId, String mId, BuildContext context}) async {
    Navigator.of(context).pop();
    List<String> members = [mId];
    String type = "remove";
    setState(() => isPersonRemoving = true);
    //* url calling
    http.Response response = await GroupRepo().addOrRemovePersonFromGroup(
        type: type, groupId: gId, memberId: members);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        setState(() =>
            groupDetails.listOfUser.removeWhere((item) => item.id == mId));
        setState(() => isPersonRemoving = false);
      }
    } else if (response.statusCode == 400) {
      setState(() => isPersonRemoving = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 422) {
      setState(() => isPersonRemoving = false);
      var res = json.decode(response.body);

      toast(res['message']);
      return null;
    } else {
      setState(() => isPersonRemoving = false);
      toast("Something went wrong");
      return null;
    }
  }

  Future leavePersonFromGroup({String gId, BuildContext context}) async {
    Navigator.of(context).pop();
    setState(() => isUserLeaveing = true);

    http.Response response =
        await GroupRepo().leavePersonFromGroup(groupId: gId);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        Navigator.of(context).pushReplacementNamed(RouteKeys.BOTTOMBAR,
            arguments: RouteArgument(param: 0));
        setState(() => isUserLeaveing = false);
      }
    } else if (response.statusCode == 400) {
      setState(() => isUserLeaveing = false);
      toast("Something went wrong");
      return null;
    } else if (response.statusCode == 422) {
      setState(() => isUserLeaveing = false);
      toast("Something went wrong");
      return null;
    } else {
      setState(() => isUserLeaveing = false);
      toast("Something went wrong");
      return null;
    }
  }
}
