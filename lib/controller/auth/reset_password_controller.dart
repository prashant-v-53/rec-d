import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/auth/auth_repo.dart';

class ResetPasswordController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureText = true;
  bool obscureText1 = true;
  bool isButtonLoading = false;

  TextEditingController newpassword = new TextEditingController();
  TextEditingController reenterPassword = new TextEditingController();

  String newPasswordDisplay = "";
  String reenterPasswordDisplay = "";

  FocusNode newpasswordFN;
  FocusNode reenterPasswordFN;

  FToast fToast;

  initFunc(BuildContext context) {
    newpasswordFN = FocusNode();
    reenterPasswordFN = FocusNode();
    fToast = FToast();
    fToast.init(context);
  }

  void viewpassword() {
    setState(() => obscureText = !obscureText);
  }

  void viewpassword1() {
    setState(() => obscureText1 = !obscureText1);
  }

  disposeFunc() {
    newpasswordFN.dispose();
    reenterPasswordFN.dispose();
  }

  void newPasswordValidate() {
    if (newpassword.text.isEmpty) {
      setState(() => newPasswordDisplay = "Please enter password");
    } else {
      setState(() => newPasswordDisplay = "");
    }
  }

  void reEnterPasswordValidate() {
    if (reenterPassword.text.isEmpty) {
      setState(() => reenterPasswordDisplay = "Please enter password");
    } else {
      setState(() => reenterPasswordDisplay = "");
    }
  }

  updatePassword(BuildContext context, String email) async {
    isInternet().then((value) {
      if (value) {
        if (newPasswordDisplay == "" &&
            reenterPasswordDisplay == "" &&
            newpassword.text.isNotEmpty &&
            reenterPassword.text.isNotEmpty) {
          if (newpassword.text == reenterPassword.text) {
            setState(() => isButtonLoading = true);
            setNewPassword(context, email);
          } else {
            setState(() => reenterPasswordDisplay = "Password doesn't match");
          }
        } else {
          if (newPasswordDisplay.isEmpty && reenterPasswordDisplay.isEmpty) {
            newPasswordValidate();
            reEnterPasswordValidate();
          }
        }
      } else {
        toast("No Internet !!!");
      }
    });
  }

  Future setNewPassword(BuildContext context, String email) async {
    Response response = await AuthRepo().forgotPasswordUpdate(
        emailAddress: email,
        password1: newpassword.text,
        password2: reenterPassword.text);
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      toast(res['message']);
      Navigator.of(context).pushNamedAndRemoveUntil(
          RouteKeys.SLECTION_SIGN_IN_UP, (route) => false);
      setState(() => isButtonLoading = false);
    } else if (response.statusCode == 422) {
      var res = json.decode(response.body);
      res['errors'].forEach((val) {
        switch (val['param']) {
          case "confirmNewPassword":
            setState(() => reenterPasswordDisplay = val['msg']);
            break;
          case "newPassword":
            setState(() => newPasswordDisplay = val['msg']);
            break;

          default:
        }
      });
      setState(() => isButtonLoading = false);
    } else if (response.statusCode == 401) {
      setState(() => isButtonLoading = false);
      toast("${App.unauthorized}");
    } else if (response.statusCode == 500) {
      toast("Something went wrong");
      setState(() => isButtonLoading = false);
    } else {
      toast("Something went wrong");
      setState(() => isButtonLoading = false);
    }
  }
}
