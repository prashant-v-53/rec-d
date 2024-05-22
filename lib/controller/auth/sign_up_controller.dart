import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/auth/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  TextEditingController fullname = new TextEditingController();
  TextEditingController userName = new TextEditingController();
  TextEditingController emailaddress = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController dateofbirth = new TextEditingController();
  TextEditingController mobilenumber = new TextEditingController();

  String usernameDisplay = "";
  String passwordDisplay = "";
  String fullnameDisplay = "";
  String emailaddressDisplay = "";
  String dateofbirthDisplay = "";
  String mobileNumberDisplay = "";

  FocusNode fullnameFN;
  FocusNode usernameFN;
  FocusNode emailAddressFN;
  FocusNode passwordFN;
  FocusNode dateofbirthFN;
  FocusNode mobileNumberFN;

  int preLength = 0;
  bool isLoding = false;
  FToast fToast;

  bool obscureText = true;
  EdgeInsetsGeometry textBoxPadding =
      const EdgeInsets.symmetric(horizontal: 15.0);

  initFunc(BuildContext context) {
    fullnameFN = FocusNode();
    usernameFN = FocusNode();
    emailAddressFN = FocusNode();
    mobileNumberFN = FocusNode();
    passwordFN = FocusNode();
    dateofbirthFN = FocusNode();
    fToast = FToast();
    fToast.init(context);
  }

  disposeFunc() {
    fullnameFN.dispose();
    usernameFN.dispose();
    emailAddressFN.dispose();
    mobileNumberFN.dispose();
    passwordFN.dispose();
    dateofbirthFN.dispose();
  }

  void viewpassword() {
    setState(() => obscureText = !obscureText);
  }

  void fullnamevalidate() {
    if (fullname.text.isEmpty) {
      setState(() {
        fullnameDisplay = "Please enter full name";
      });
    } else {
      setState(() {
        fullnameDisplay = "";
      });
    }
  }

  void usernamevalidate() {
    if (userName.text.isEmpty) {
      setState(() {
        usernameDisplay = "Please enter username";
      });
    } else {
      setState(() {
        usernameDisplay = "";
      });
    }
  }

  void emailaddressvalidate() {
    if (emailaddress.text.isEmpty) {
      setState(() {
        emailaddressDisplay = "Please enter email address";
      });
    } else {
      setState(() {
        emailaddressDisplay = "";
      });
    }
  }

  void mobileNumbervalidate() {
    if (mobilenumber.text.isEmpty) {
      setState(() {
        mobileNumberDisplay = "Please enter mobile number";
      });
    } else {
      setState(() {
        mobileNumberDisplay = "";
      });
    }
  }

  void passwordvalidate() {
    if (password.text.isEmpty) {
      setState(() {
        passwordDisplay = "Please enter password";
      });
    } else {
      setState(() {
        passwordDisplay = "";
      });
    }
  }

  void dateofbirthvalidate() {
    if (dateofbirth.text.isEmpty) {
      setState(() {
        dateofbirthDisplay = "Please select date";
      });
    } else {
      setState(() {
        dateofbirthDisplay = "";
      });
    }
  }

  selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 01, 01),
      firstDate: DateTime(1947),
      lastDate: DateTime(2016),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.PRIMARY_COLOR,
            ),
          ),
          child: child,
        );
      },
    );
    if (pickedDate != null) {
      final picked = DateFormat('MM-dd-yyyy').format(pickedDate);
      dateofbirth.text = picked;
      dateofbirthvalidate();
    }
  }

  singup(BuildContext context) async {
    isInternet().then((value) {
      if (value) {
        if (fullnameDisplay == "" &&
            usernameDisplay == "" &&
            emailaddressDisplay == "" &&
            mobileNumberDisplay == "" &&
            passwordDisplay == "" &&
            dateofbirthDisplay == "" &&
            fullname.text.isNotEmpty &&
            userName.text.isNotEmpty &&
            emailaddress.text.isNotEmpty &&
            mobilenumber.text.isNotEmpty &&
            password.text.isNotEmpty &&
            dateofbirth.text.isNotEmpty) {
          setState(() => isLoding = true);

          _firebaseMessaging.getToken().then((token) async {
            signUpCall(context, token);
          });
          setState(
            () {
              fullnameDisplay = "";
              usernameDisplay = "";
              emailaddressDisplay = "";
              mobileNumberDisplay = "";
              passwordDisplay = "";
              dateofbirthDisplay = "";
            },
          );
        } else {
          if (fullname.text.isEmpty ||
              userName.text.isEmpty ||
              emailaddress.text.isEmpty ||
              mobilenumber.text.isEmpty ||
              password.text.isEmpty ||
              dateofbirth.text.isEmpty) {
            usernamevalidate();
            passwordvalidate();
            fullnamevalidate();
            mobileNumbervalidate();
            emailaddressvalidate();
            dateofbirthvalidate();
          }
        }
      } else {
        toast("No Internet !!!");
      }
    });
  }

  signUpCall(BuildContext context, String token) async {
    http.Response response = await AuthRepo().signUpAPI(
        fullname: fullname.text,
        username: userName.text,
        emailAddress: emailaddress.text,
        mobile: mobilenumber.text,
        dob: dateofbirth.text,
        pwd: password.text,
        token: token);
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['message'] == "signup success") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(PrefsKey.ACCESS_TOKEN, res['data']['accessToken']);
        prefs.setString(PrefsKey.USER_ID, res['data']['userRecord']['_id']);
        setState(() => isLoding = false);
        Navigator.of(context).pushReplacementNamed(RouteKeys.SELECT_PROFILE);
      } else {
        toast("Something went wrong");
        setState(() => isLoding = false);
      }
    } else if (response.statusCode == 401) {
      var res = json.decode(response.body);
      if (res.containsKey('errors')) {
        toast("Something went wrong");
      } else {
        toast("Something went wrong");
        setState(() => isLoding = false);
      }
      setState(() {
        isLoding = false;
      });
    } else if (response.statusCode == 422) {
      var res = json.decode(response.body);
      if (res.containsKey('errors')) {
        res['errors'].forEach((val) {
          switch (val['param']) {
            case "email":
              setState(() => emailaddressDisplay = val['msg']);
              break;
            case "u_name":
              setState(() => usernameDisplay = val['msg']);
              break;
            case "DOB":
              setState(() => dateofbirthDisplay = val['msg']);
              break;
            case "password":
              setState(() => passwordDisplay = val['msg']);
              break;
            case "mobile":
              setState(() => mobileNumberDisplay = val['msg']);
              break;

            default:
          }
        });
      } else {
        toast("Something went wrong");
      }
      setState(() {
        isLoding = false;
      });
    } else {
      toast("Something went wrong");
      setState(() => isLoding = false);
    }
  }
}
