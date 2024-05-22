import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/profile/profile_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends StateMVC<ProfileScreen> {
  ProfileController _con;
  _ProfileScreenState() : super(ProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();

    setState(() => _con.isRecsLoading = true);
    _con.fetchAllRecs(_con.page).then((val) {
      setState(() {
        _con.recsList = val;
        _con.isRecsLoading = false;
      });
    });
    _con.pageScroll.addListener(() {
      if (_con.pageScroll.position.pixels ==
          _con.pageScroll.position.maxScrollExtent) {
        _con.page++;

        setState(() => _con.isPaginationLoading = true);

        _con.fetchAllRecs(_con.page).then((value) {
          if (value != null) setState(() => _con.recsList.addAll(value));
        });
      }
    });
    isInternet().then((value) {
      if (value)
        _con.getUserDetails().then((userInfo) {
          _con.getBookmarks().then((value) {
            if (mounted)
              setState(() {
                _con.bookmarkData = value;
                _con.userData = userInfo;
                _con.isDataLoading = false;
              });
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Consumer<NetworkModel>(
        builder: (context, value, child) {
          if (value.connection) {
            return _con.isDataLoading ? processing : _body();
          } else {
            return NetworkErrorPage();
          }
        },
      ),
    );
  }

//* App Bar
  AppBar _appBar() {
    Size size = MediaQuery.of(context).size;
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "@${_con?.userData?.username ?? ''}",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      actions: [
        InkWell(
          onTap: () async {
            showDialog(
              context: context,
              useSafeArea: true,
              builder: (context) => AlertDialog(
                title: Text("Are you sure you want to log out?"),
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    7.0,
                  ),
                ),
                content: Container(
                  height: 50,
                  width: size.width / 1.1,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                            color: AppColors.PRIMARY_COLOR,
                            onPressed: () => _con.logOut(context),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                25.0,
                              ),
                            ),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          MaterialButton(
                            color: AppColors.PRIMARY_COLOR,
                            onPressed: () => Navigator.of(context).pop(),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                25.0,
                              ),
                            ),
                            child: Text(
                              "No",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              Icons.logout,
              color: AppColors.PRIMARY_COLOR,
            ),
          ),
        ),
      ],
    );
  }

// * Body
  Widget _body() {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: _con.userData == null
          ? commonMsgFunc("No data found")
          : Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    profileCard(size),
                    hBox(5.0),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 5.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Recent RECs",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    data(),
                    _con.recsList.isEmpty
                        ? Container()
                        : _con.recsList.length <= 5
                            ? Container()
                            : InkWell(
                                onTap: () => Navigator.of(context)
                                    .pushNamed(RouteKeys.GET_RECS),
                                child: Container(
                                    alignment: Alignment.center,
                                    width: size.width,
                                    child: Text("Show More",
                                        style: TextStyle(
                                            color: AppColors.PRIMARY_COLOR,
                                            fontWeight: FontWeight.w500)))),
                    _con.recsList.length <= 5
                        ? Container()
                        : Divider(
                            endIndent: 30.0,
                            indent: 30.0,
                            color: Colors.grey,
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget profileCard(Size size) {
    const EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0);
    return Card(
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Hero(
                    tag: _con.userData.profile == null
                        ? Global.staticRecdImageUrl
                        : _con.userData.profile,
                    child: CircleAvatar(
                        radius: (size.width < 330) ? 40 : 45.0,
                        backgroundImage: CachedNetworkImageProvider(
                            _con.userData.profile == null
                                ? Global.staticRecdImageUrl
                                : _con.userData.profile))),
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed(RouteKeys.GET_RECS),
                    child: Padding(
                      padding: padding,
                      child: Column(
                        children: [
                          titleNumber("${_con.userData.recs}"),
                          hBox(2.0),
                          titleText("RECs")
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed(
                          RouteKeys.GET_FRIENDS,
                          arguments: RouteArgument(id: _con.userData.id)),
                      child: Padding(
                          padding: padding,
                          child: Column(children: [
                            titleNumber("${_con.userData.friends}"),
                            hBox(2.0),
                            titleText("Friends")
                          ]))),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed(RouteKeys.GET_GROUPS),
                    child: Padding(
                      padding: padding,
                      child: Column(
                        children: [
                          titleNumber("${_con.userData.groups}"),
                          hBox(2.0),
                          titleText("Groups")
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            hBox(5.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text("${_con?.userData?.name ?? ''}",
                  maxLines: 1,
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
            ),
            hBox(2.0),
            _con.userData.bio.trim().isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "${_con?.userData?.bio ?? ''}",
                      maxLines: 3,
                    ),
                  ),
            hBox(5.0),
            editProfileButton()
          ],
        ),
      ),
    );
  }

  Text titleNumber(String number) => Text("$number",
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 16.0, color: Colors.black));
  Text titleText(String title) => Text(title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0));

  Widget data() {
    return _con.isRecsLoading
        ? processing
        : _con.recsList.isEmpty
            ? commonMsgFunc("No RECs Found")
            : Container(
                child: ListView.builder(
                  cacheExtent: 99,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: _con.pageScroll,
                  itemCount:
                      (_con.recsList.length < 5) ? _con.recsList.length : 5,
                  itemBuilder: (context, index) => Container(
                    // margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 2.0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => navigateToItemScreen(
                                    _con.recsList[index].itemType,
                                    _con.recsList[index].itemId),
                                child: _secSection(
                                  title: _con.recsList[index].title,
                                  desc: _con.recsList[index].subtitle,
                                  img: _con.recsList[index].image,
                                  humanDate: _con.recsList[index].humanDate,
                                ),
                              ),
                              _thirdSection(_con.recsList[index].recipientList,
                                  _con.recsList[index].totalReco),
                              Divider(
                                endIndent: 15.0,
                                indent: 15.0,
                                color: Colors.grey,
                              ),
                              // hBox(5.0)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
  }

  navigateToItemScreen(String type, String id) {
    Navigator.of(context).pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [type, id]));
  }

  Widget _secSection(
      {String img, String title, String desc, String humanDate}) {
    String d =
        TimeAgo().timeAgo(DateTime.parse(DateTime.parse(humanDate).toString()));
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            width: 100.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                7.0,
              ),
              child: ImageWidget(
                imageUrl: img,
                height: 100.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    title,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                  ),
                ),
                hBox(7.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Align(
                    child: Container(
                      height: 40.0,
                      child: Html(
                        data: desc,
                        style: {
                          'body': Style(
                            display: Display.INLINE,
                            color: Colors.grey,
                          )
                        },
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                ),
                hBox(7.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ),
                hBox(7.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

//* include photo overlay and name
  Widget _thirdSection(List list, int totalUsers) {
    String title = "REC'd to ";
    list[0]['is_group']
        ? title += list[0]['group_name']
        : title += list[0]['members']['name'];

    if (totalUsers == 1) {
      title = title;
    } else if (totalUsers == 2) {
      title += " and ${totalUsers - 1} other";
    } else if (totalUsers >= 3) {
      title += " and ${totalUsers - 1} others";
    }
    double w = getUserImageListWidth(list);

    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          Container(
              width: w,
              child: new Stack(children: <Widget>[
                list[0]['is_group']
                    ? imgCircle(list[0]['group_cover_path'])
                    : imgCircle(list[0]['members']['profile_path']),
                list.length > 1
                    ? Positioned(
                        left: 20.0,
                        child: list[1]['is_group']
                            ? imgCircle(list[1]['group_cover_path'])
                            : imgCircle(list[1]['members']['profile_path']))
                    : hBox(0.0),
                list.length > 2
                    ? new Positioned(
                        left: 40.0,
                        child: list[2]['is_group']
                            ? imgCircle(list[2]['group_cover_path'])
                            : imgCircle(list[2]['members']['profile_path']))
                    : hBox(0.0)
              ])),
          Expanded(
            child: Text("$title",
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 1,
                style:
                    TextStyle(color: AppColors.PRIMARY_COLOR, fontSize: 12.0)),
          )
        ]));
  }

  Widget editProfileButton() {
    return Align(
      alignment: Alignment.center,
      child: MaterialButton(
          onPressed: () => Navigator.of(context).pushNamed(
                RouteKeys.EDIT_PROFILE,
                arguments: RouteArgument(
                  param: [
                    _con.userData.profile == null
                        ? Global.staticRecdImageUrl
                        : _con.userData.profile,
                    _con.userData.name,
                    _con.userData.email,
                    _con.userData.mobile,
                    _con.userData.dob,
                    _con.userData.bio
                  ],
                ),
              ),
          child: Text("Edit Profile",
              style: TextStyle(color: AppColors.PRIMARY_COLOR)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(color: AppColors.PRIMARY_COLOR, width: 0.8)),
          height: 45.0,
          minWidth: MediaQuery.of(context).size.width / 2),
    );
  }

  CircleAvatar imgCircle(String image) => CircleAvatar(
      backgroundColor: Colors.white,
      radius: 16.0,
      child: new CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(image), radius: 15.0));
}
