import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/bottombar_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/api_variable_key.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/listner/notification_listner.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  String message = '';
  int count;
  int onMsgCount;
  bool isTransfer = false;

  @override
  void initState() {
    super.initState();
    fetchAppInfo().then((value) => checkUserIslogin());

    getMessage(context);

    updateStatusInit();
    initDynamicLinks();
    _getNotification();
    // checkLogin();
  }

  Future<PermissionStatus> _getNotification() async {
    final status = await Permission.notification.request();
    return status;
  }

  // checkLogin() {
  //   checkUserLogin().then((value) {
  //     if (value) {
  //       getMessage(context);
  //       if(isTransfer==false){
  //         updateStatusInit();
  //       }
  //     }
  //   });
  // }

  //* notification
  void getMessage(BuildContext context) async {
    var token = await _firebaseMessaging?.getToken();
    debugPrint(token.toString());
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      setState(() => isTransfer = true);
      print('on **message $message');
      updateStatus();
    }, onResume: (Map<String, dynamic> message) async {
      if (Platform.isIOS) {
        if (message['notification_type'] == "recommndation") {
          String id = message['id'];
          String title = message['title'];

          transfer(id, title);
        } else if (message['notification_type'] == "friend_request") {
          String userid = message['id'];
          transferUser(userid);
        } else if (message['notification_type'] == "added_to_group") {
          String id = message['id'];
          String title = message['title'];
          transfer(id, title);
        }
      } else {
        if (message['data']['notification_type'] == "recommndation") {
          String id = message['data']['id'];
          String title = message['data']['title'];

          transfer(id, title);
        } else if (message['data']['notification_type'] == "friend_request") {
          String userid = message['data']['id'];
          transferUser(userid);
        } else if (message['data']['notification_type'] == "added_to_group") {
          String id = message['data']['id'];
          String title = message['data']['title'];
          transfer(id, title);
        }
        print('on resume $message');
        setState(() => isTransfer = true);
      }
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => isTransfer = true);
    });
  }

  transfer(String groupId, String title) {
    Navigator.of(context).pushNamed(RouteKeys.GROUP_RECOMMENDED,
        arguments: RouteArgument(param: ["$groupId", "$title", false]));
  }

  transferUser(String userId) {
    Navigator.of(context).pushNamed(
      RouteKeys.VIEW_PROFILE,
      arguments: RouteArgument(
        param: "$userId",
      ),
    );
  }

  updateStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int number = prefs.getInt("NNum");
    if (number == 0 || number == null) {
      prefs.setInt("NNum", 1);

      Provider.of<NListner>(context, listen: false).updateStatus(1);
    } else {
      int numBer = number;
      numBer++;
      prefs.setInt("NNum", numBer);
      Provider.of<NListner>(context, listen: false).updateStatus(numBer);
    }
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      checkUserLogin().then((val) {
        if (val) navigationToItem(deepLink);
      });
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    PendingDynamicLinkData data;
    if (Platform.isIOS) {
      await Future.delayed(Duration(seconds: 2), () async {
        data = await FirebaseDynamicLinks.instance.getInitialLink();
      });
    } else {
      data = await FirebaseDynamicLinks.instance.getInitialLink();
    }
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      checkUserLogin().then((val) {
        if (val) navigationToItem(deepLink);
      });
    }
  }

  navigationToItem(deepLink) async {
    if (deepLink != null) {
      String type;
      bool isItemAvailble = false;
      if (deepLink.pathSegments.contains('Movie')) {
        type = "Movie";
        isItemAvailble = true;
      } else if (deepLink.pathSegments.contains('Tv Show')) {
        type = "Tv Show";
        isItemAvailble = true;
      } else if (deepLink.pathSegments.contains('Podcast')) {
        type = "Podcast";
        isItemAvailble = true;
      } else if (deepLink.pathSegments.contains('Book')) {
        type = "Book";
        isItemAvailble = true;
      } else {
        type = "";
        isItemAvailble = false;
      }
      if (isItemAvailble) {
        String id = deepLink.queryParameters['id'];
        if (id != null) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pushNamed(
              RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
              // (route) => false,
              arguments: RouteArgument(
                param: [type, id],
              ),
            );
          });
        }
      } else {
        toast("Item not found");
      }
    }
  }

  checkUserIslogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(PrefsKey.ACCESS_TOKEN);

    if (token == null) {
      Navigator.of(context).pushNamed(
        RouteKeys.SLECTION_SIGN_IN_UP,
        // (route) => false,
      );
    } else {
      if (token.isNotEmpty) {
        Timer(
          Duration(seconds: 1),
          () => Navigator.of(context).pushNamed(
            RouteKeys.BOTTOMBAR,
            // (route) => false,
            arguments: RouteArgument(param: 0),
          ),
        );
      } else {
        Timer(
            Duration(seconds: 1),
            () => Navigator.of(context).pushNamed(
                  RouteKeys.SLECTION_SIGN_IN_UP,
                  // (route) => false,
                ));
      }
    }
  }

  Future<bool> checkUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(PrefsKey.ACCESS_TOKEN);

    if (token == null) {
      return false;
    } else {
      if (token.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }

  updateStatusInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int number = prefs.getInt("NNum");

    if (number == 0 || number == null) {
      prefs.setInt("NNum", 0);
      Provider.of<NListner>(context, listen: false).updateStatus(0);
    } else {
      int numb = prefs.getInt("NNum");
      Provider.of<NListner>(context, listen: false).updateStatus(numb);
    }
  }

  Future fetchAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      String url = "${App.RECd_URL}${API.APP_LINKS}";
      final response = await http.get(url);
      print(response?.statusCode);
      print(response?.body);
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        setState(() {
          Global.apiKey = res['data']['tmdb_api_key'];
          Global.podcastToken = res['data']['listennotes_api_key'];
          Global.tmdbApiBaseUrl = res['data']['tmdb_api_base_url'];
          Global.tmdbImgBaseUrl = res['data']['tmdb_img_base_url'];
          Global.tmdbBackdropBaseUrl = res['data']['tmdb_backdrop_base_url'];
          Global.podcastApiBaseUrl = res['data']['podcast_api_base_url'];
        });

        prefs.setString(General.ANDROID_LINK, res['data']['android_app_URL']);
        prefs.setString(General.IOS_LINK, res['data']['ios_app_URL']);
      } else {
        setSP(prefs);
      }
    } catch (e) {
      setSP(prefs);
    }
  }

  @override
  Widget build(BuildContext context) {
    Consumer(
      builder: (context, value, child) {
        if (value.connection) {
          return Scaffold(
            body: _body(),
            backgroundColor: AppColors.PRIMARY_COLOR,
          );
        } else {
          return NetworkErrorPage();
        }
      },
    );
    return Scaffold(
      backgroundColor: AppColors.PRIMARY_COLOR,
      body: _body(),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            ImagePath.ICONPATH,
            color: Colors.white,
            scale: 1.3,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Recommending Reimagined",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
