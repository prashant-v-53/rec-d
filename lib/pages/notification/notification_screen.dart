import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/notification/notification_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/listner/notification_listner.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends StateMVC<NotificationScreen> {
  NotificationController _con;
  _NotificationScreenState() : super(NotificationController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();

    _con.pageScroll.addListener(() {
      if (_con.pageScroll.position.pixels ==
          _con.pageScroll.position.maxScrollExtent) {
        _con.page++;
        setState(() => _con.isPaginationLoading = true);
        _con.fetchNotificationRecs(_con.page).then((value) {
          if (value != null)
            setState(() {
              _con.notificationList.addAll(value);
            });
        });
      }
    });
    setState(() => _con.isRecsLoading = true);
    _con.fetchNotificationRecs(_con.page).then((val) {
      if (mounted)
        setState(() {
          _con.notificationList = val;
          _con.isRecsLoading = false;
          clearN();
        });
    });
  }

  clearN() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("NNum", 0);
    Provider.of<NListner>(context, listen: false).updateStatus(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: _appBar(),
        body: Consumer<NetworkModel>(
          builder: (context, value, child) {
            if (value.connection) {
              return _body();
            } else {
              return NetworkErrorPage();
            }
          },
        ));
  }

  AppBar _appBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        "Notifications",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      leading: leadingIcon(
        context: context,
      ),
    );
  }

  Widget _body() {
    return RefreshIndicator(
      onRefresh: () async {
        _con.page = 1;
        await _con
            .fetchNotificationRecs(_con.page)
            .then((value) => setState(() => _con.notificationList = value));
      },
      child: _con.isRecsLoading
          ? processing
          : _con.notificationList == null || _con.notificationList.isEmpty
              ? commonMsgFunc("No notifications")
              : ListView.builder(
                  itemCount: _con.notificationList.length,
                  controller: _con.pageScroll,
                  itemBuilder: (context, index) => Column(
                    children: [
                      _box(index),
                    ],
                  ),
                ),
    );
  }

  Widget _box(int index) {
    Size size = MediaQuery.of(context).size;

    String d = TimeAgo().timeAgo(DateTime.parse(
        DateTime.parse(_con.notificationList[index].humanDate).toString()));
    return Container(
        width: size.width,
        child: Column(
          children: [
            SizedBox(
              width: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                viewProfile(
                  index: index,
                  size: size,
                ),
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (size.width < 330) ? wBox(15.0) : wBox(22.0),
                                  _con.notificationList[index]
                                                  .notificationType ==
                                              "friend_request" &&
                                          _con.notificationList[index]
                                                  .isRequestPending ==
                                              false
                                      ? acceptRejectMsg(
                                          index: index,
                                          size: size,
                                        )
                                      : _con.notificationList[index]
                                                  .notificationType ==
                                              "added_to_group"
                                          ? addToGroup(
                                              index: index,
                                              size: size,
                                            )
                                          : _con.notificationList[index]
                                                      .notificationType !=
                                                  "friend_request"
                                              ? navigationToScreen(
                                                  index: index,
                                                  size: size,
                                                )
                                              : acceptRejectSection(
                                                  index: index,
                                                  size: size,
                                                ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: notificationTime(d),
                          width: double.infinity,
                        ),
                      ]),
                ),
              ],
            ),
            div()
          ],
        ));
  }

  Widget acceptRejectMsg({Size size, int index}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RouteKeys.VIEW_PROFILE,
          arguments: RouteArgument(param: _con.notificationList[index].userId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hBox(15.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
            child: Container(
              width: size.width / 1.5,
              child: Text(
                  "${_con.notificationList[index].userName} is now your friend",
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                      color: AppColors.PRIMARY_COLOR,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget acceptRejectSection({int index, Size size}) => Column(children: [
        notificationTitle(index: index, size: size),
        hBox(10.0),
        _con.notificationList[index].flag
            ? processing
            : Row(children: [
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0)),
                    clipBehavior: Clip.none,
                    color: AppColors.WHITE_COLOR,
                    splashColor: AppColors.PRIMARY_COLOR,
                    elevation: 8.0,
                    child: Text("Reject"),
                    onPressed: () {
                      setState(() => _con.notificationList[index].flag = true);
                      _con
                          .sendAcceptRejectRequest(
                              id: _con.notificationList[index].userId,
                              type: "rejected")
                          .then((val) {
                        setState(() {
                          _con.notificationList[index].flag = false;
                          _con.notificationList.removeWhere((item) =>
                              item.id == _con.notificationList[index].id);
                        });
                      });
                    }),
                wBox(5.0),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0)),
                    clipBehavior: Clip.antiAlias,
                    color: AppColors.PRIMARY_COLOR,
                    splashColor: AppColors.WHITE_COLOR,
                    elevation: 8.0,
                    child:
                        Text("Accept", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      setState(() => _con.notificationList[index].flag = true);
                      _con
                          .sendAcceptRejectRequest(
                              id: _con.notificationList[index].userId,
                              type: "accepted")
                          .then((val) {
                        if (val) {
                          setState(() {
                            _con.notificationList[index].flag = false;
                            _con.notificationList[index].isRequestPending =
                                false;
                          });
                        }
                      });
                    }),
              ])
      ]);

  GestureDetector viewProfile({int index, Size size}) => GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(RouteKeys.VIEW_PROFILE,
            arguments:
                RouteArgument(param: _con.notificationList[index].userId)),
        child: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
              _con.notificationList[index].profileImage),
          radius: 22.0,
        ),
      );

  GestureDetector navigationToScreen({int index, Size size}) => GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(RouteKeys.GROUP_RECOMMENDED,
            arguments: RouteArgument(param: [
              _con.notificationList[index].conversationId,
              _con.notificationList[index].conversationTitle,
              _con.notificationList[index].isGroup
            ]));
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        wBox(12.0),
        notificationTitle(index: index, size: size),
        hBox(12.0),
        notificationImage(index)
      ]));

  GestureDetector addToGroup({int index, Size size}) => GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(RouteKeys.GROUP_RECOMMENDED,
            arguments: RouteArgument(param: [
              _con.notificationList[index].conversationId,
              _con.notificationList[index].conversationTitle,
              _con.notificationList[index].isGroup
            ]));
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        wBox(12.0),
        notificationTitle(index: index, size: size),
      ]));

  Widget notificationTitle({Size size, int index}) {
    return Container(
        width: size.width / 1.5,
        child: Text("${_con.notificationList[index].title}",
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(fontSize: 15.0, color: Colors.grey[700])));
  }

  Widget notificationImage(int index) => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                    width: 70.0,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: ImageWidget(
                          imageUrl: _con.notificationList[index].titleImage,
                          height: 70.0,
                          width: 70.0,
                        ))))
          ]);

  Widget notificationTime(String d) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: Align(
          alignment: Alignment.bottomRight,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("$d", style: TextStyle(fontSize: 12.0, color: Colors.grey))
              ])));

  Widget div() => Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(endIndent: 5.0, indent: 5.0));
}
