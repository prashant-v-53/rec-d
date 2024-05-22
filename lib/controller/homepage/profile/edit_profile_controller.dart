import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fullname = new TextEditingController();
  TextEditingController emailaddress = new TextEditingController();
  TextEditingController dateofbirth = new TextEditingController();
  TextEditingController mobilenumber = new TextEditingController();
  TextEditingController bio = new TextEditingController();

  String fullnameDisplay = "";
  String emailaddressDisplay = "";
  String dateofbirthDisplay = "";
  String mobileNumberDisplay = "";
  String bioDisplay = "";

  File file;
  bool flag = false;
  bool isLoding = false;

  FocusNode fullnameFN;
  FocusNode emailAddressFN;
  FocusNode dateofbirthFN;
  FocusNode mobileNumberFN;
  FocusNode bioFN;

  FToast fToast;
  String profileError = "";

  EdgeInsetsGeometry textBoxPadding =
      const EdgeInsets.symmetric(horizontal: 15.0);

  initFunc(BuildContext context) {
    fullnameFN = FocusNode();
    emailAddressFN = FocusNode();
    mobileNumberFN = FocusNode();
    dateofbirthFN = FocusNode();
    bioFN = FocusNode();
    fToast = FToast();
    fToast.init(context);
  }

  disposeFunc() {
    fullnameFN.dispose();
    emailAddressFN.dispose();
    mobileNumberFN.dispose();
    dateofbirthFN.dispose();
    bioFN.dispose();
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

  void fullnamevalidate() {
    if (fullname.text.isEmpty) {
      setState(() => fullnameDisplay = "Please enter full name");
    } else {
      setState(() => fullnameDisplay = "");
    }
  }

  void biovalidate() {
    if (bio.text.isEmpty) {
      setState(() => bioDisplay = "Please enter bio");
    } else {
      setState(() => bioDisplay = "");
    }
  }

  void emailaddressvalidate() {
    if (emailaddress.text.isEmpty) {
      setState(() => emailaddressDisplay = "Please enter email address");
    } else {
      setState(() => emailaddressDisplay = "");
    }
  }

  void mobileNumbervalidate() {
    if (mobilenumber.text.isEmpty) {
      setState(() => mobileNumberDisplay = "Please enter mobile number");
    } else {
      setState(() => mobileNumberDisplay = "");
    }
  }

  void dateofbirthvalidate() {
    if (dateofbirth.text.isEmpty) {
      setState(() => dateofbirthDisplay = "Please select date");
    } else {
      setState(() => dateofbirthDisplay = "");
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
                  colorScheme:
                      ColorScheme.light(primary: AppColors.PRIMARY_COLOR)),
              child: child);
        });
    if (pickedDate != null) {
      final picked = DateFormat('MM-dd-yyyy').format(pickedDate);
      dateofbirth.text = picked;
      dateofbirthvalidate();
    }
  }

  updateProfile(BuildContext context) async {
    isInternet().then((value) {
      if (value) {
        if (fullnameDisplay == "" &&
            emailaddressDisplay == "" &&
            mobileNumberDisplay == "" &&
            dateofbirthDisplay == "" &&
            fullname.text.isNotEmpty &&
            emailaddress.text.isNotEmpty &&
            mobilenumber.text.isNotEmpty &&
            dateofbirth.text.isNotEmpty) {
          setState(() => isLoding = true);
          updateProfileApi(context);
          setState(() {
            fullnameDisplay = "";
            emailaddressDisplay = "";
            mobileNumberDisplay = "";
            dateofbirthDisplay = "";
          });
        } else {
          if (fullname.text.isEmpty ||
              emailaddress.text.isEmpty ||
              mobilenumber.text.isEmpty ||
              dateofbirth.text.isEmpty) {
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

  updateProfileApi(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString(PrefsKey.ACCESS_TOKEN);

    Dio dio = new Dio();
    var uri = Uri.parse('${App.RECd_URL}${API.UPDATE_PROFILE}');

    var data = FormData.fromMap({
      "profile_picture": file == null
          ? null
          : MultipartFile.fromFileSync(file.path,
              filename: path.basename(file.path)),
      "name": fullname.text,
      "email": emailaddress.text,
      "DOB": dateofbirth.text,
      "mobile": mobilenumber.text,
      "bio": bio.text == null || bio.text.isEmpty ? " " : bio.text
    });

    Response response;

    response = await dio.post("$uri",
        options: Options(
          headers: {
            "authorization": "${prefs.getString(PrefsKey.ACCESS_TOKEN)}"
          },
        ),
        data: data);

    if (response.statusCode == 200) {
      var res = response.data;

      setState(() => isLoding = false);
      if (res['status'] == 1) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteKeys.BOTTOMBAR,
          (route) => false,
          arguments: RouteArgument(
            param: 4,
          ),
        );
      } else {
        setState(() => isLoding = false);
      }
    } else if (response.statusCode == 401) {
      var res = json.decode(response.data);
      if (res.containsKey('errors')) {
        toast("Something went wrong");
      } else {
        toast("Something went wrong");
        setState(() => isLoding = false);
      }
      setState(() => isLoding = false);
    } else if (response.statusCode == 422) {
      var res = json.decode(response.data);
      if (res.containsKey('errors')) {
        res['errors'].forEach((val) {
          switch (val['param']) {
            case "email":
              setState(() => emailaddressDisplay = val['msg']);
              break;
            case "DOB":
              setState(() => dateofbirthDisplay = val['msg']);
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
      setState(() => isLoding = false);
    } else {
      toast("Something went wrong");
      setState(() => isLoding = false);
    }
  }
}
