import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectProfileController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isButtonLoading = false;
  FToast fToast;
  File file;
  bool flag = false;
  EdgeInsetsGeometry padding =
      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0);

  String profileError = "";

  initFunc(BuildContext context) {
    fToast = FToast();
    fToast.init(context);
  }

  final picker = ImagePicker();

  Future selectPhoto() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        flag = true;
        profileError = "";
        file = File(pickedFile.path);
      });
    }
  }

  setFlag() {
    setState(() {
      flag = false;
      file = null;
    });
  }

  final networkImage =
      "https://c8.alamy.com/comp/P4F3M3/original-film-title-the-lord-of-the-rings-the-return-of-the-king-english-title-the-lord-of-the-rings-the-return-of-the-king-film-director-peter-jackson-year-2003-credit-new-line-cinemathe-saul-zaentz-companywingnut-films-album-P4F3M3.jpg";

  uploadProfile(BuildContext context) async {
    isInternet().then((value) async {
      if (value) {
        if (file == null) {
          setState(() {
            profileError = "Please select profile picture";
            isButtonLoading = false;
          });
        } else {
          setState(() {
            profileError = "";
            isButtonLoading = true;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.getString(PrefsKey.ACCESS_TOKEN);
          Dio dio = new Dio();
          var uri = Uri.parse('${App.RECd_URL}${API.SET_UPDATE_PROFILE}');
          dio
              .post("$uri",
                  options: Options(headers: {
                    "authorization": "${prefs.getString(PrefsKey.ACCESS_TOKEN)}"
                  }),
                  data: FormData.fromMap({
                    "profile": MultipartFile.fromFileSync(file.path,
                        filename: path.basename(file.path))
                  }))
              .then((response) {
            if (response.statusCode == 200) {
              setState(() => isButtonLoading = false);
              Navigator.of(context).pushNamed(RouteKeys.ADD_BIO);
            } else {
              setState(() => profileError = "Somethig went wrong");
            }
          });
        }
      } else {
        toast("No Internet !!!");
      }
    });
  }
}
