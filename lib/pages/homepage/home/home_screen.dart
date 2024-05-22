import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/home/home_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/listner/notification_listner.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends StateMVC<HomeScreen> {
  HomeController _con;
  _HomeScreenState() : super(HomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.pageController.addListener(() {
      if (_con.pageController.position.pixels ==
          _con.pageController.position.maxScrollExtent) {
        setState(() => _con.isPageLoading = true);
        _con.page++;
        _con.fetchConversation(_con.page).then((list) {
          if (list != null)
            setState(() {
              _con.conList.addAll(list);
              _con.isPageLoading = false;
            });
        });
      }
    });
    setState(() => _con.isLoading = true);
    _con.fetchConversation(_con.page).then((value) {
      if (mounted) {
        setState(() {
          _con.conList = value;
          _con.isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: _appBar(),
        body: Consumer<NetworkModel>(
          builder: (context, net, child) {
            if (net.connection) {
              return _body();
            } else {
              return NetworkErrorPage();
            }
          },
        ));
  }

//* Appbar
  AppBar _appBar() {
    return AppBar(
      title: Image.asset(ImagePath.ICONPATH, scale: 3.0),
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(Icons.people_sharp,
              color: AppColors.PRIMARY_COLOR, size: 30.0),
          onPressed: () =>
              Navigator.of(context).pushNamed(RouteKeys.HOME_CONTACT),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.PRIMARY_COLOR,
                  size: 25.0,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteKeys.NOTIFICATION);
                },
              ),
              Consumer<NListner>(
                builder: (context, nListner, child) {
                  if (nListner.getNBadge == 0) {
                    return hBox(0);
                  } else {
                    return new Positioned(
                        right: 8,
                        child: new Container(
                            padding: EdgeInsets.all(2),
                            decoration: new BoxDecoration(
                                color: Colors.red,
                                // borderRadius: BorderRadius.circular(6),
                                shape: BoxShape.circle),
                            constraints: BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(nListner.getNBadge.toString(),
                                style: new TextStyle(
                                    color: Colors.white, fontSize: 10),
                                textAlign: TextAlign.center)));
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }

//* Body
  Widget _body() {
    return _con.isLoading
        ? processing
        : _con.conList == null || _con.conList.isEmpty
            ? commonMsgFunc("No RECs Found")
            : Container(
                child: Center(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _con.page = 1;
                      await _con.fetchConversation(_con.page).then((value) {
                        if (mounted)
                          setState(() {
                            _con.conList = value;
                            _con.isLoading = false;
                          });
                      });
                    },
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _con.isPageLoading
                          ? _con.conList.length + 1
                          : _con.conList.length,
                      controller: _con.pageController,
                      itemBuilder: (context, index) {
                        if (index == _con.conList.length) {
                          return buildProgressIndicator();
                        } else {
                          if (_con.conList[index].isGroup == true) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).pushNamed(
                                    RouteKeys.GROUP_RECOMMENDED,
                                    arguments: RouteArgument(
                                      param: [
                                        _con.conList[index].id,
                                        _con.conList[index].title,
                                        _con.conList[index].isGroup
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 2.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                            onTap: () => Navigator.of(context)
                                                .pushNamed(
                                                    RouteKeys
                                                        .GROUP_PARTICIPANTS_EV,
                                                    arguments: RouteArgument(
                                                        param: _con
                                                            .conList[index]
                                                            .id)),
                                            child: _firstSection(
                                                image: _con
                                                    .conList[index].conImage,
                                                text:
                                                    _con.conList[index].title)),
                                        _secSection(
                                            title: _con
                                                .conList[index].lastMsgTitle,
                                            desc: _con
                                                .conList[index].lastMsgSubTitle,
                                            img: _con
                                                .conList[index].lastMsgImage,
                                            humanDate:
                                                _con.conList[index].humanDate),
                                        _con.conList[index].recdBy.length >= 1
                                            ? InkWell(
                                                onTap: () =>
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                  RouteKeys.RECD_BY_FRIEND_LIST,
                                                  arguments: RouteArgument(
                                                    param: [
                                                      _con.conList[index]
                                                          .itemId,
                                                      _con.conList[index]
                                                          .itemType,
                                                    ],
                                                  ),
                                                ),
                                                child: _thirdSection(
                                                    _con.conList[index].recdBy,
                                                    _con.conList[index]
                                                        .totalUsers),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                d(),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          Navigator.of(context).pushNamed(
                                        RouteKeys.GROUP_RECOMMENDED,
                                        arguments: RouteArgument(
                                          param: [
                                            _con.conList[index].id,
                                            _con.conList[index].title,
                                            _con.conList[index].isGroup
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 2.0),
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () => Navigator.of(context)
                                                  .pushNamed(
                                                      RouteKeys.VIEW_PROFILE,
                                                      arguments: RouteArgument(
                                                          param: _con
                                                              .conList[index]
                                                              .userId)),
                                              child: _firstSection(
                                                text: _con.conList[index].title,
                                                image: _con
                                                    .conList[index].conImage,
                                              ),
                                            ),
                                            _secSection(
                                                title: _con.conList[index]
                                                    .lastMsgTitle,
                                                desc: _con.conList[index]
                                                    .lastMsgSubTitle,
                                                img: _con.conList[index]
                                                    .lastMsgImage,
                                                humanDate: _con
                                                    .conList[index].humanDate),
                                          ],
                                        ),
                                      ),
                                    ),
                                    d(),
                                  ],
                                ),
                              ],
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              );
  }

  //* include top profile image,name and other name
  Widget _firstSection({String text, String image}) {
    Size size = MediaQuery.of(context).size;
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(image),
              radius: 18.0)),
      wBox(10.0),
      Container(
          width: size.width / 1.6,
          child: Text(text,
              softWrap: true,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1))
    ]);
  }

  Widget _secSection(
      {String img, String title, String desc, String humanDate}) {
    String d = TimeAgo().timeAgo(DateTime.parse(
      DateTime.parse(humanDate).toString(),
    ));
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              width: 100.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7.0),
                child: ImageWidget(
                  imageUrl: img,
                  height: 100.0,
                  width: 100.0,
                ),
              ),
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(top: 2.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(title,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w500))),
                  hBox(7.0),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 300.0,
                            minHeight: 40.0,
                            maxHeight: 100.0,
                          ),
                          child: Container(
                            height: 40.0,
                            child: Html(
                              data: desc,
                              style: {
                                'body': Style(
                                  display: Display.INLINE,
                                  color: Colors.grey,
                                ),
                              },
                              shrinkWrap: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  hBox(7.0),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(d,
                          style: TextStyle(
                            fontSize: 12.0,
                          )))
                ]),
          ))
        ]);
  }

