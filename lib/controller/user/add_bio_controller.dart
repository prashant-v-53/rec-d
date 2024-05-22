import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/auth/auth_repo.dart';

class AddBioController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  EdgeInsetsGeometry padding =
      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0);

  TextEditingController intro = new TextEditingController();
  String introDisplay = "";
  FToast fToast;
  String profileError = "";
  bool isButtonLoading = false;

  initFunc(BuildContext context) {
    fToast = FToast();
    fToast.init(context);
  }

  void usernamevalidate() {
    if (intro.text.isEmpty) {
      setState(() {
        introDisplay = "Please enter bio";
      });
    } else {
      setState(() {
        introDisplay = "";
      });
    }
  }

  addBio(BuildContext context) async {
    isInternet().then((value) async {
      if (value) {
        if (intro.text.isEmpty) {
          setState(() => introDisplay = "Please enter bio");
        } else {
          setState(() => isButtonLoading = true);
          Response response = await AuthRepo().updateBio(bio: intro.text);
          if (response.statusCode == 200) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteKeys.BOTTOMBAR,
              (route) => false,
              arguments: RouteArgument(
                param: 0,
              ),
            );
            setState(() => isButtonLoading = false);
          } else if (response.statusCode == 422) {
            var res = json.decode(response.body);

            res['errors'].forEach((val) {
              switch (val['param']) {
                case "bio":
                  setState(() {
                    introDisplay = val['msg'];
                  });
                  break;
                default:
              }
            });
            setState(() => isButtonLoading = false);
          } else if (response.statusCode == 401) {
            setState(() => isButtonLoading = false);
            setState(() => introDisplay = "${App.unauthorized}");
            toast("${App.unauthorized}");
            return null;
          } else if (response.statusCode == 500) {
            setState(() => introDisplay = "Something went wrong");
            setState(() => isButtonLoading = false);
          } else {
            setState(() => introDisplay = "Something went wrong");
            setState(() => isButtonLoading = false);
          }
        }
      } else {
        toast("No Internet !!!");
      }
    });
  }
}
