import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/auth/auth_repo.dart';

class ForgetPasswordController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailaddress = new TextEditingController();
  TextEditingController phonenumber = new TextEditingController();
  String emailaddressDisplay = "";
  String phonenumberDisplay = "";
  bool isButtonLoading = false;
  FToast fToast;

  initFunc(BuildContext context) {
    fToast = FToast();
    fToast.init(context);
  }

  void emailAddrerssValidate() {
    if (emailaddress.text.isEmpty) {
      setState(() => emailaddressDisplay = "Please enter email address");
    } else {
      setState(() => emailaddressDisplay = "");
    }
  }

  void phoneNumberValidate() {
    if (phonenumber.text.isEmpty) {
      setState(() => phonenumberDisplay = "Please enter phone number");
    } else {
      setState(() => phonenumberDisplay = "");
    }
  }

  sendMail(BuildContext context) async {
    isInternet().then((value) {
      if (value) {
        if (emailaddressDisplay == "" && emailaddress.text.isNotEmpty) {
          setState(() => isButtonLoading = true);
          callForgotPassword(context);
        } else {
          if (emailaddressDisplay.isEmpty) {
            emailAddrerssValidate();
          }
          setState(() => isButtonLoading = false);
        }
      } else {
        toast("No Internet !!!");
      }
    });
  }

  Future callForgotPassword(BuildContext context) async {
    Response response =
        await AuthRepo().forgotPassword(emailAddress: emailaddress.text.trim());

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res['status'] == 1) {
        Navigator.of(context).pushNamed(RouteKeys.OTP_VERIFICATION,
            arguments: RouteArgument(
              param: emailaddress.text,
            ));
      } else if (res['status'] == 0) {
        toast("Something went wrong");
      }
      setState(() => isButtonLoading = false);
    } else if (response.statusCode == 401) {
      var res = json.decode(response.body);
      if (res.containsKey('errors')) {
        res['errors'].forEach((val) {
          switch (val['param']) {
            case "email":
              setState(() => emailaddressDisplay = val['msg']);
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
            case "email":
              setState(() => emailaddressDisplay = val['msg']);
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
