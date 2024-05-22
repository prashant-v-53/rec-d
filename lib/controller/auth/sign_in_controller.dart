import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/repository/auth/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:http/http.dart' as http;

class SignInController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController userName = new TextEditingController();

  TextEditingController password = new TextEditingController();
  String usernameDisplay = "";
  String passwordDisplay = "";
  bool obscureText = true;
  bool isButtonLoading = false;
  bool googleSignInLoader = false;
  FToast fToast;

  var tokenFCM;
  FocusNode usernameFN;
  FocusNode passwordFN;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future register() async {
    _firebaseMessaging.getToken().then((token) {
      return token;
    });
  }

  initFunc(BuildContext context) {
    // getMessage();
    usernameFN = FocusNode();
    passwordFN = FocusNode();
    fToast = FToast();
    fToast.init(context);
  }

  void disposeFunc() {
    usernameFN.dispose();
    password.dispose();
  }

  void viewpassword() {
    setState(() => obscureText = !obscureText);
  }

  void usernamevalidate() {
    if (userName.text.isEmpty) {
      setState(() => usernameDisplay = "Please enter username or email");
    } else {
      setState(() => usernameDisplay = "");
    }
  }

  void passwordvalidate() {
    if (password.text.isEmpty) {
      setState(() => passwordDisplay = "Please enter password");
    } else {
      setState(() => passwordDisplay = "");
    }
    if (usernameDisplay.isNotEmpty) {
      usernamevalidate();
    }
  }

  loginUser(BuildContext context) async {
    isInternet().then(
      (value) {
        if (value == true) {
          if (usernameDisplay == "" &&
              passwordDisplay == "" &&
              userName.text.isNotEmpty &&
              password.text.isNotEmpty) {
            setState(() => isButtonLoading = true);
            _firebaseMessaging.getToken().then((token) async {
              callLoginAPI(context, token);
            });
            setState(() {
              usernameDisplay = "";
              passwordDisplay = "";
            });
          } else {
            if (usernameDisplay.isEmpty || passwordDisplay.isEmpty) {
              usernamevalidate();
              passwordvalidate();
            }
          }
        } else {
          toast("No Internet !!!");
        }
      },
    );
  }

  Future callLoginAPI(BuildContext context, var tkn) async {
    http.Response response = await AuthRepo().signInAPI(
        username: userName.text.trim(), password: password.text, token: tkn);

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(PrefsKey.ACCESS_TOKEN, res['data']['accessToken']);
        prefs.setString(PrefsKey.USER_ID, res['data']['userRecord']['_id']);
        Navigator.of(context).pushNamedAndRemoveUntil(
            RouteKeys.BOTTOMBAR, (route) => false,
            arguments: RouteArgument(param: 0));
      } else if (res['status'] == 0) {
        toast("Something went wrong");
      }
      setState(() => isButtonLoading = false);
    } else if (response.statusCode == 401) {
      var res = json.decode(response.body);
      if (res.containsKey('errors')) {
        res['errors'].forEach((val) {
          switch (val['param']) {
            case "emailORuserName":
              setState(() => usernameDisplay = val['msg']);
              break;
            case "password":
              setState(() => passwordDisplay = val['msg']);
              break;
            default:
          }
        });
      } else {
        toast("Something went wrong");
      }

      setState(() => isButtonLoading = false);
    } else if (response.statusCode == 422) {
      var res = json.decode(response.body);
      if (res.containsKey('errors')) {
        res['errors'].forEach((val) {
          switch (val['param']) {
            case "emailORuserName":
              setState(() => usernameDisplay = val['msg']);
              break;
            case "password":
              setState(() => passwordDisplay = val['msg']);
              break;
            default:
          }
        });
      } else {
        toast("Something went wrong");
      }
      setState(() => isButtonLoading = false);
    } else {
      toast("Something went wrong");
      setState(() => isButtonLoading = false);
    }
  }
}
