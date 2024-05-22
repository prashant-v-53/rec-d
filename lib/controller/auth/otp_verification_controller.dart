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

class OtpVerificationController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController otpController = TextEditingController();
  bool isButtonLoading = false;
  String otpError = "";
  FToast fToast;

  initFunc(BuildContext context) {
    fToast = FToast();
    fToast.init(context);
  }

  verify(BuildContext context, String email) {
    isInternet().then((value) {
      if (value) {
        if (otpController.text.isEmpty) {
          setState(() => otpError = "Invalid OTP");
        } else {
          if (otpController.text.length <= 4) {
            setState(() => isButtonLoading = true);
            otpVerify(context, email);
          } else {
            setState(() => otpError = "Invalid OTP");
          }
        }
      } else {
        toast("No Internet !!!");
      }
    });
  }

  Future otpVerify(BuildContext context, String email) async {
    Response response = await AuthRepo().forgotPasswordOtpVerification(
        emailAddress: email, otp: int.parse(otpController.text));

    if (response.statusCode == 200) {
      toast("OTP verified");
      Navigator.of(context).pushNamed(RouteKeys.RESET_PASSWORD,
          arguments: RouteArgument(param: email));
      setState(() => isButtonLoading = false);
    } else if (response.statusCode == 500) {
      var res = json.decode(response.body);
      setState(() => otpError = res['error']['message']);
      setState(() => isButtonLoading = false);
    } else if (response.statusCode == 422) {
      var res = json.decode(response.body);
      res['errors'].forEach((val) {
        switch (val['param']) {
          case "otp":
            setState(() => otpError = val['msg']);
            break;
          default:
        }
      });
      setState(() => isButtonLoading = false);
    } else if (response.statusCode == 401) {
      setState(() => isButtonLoading = false);
      toast("${App.unauthorized}");
      return null;
    } else {
      toast("Something went wrong");
      setState(() => isButtonLoading = false);
    }
  }
}
