import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  Future signUpAPI(
      {String fullname,
      String username,
      String emailAddress,
      String dob,
      String mobile,
      String pwd,
      String token}) async {
    try {
      String url = "${App.RECd_URL}" "${API.SingUp_URL}";

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": fullname,
          "u_name": username,
          "email": emailAddress,
          "DOB": dob,
          "mobile": mobile,
          "password": pwd,
          "device_token": token
        }),
      );

      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future signInAPI({String username, String password, var token}) async {
    try {
      String url = "${App.RECd_URL}" + "${API.Login_URL}";
      print(url);
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "emailORuserName": username,
            "password": password,
            "device_token": token
          }));
      print(response?.statusCode);
      print(response?.body);
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future forgotPassword({String emailAddress}) async {
    try {
      String url = "${App.RECd_URL}" + "${API.FORGOT_PASSWORD_MAIL_SENT}";

      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({"email": emailAddress}));
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future forgotPasswordOtpVerification({String emailAddress, int otp}) async {
    try {
      String url = "${App.RECd_URL}" + "${API.FORGOT_PASSWORD_OTP_VERIFY}";

      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({"email": emailAddress, "otp": otp}));
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future forgotPasswordUpdate({
    String emailAddress,
    String password1,
    String password2,
  }) async {
    try {
      String url = "${App.RECd_URL}" + "${API.FORGOT_PASSWORD_UPDATE}";

      final response = await http.put(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "type": "email",
            "email": emailAddress,
            "newPassword": password1,
            "confirmNewPassword": password2
          }));
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future updateBio({
    String bio,
  }) async {
    try {
      String url = "${App.RECd_URL}" + "${API.UPDATE_BIO}";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.getString(PrefsKey.ACCESS_TOKEN);

      final response = await http.put(url,
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader:
                "${prefs.getString(PrefsKey.ACCESS_TOKEN)}"
          },
          body: json.encode({"bio": bio}));
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future userData() async {
    try {
      String url = "${App.RECd_URL}" + "${API.PROFILE_DATA}";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.getString(PrefsKey.ACCESS_TOKEN);

      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader:
            "${prefs.getString(PrefsKey.ACCESS_TOKEN)}"
      });
      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future getUserProfile(String userId) async {
    try {
      String url = "${App.RECd_URL}" + "${API.GET_VIEW_PROFILE}/$userId";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.getString(PrefsKey.ACCESS_TOKEN);
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader:
            "${prefs.getString(PrefsKey.ACCESS_TOKEN)}",
      });

      return response;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future logOutApi() async {
    String url = App.RECd_URL + 'api/v1/user/logout';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("${PrefsKey.ACCESS_TOKEN}");
    http.Response response = await http.get(url,
        headers: {"Accept": "application/json", "authorization": "$token"});
    return response;
  }
}
