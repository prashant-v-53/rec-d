import 'dart:convert';

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/bookmark/bookmark_repo.dart';
import 'package:http/http.dart' as http;

class CreateBookmarkController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController listname = new TextEditingController();

  String listnameDisplay = "";

  bool isButtonLoading = false;

  File file;
  bool flag = false;
  bool flag1 = false;

  FocusNode nameFN;
  // FocusNode descFN;

  String buttonVal = "Create";
  String titleVal = "Create New";
  String bookmarkId;
  String create = "";

  void iniFunc(BuildContext context) {
    nameFN = FocusNode();
  }

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

  setFlag() {
    setState(() {
      flag = false;
    });
  }

  void listNameValidate() {
    listname.text.isEmpty
        ? setState(() => listnameDisplay = "Please enter list name")
        : setState(() => listnameDisplay = "");
  }

  void createBookmark(BuildContext context) async {
    if (listname.text.isNotEmpty) {
      setState(() => isButtonLoading = true);
      try {
        Response response;
        if (flag1) {
          response = await BookMarkRepo()
              .updateBookmarkRepo(
                id: bookmarkId,
                fileData: file,
                title: listname.text,
              )
              .catchError((err) => null);
        } else {
          response = await BookMarkRepo()
              .createBookmarkRepo(
                fileData: file,
                title: listname.text,
              )
              .catchError((err) => null);
        }

        if (response == null) {
          setState(() => isButtonLoading = false);
        } else {
          if (response.statusCode == 200) {
            var res = response.data;
            if (res['status'] == 1) {
              if (create == "create") {
                Navigator.of(context).pop("success");
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteKeys.BOTTOMBAR,
                  (route) => false,
                  arguments: RouteArgument(param: 3),
                );
              }

              setState(() => isButtonLoading = false);
            }
          } else if (response.statusCode == 422) {
            var res = json.decode(response.data);
            if (res.containsKey('errors')) {
              res.forEach((value) {
                switch (value['param']) {
                  case 'title':
                    setState(() => listnameDisplay = value['msg']);
                    break;
                  default:
                }
              });
              setState(() => isButtonLoading = false);
            } else {
              setState(() => isButtonLoading = false);
            }
          } else if (response.statusCode == 401) {
            toast("${App.unauthorized}");
            setState(() => isButtonLoading = false);
          } else if (response.statusCode == 500) {
            setState(() => isButtonLoading = false);
          } else {
            setState(() => isButtonLoading = false);
          }
        }
      } catch (e) {
        setState(() => isButtonLoading = false);
      }
    } else {
      listNameValidate();
    }
  }

  Future removeBookMarkList(
      {BuildContext context, String bookmarkId, int index}) async {
    http.Response response =
        await BookMarkRepo().removeBList(bookmarkId).catchError((err) => err);

    if (response != null) {
      if (response.statusCode == 200) {
        try {
          var res = json.decode(response.body);
          if (res['status'] == 1) {
            setState(() {
              isButtonLoading = false;
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteKeys.BOTTOMBAR,
                (route) => false,
                arguments: RouteArgument(param: 3),
              );
            });
          }
        } catch (e) {
          toast("Something went wrong");
          setState(() => isButtonLoading = false);
          return null;
        }
      } else if (response.statusCode == 422) {
        toast("Something went wrong");
        setState(() => isButtonLoading = false);
        return null;
      } else if (response.statusCode == 401) {
        setState(() => isButtonLoading = false);
        toast("${App.unauthorized}");
      } else if (response.statusCode == 500) {
        toast("Something went wrong");
        setState(() => isButtonLoading = false);
        return null;
      } else {
        toast("Something went wrong");
        setState(() => isButtonLoading = false);
        return null;
      }
    } else {
      toast("Something went wrong");
      setState(() => isButtonLoading = false);
      return null;
    }
  }
}
