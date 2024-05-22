import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/bottombar_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class BottomBarScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  BottomBarScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends StateMVC<BottomBarScreen> {
  BottomBarController _con;
  _BottomBarScreenState() : super(BottomBarController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.setIndex(widget.routeArgument.param);

    // _con.fetchAppLinks();
    // Provider.of<NetworkModel>(context, listen: false).updateStatus(true);
    if (Global.movieCategory.isEmpty || Global.podCastCategory.isEmpty) {
      _con.fetchCategory("movie").then((movieCategory) {
        _con.fetchCategory("tv").then((tvCategory) {
          _con.fecthPodcastCategory().then((podCastCategory) {
            setState(() {
              Global.movieCategory = movieCategory;
              Global.tvShowCategory = tvCategory;
              Global.podCastCategory = podCastCategory;
            });
          });
        });
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (Platform.isAndroid) {
      return WillPopScope(
          onWillPop: () async {
            return exitApp(context, size);
          },
          child: scaffold());
    } else {
      return scaffold();
    }
  }

  Widget scaffold() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _con.scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _con.index,
          selectedIconTheme: IconThemeData(
            color: AppColors.PRIMARY_COLOR,
          ),
          selectedItemColor: AppColors.PRIMARY_COLOR,
          elevation: 5.0,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.0,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.0,
          ),
          unselectedIconTheme: IconThemeData(
            color: Colors.black,
          ),
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          onTap: (value) => _con.changeTabValue(value),
          items: [
            BottomNavigationBarItem(
              label: "Home",
              icon: (_con.index == 0)
                  ? icon(ImagePath.HOME1)
                  : icon(ImagePath.HOME2),
            ),
            BottomNavigationBarItem(
              label: "Trending",
              icon: (_con.index == 1)
                  ? SvgPicture.asset(
                      ImagePath.TRENDING,
                      color: AppColors.PRIMARY_COLOR,
                      height: 20.0,
                      width: 20.0,
                    )
                  : icon(
                      ImagePath.TRENDING,
                    ),
            ),
            BottomNavigationBarItem(
              label: "Explore",
              icon: (_con.index == 2)
                  ? SvgPicture.asset(
                      ImagePath.SEARCH,
                      color: AppColors.PRIMARY_COLOR,
                      height: 20.0,
                      width: 20.0,
                    )
                  : icon(
                      ImagePath.SEARCH,
                    ),
            ),
            BottomNavigationBarItem(
              label: "Bookmarks",
              icon: (_con.index == 3)
                  ? icon(ImagePath.BOOKMARK1)
                  : icon(ImagePath.BOOKMARK2),
            ),
            BottomNavigationBarItem(
              label: "Profile",
              icon: (_con.index == 4)
                  ? icon(ImagePath.USER)
                  : icon(ImagePath.USERUNFILL),
            )
          ],
        ),
        body: _con.internet == false
            ? commonMsgFunc("No Internet !!!")
            : _con.children[_con.index],
      ),
    );
  }

  Widget icon(String imagepath) {
    return SvgPicture.asset(
      imagepath,
      height: 20.0,
      width: 20.0,
    );
  }
}
