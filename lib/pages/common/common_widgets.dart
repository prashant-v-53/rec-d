import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppBar getAppbar(String appbar) => AppBar(
      title: Text(
        appbar,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: true,
      leading: SizedBox(),
    );

// * Back Button for screen at the top
Widget topBackButton(BuildContext context) {
  return Positioned(
      top: 5.0,
      left: 5.0,
      child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black)));
}

// * set Sized Box height
SizedBox hBox(double height) => SizedBox(height: height);

// * set Sized Box Width
SizedBox wBox(double width) => SizedBox(width: width);

// * Coomon Border
InputBorder decor({Color colors, double width}) {
  return OutlineInputBorder(
      borderRadius: BorderRadius.circular(7.0),
      borderSide:
          BorderSide(color: colors, width: (width == null) ? 0 : width));
}

// * Error text after textbox
Widget errorText(String value) {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: TextStyle(color: Colors.red, fontSize: 13.0))));
}

// * Common Widgets
InputDecoration inputDecoration({String text, String path}) {
  return InputDecoration(
      hintText: text,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
      isDense: true,
      prefixIcon: SvgPicture.asset(path),
      prefixIconConstraints: cons(),
      filled: true,
      focusedBorder: decor(colors: AppColors.PRIMARY_COLOR, width: 0.7),
      fillColor: Colors.grey[100],
      enabledBorder: decor(colors: AppColors.BORDER_COLOR, width: 1.0));
}

//* Or text with Divider
Widget orSection() {
  return Row(children: <Widget>[
    Expanded(
        child: new Container(
            margin: const EdgeInsets.only(left: 10.0, right: 15.0),
            child: Divider(
                color: AppColors.PRIMARY_COLOR,
                endIndent: 10.0,
                indent: 10.0,
                height: 0.5))),
    Text("OR"),
    Expanded(
        child: new Container(
            margin: const EdgeInsets.only(left: 15.0, right: 10.0),
            child: Divider(
                color: AppColors.PRIMARY_COLOR,
                endIndent: 10.0,
                indent: 10.0,
                height: 40)))
  ]);
}

// * Divider
Divider d() => Divider(endIndent: 20.0, indent: 20.0);

//* Leading BackAcon for appbar
Widget leadingIcon({BuildContext context, isPopTrue = false}) {
  return IconButton(
      onPressed: () => Navigator.of(context).pop(isPopTrue),
      icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black));
}

// * invite friends section
Widget inviteFriends(BuildContext context) {
  return GestureDetector(
    // onTap: () => shareInfo(),
    onTap: () => Navigator.of(context).pushNamed(RouteKeys.USER_CONTACT),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.PRIMARY_COLOR,
        child: Icon(Icons.person_add, color: Colors.white),
        radius: 25,
      ),
      title: Text(
        "Invite new friends to REC'd",
        style: TextStyle(
          fontSize: 14.0,
          color: AppColors.PRIMARY_COLOR,
        ),
      ),
    ),
  );
}

Future<bool> isInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    if (await DataConnectionChecker().hasConnection) {
      return true;
    } else {
      return false;
    }
  } else if (connectivityResult == ConnectivityResult.wifi) {
    if (await DataConnectionChecker().hasConnection) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

BoxConstraints cons() => BoxConstraints(maxHeight: 20.0, maxWidth: 50.0);

toast(String title) =>
    Fluttertoast.showToast(msg: title, gravity: ToastGravity.BOTTOM);

Future exitApp(BuildContext context, Size size) {
  return showDialog(
    context: context,
    useSafeArea: true,
    builder: (context) => AlertDialog(
      title: Text("Are you sure you want to exit?"),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      content: Container(
        height: 70,
        width: size.width / 1.1,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                    color: AppColors.PRIMARY_COLOR,
                    onPressed: () async => SystemNavigator.pop(),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    child: Text("Yes", style: TextStyle(color: Colors.white))),
                MaterialButton(
                  color: AppColors.PRIMARY_COLOR,
                  onPressed: () => Navigator.of(context).pop(),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Future deleteConfirmation(
  BuildContext context,
) {
  return showDialog(
    context: context,
    useSafeArea: true,
    builder: (context) => AlertDialog(
      title: Text("Are you sure you want to delete this list?"),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      content: Container(
        height: 70,
        width: MediaQuery.of(context).size.width / 1.1,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                    color: AppColors.PRIMARY_COLOR,
                    onPressed: () async => Navigator.pop(context, true),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    child: Text("Yes", style: TextStyle(color: Colors.white))),
                MaterialButton(
                  color: AppColors.PRIMARY_COLOR,
                  onPressed: () => Navigator.of(context).pop(),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    ),
  );
}

getLocalDate(String date) {
  DateTime strToDateTime = DateTime.parse(DateTime.parse(date).toString());
  DateTime convertLocal = strToDateTime.toLocal();
  String d = DateFormat().add_jm().format(convertLocal);
  return d;
}

SvgPicture svgIcon({double hw, String str}) {
  return SvgPicture.asset(str,
      color: AppColors.PRIMARY_COLOR, height: hw, width: hw);
}

Center processing = Center(child: CircularProgressIndicator());

Widget commonMsgFunc(String msg) => Container(child: Center(child: Text(msg)));

//* pagination loadder
Widget buildProgressIndicator() {
  return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(child: new CircularProgressIndicator()));
}

Widget indexListing(int index) =>
    Container(margin: EdgeInsets.only(top: 10.0), child: Text('${index + 1}'));

Widget errorPart() => Container(
    height: 100.0,
    width: 100,
    decoration: BoxDecoration(
        color: Colors.grey, borderRadius: BorderRadius.circular(7.0)),
    child: Text(" "));

shareInfo() async {
  String shareLink = "";
  String storeType = "";
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (Platform.isAndroid) {
    storeType = "play";
    shareLink = prefs.getString(General.ANDROID_LINK);
  } else if (Platform.isIOS) {
    storeType = "apple";
    shareLink = prefs.getString(General.IOS_LINK);
  }
  Share.share(
      '${'Get REC’d App to share your favorite Movies, TV Shows, Books, and Podcasts with your favorite people to download app on $storeType store $shareLink'}');
}

shareItem({String id, String type, String itemName}) async {
  String shareLink;

  createDynamicLink(id: id, type: type).then((val) {
    shareLink = val;
    Share.share('''Check out $itemName $type on REC'd!
    $shareLink''');
  });
}

Future<String> createDynamicLink({String id, String type}) async {
  var parameters = DynamicLinkParameters(
    uriPrefix: 'https://recd.page.link',
    link: Uri.parse('https://recd/$type?id=$id'),
    androidParameters: AndroidParameters(
      packageName: "com.micrasol.recd",
    ),
    iosParameters: IosParameters(
      bundleId: "com.micrasol.recd",
      appStoreId: '1552393632',
    ),
  );
  // var dynamicUrl = await parameters.buildUrl();
  var shortLink = await parameters.buildShortLink();
  var shortUrl = shortLink.shortUrl;

  return shortUrl.toString();
}

Widget oops() {
  return Scaffold(
    body: Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
            hBox(5.0),
            Text(
              "Ooops something went wrong!!!",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    ),
  );
}
