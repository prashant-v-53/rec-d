import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/model/usermodel.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/group/create_group_repo.dart';

class CreateGroupController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  bool flag = false;
  File file;
  bool checked = false;
  bool isLoading = false;
  final picker = ImagePicker();
  List<UserInfo> parms;
  List removePerson = [];
  TextEditingController groupname = TextEditingController();

  FToast fToast;

  final networkImage =
      "https://c8.alamy.com/comp/P4F3M3/original-film-title-the-lord-of-the-rings-the-return-of-the-king-english-title-the-lord-of-the-rings-the-return-of-the-king-film-director-peter-jackson-year-2003-credit-new-line-cinemathe-saul-zaentz-companywingnut-films-album-P4F3M3.jpg";

  initialize(param) {
    setState(() {
      parms = param;
    });
    param.forEach((e) => e.userid);
  }

  setFlag() {
    setState(() {
      flag = false;
    });
  }

  Future selectPhoto() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        flag = true;
        file = File(pickedFile.path);
      });
    }
  }

  personRemove(String id) {
    if (parms.length > 2) {
      setState(() {
        parms.removeWhere((item) => item.userid == id);
        removePerson.add(id);
      });
    } else {
      toast("Group should have at least 2 members");
    }
  }

  Future createGroup(BuildContext context) async {
    if (groupname.text != null && groupname.text != '') {
      setState(() => isLoading = true);

      Response response = await GroupRepo()
          .createGroup(
            fileData: file,
            name: groupname.text.trim(),
            ids: parms,
          )
          .catchError((err) => null);

      if (response != null) {
        setState(() => isLoading = false);
        if (response.statusCode == 200) {
          var res = response.data;
          if (res['status'] == 1) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteKeys.BOTTOMBAR,
              (route) => false,
              arguments: RouteArgument(param: 0),
            );
            toast("Group created successfully");
          }
        } else if (response.statusCode == 401) {
          setState(() => isLoading = false);
          toast("${App.unauthorized}");
          return null;
        } else if (response.statusCode == 500) {
          toast("Something went wrong");
          setState(() => isLoading = false);
          return null;
        } else if (response.statusCode == 422) {
          toast("Something went wrong");
          setState(() => isLoading = false);
        }
      }
      setState(() => isLoading = false);
    } else {
      toast("Enter group name");
    }
  }
}
