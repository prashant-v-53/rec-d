import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/home/group/group_recommended_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/conversation_message_model.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';

class GroupRecommendedScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  GroupRecommendedScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _GroupRecommendedScreenState createState() => _GroupRecommendedScreenState();
}

class _GroupRecommendedScreenState extends StateMVC<GroupRecommendedScreen> {
  GroupRecommendedController _con;
  _GroupRecommendedScreenState() : super(GroupRecommendedController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    //* groupid[0] -> title[1] ->  isGroup[2]
    _con.pageController.addListener(() {
      if (_con.pageController.position.pixels ==
          _con.pageController.position.maxScrollExtent) {
        _con.page++;
        _con
            .getConversationMessages(
                '${widget.routeArgument.param[0]}', _con.page)
            .then((list) {
          if (list != null) setState(() => _con.messagList.addAll(list));
        });
      }
    });
    setState(() => _con.isLoading = true);
    _con
        .getConversationMessages('${widget.routeArgument.param[0]}', _con.page)
        .then((list) {
      if (mounted)
        setState(() {
          _con.messagList = list;
          _con.isLoading = false;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: _appbar(
        id: widget.routeArgument.param[0],
        title: widget.routeArgument.param[1],
        isGroup: widget.routeArgument.param[2],
      ),
      body: _con.isLoading
          ? processing
          : _con.messagList == null || _con.messagList.isEmpty
              ? commonMsgFunc("No RECs Found")
              : _body(),
    );
  }

  Widget _appbar({String id, String title, bool isGroup}) {
    return AppBar(
        title: Text("$title",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.w500)),
        leading: leadingIcon(context: context),
        centerTitle: false,
        actions: [
          isGroup
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: IconButton(
                      icon: Icon(Icons.info, color: AppColors.PRIMARY_COLOR),
                      onPressed: () => Navigator.of(context).pushNamed(
                          RouteKeys.GROUP_PARTICIPANTS_EV,
                          arguments: RouteArgument(param: id))))
              : _con.isLoading
                  ? Container()
                  : _con.messagList == null || _con.messagList.isEmpty
                      ? Container()
                      : IconButton(
                          icon:
                              Icon(Icons.info, color: AppColors.PRIMARY_COLOR),
                          onPressed: () => Navigator.of(context).pushNamed(
                            RouteKeys.VIEW_PROFILE,
                            arguments: RouteArgument(
                              param: _con.userId,
                            ),
                          ),
                        )
        ]);
  }

  Widget _body() {
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: ListView.builder(
            cacheExtent: 99,
            reverse: true,
            controller: _con.pageController,
            itemCount: _con.messagList.length,
            itemBuilder: (BuildContext context, int index) {
              ConversationMessageModel data = _con.messagList[index];

              if (_con.messagList[index].isMyMsg) {
                return GestureDetector(
                  onTap: () => navigateToItemScreen(data.itemType, data.itemId),
                  child: rightBox(_con.messagList[index]),
                );
              } else
                return leftBox(_con.messagList[index]);
            }),
      ),
    );
  }

  Widget leftBox(ConversationMessageModel data) {
    String d = TimeAgo()
        .timeAgo(DateTime.parse(DateTime.parse(data.msgTime).toString()));
    Size size = MediaQuery.of(context).size;
    if (size.width < 330) {
      return Padding(
          padding: EdgeInsets.all(4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(
                        RouteKeys.VIEW_PROFILE,
                        arguments: RouteArgument(param: data.userId)),
                    child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                            padding: EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.PRIMARY_COLOR)),
                            child: CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(data.image),
                            )))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text("${data.username}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontWeight: FontWeight.w500))),
                  GestureDetector(
                      onTap: () =>
                          navigateToItemScreen(data.itemType, data.itemId),
                      child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                              height: 100.0,
                              width: 230.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.grey[200],
                              ),
                              child: Row(children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.0),
                                        topLeft: Radius.circular(10.0)),
                                    child: ImageWidget(
                                      imageUrl: data.msgImage,
                                      height: 100.0,
                                      width: 80.0,
                                    )),
                                wBox(15.0),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text("${data.msgTitle}",
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500)),
                                      hBox(5.0),
                                      Text(
                                          data.itemType == "Tv Show"
                                              ? "TV Show"
                                              : data.itemType,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12.0)),
                                      hBox(5.0),
                                      Row(children: [
                                        Icon(Icons.star,
                                            color: AppColors.PRIMARY_COLOR,
                                            size: 20.0),
                                        wBox(10.0),
                                        Text("${data.avgRating}",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0))
                                      ])
                                    ]))
                              ])))),
                  Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(d, style: TextStyle(color: Colors.grey)))
                ])
              ]));
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                  RouteKeys.VIEW_PROFILE,
                  arguments: RouteArgument(param: data.userId)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.PRIMARY_COLOR,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(data.image),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    "${data.username}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                GestureDetector(
                  onTap: () => navigateToItemScreen(data.itemType, data.itemId),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      height: 110.0,
                      width: 250.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                topLeft: Radius.circular(10.0),
                              ),
                              child: ImageWidget(
                                imageUrl: data.msgImage,
                                height: 110.0,
                                width: 90.0,
                              )),
                          wBox(15.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${data.msgTitle}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                hBox(5.0),
                                Text(
                                  data.itemType == "Tv Show"
                                      ? "TV Show"
                                      : data.itemType,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                                hBox(5.0),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.PRIMARY_COLOR,
                                      size: 20.0,
                                    ),
                                    wBox(10.0),
                                    Text(
                                      "${data.avgRating}",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.0,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    d,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  Widget rightBox(ConversationMessageModel data) {
    Size size = MediaQuery.of(context).size;

    String d = TimeAgo()
        .timeAgo(DateTime.parse(DateTime.parse(data.msgTime).toString()));
    if (size.width < 330) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  height: 100.0,
                  width: 230.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                    color: AppColors.PRIMARY_COLOR,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${data.msgTitle}",
                              softWrap: true,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                            hBox(5.0),
                            Text(
                              data.itemType == "Tv Show"
                                  ? "TV Show"
                                  : data.itemType,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12.0),
                            ),
                            hBox(5.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.star,
                                    color: Colors.white, size: 20.0),
                                wBox(10.0),
                                Text("${data.avgRating}",
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12.0))
                              ],
                            )
                          ],
                        ),
                      ),
                      wBox(15.0),
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: ImageWidget(
                          imageUrl: data.msgImage,
                          height: 110.0,
                          width: 90.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  d,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  height: 110.0,
                  width: 250.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                    color: AppColors.PRIMARY_COLOR,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${data.msgTitle}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: true,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                            hBox(5.0),
                            Text(
                              data.itemType == "Tv Show"
                                  ? "TV Show"
                                  : data.itemType,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12.0,
                              ),
                            ),
                            hBox(5.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                                wBox(10.0),
                                Text(
                                  "${data.avgRating}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12.0,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      wBox(15.0),
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: ImageWidget(
                          imageUrl: data.msgImage,
                          height: 110.0,
                          width: 90.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  d,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  navigateToItemScreen(String type, String id) {
    Navigator.of(context).pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [type, id]));
  }
}