//* include photo overlay and name
  Widget _thirdSection(List list, int totalUsers) {
    double w = getUserImageListWidth(list);
    String recdByTitle = "";
    if (totalUsers == 1) {
      recdByTitle = "REC'd by ${list[0]['created_by']['name']}";
    } else if (totalUsers == 2) {
      recdByTitle =
          "REC'd by ${list[0]['created_by']['name']} and ${totalUsers - 1} other";
    } else if (totalUsers >= 3) {
      recdByTitle =
          "REC'd by ${list[0]['created_by']['name']} and ${totalUsers - 1} others";
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Container(
              width: w,
              child: new Stack(children: <Widget>[
                list.length >= 1
                    ? CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16.0,
                        child: new CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            list[0]['created_by']['profile_path'] == null
                                ? Global.staticRecdImageUrl
                                : list[0]['created_by']['profile_path'],
                          ),
                          radius: 15.0,
                        ),
                      )
                    : null,
                list.length >= 2
                    ? new Positioned(
                        left: 20.0,
                        child: new CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16.0,
                            child: new CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  list[1]['created_by']['profile_path'] == null
                                      ? Global.staticRecdImageUrl
                                      : list[1]['created_by']['profile_path'],
                                ),
                                radius: 15.0)))
                    : Container(),
                list.length >= 3
                    ? new Positioned(
                        left: 40.0,
                        child: new CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16.0,
                            child: new CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                list[2]['created_by']['profile_path'] == null
                                    ? Global.staticRecdImageUrl
                                    : list[2]['created_by']['profile_path'],
                              ),
                              radius: 15.0,
                            )))
                    : hBox(0.0)
              ])),
          Flexible(
            child: Text(
              recdByTitle,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
              style: TextStyle(
                color: AppColors.PRIMARY_COLOR,
                fontSize: 12.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
