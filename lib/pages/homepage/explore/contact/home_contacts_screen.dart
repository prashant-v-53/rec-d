import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/explore/contact/home_contact_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/helpers/app_colors.dart';

class HomeContactScreen extends StatefulWidget {
  final RouteArgument routeArgument;

  HomeContactScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _HomeContactScreenState createState() => _HomeContactScreenState();
}

class _HomeContactScreenState extends StateMVC<HomeContactScreen> {
  HomeContactController _con;
  _HomeContactScreenState() : super(HomeContactController()) {
    _con = controller;
  }

  Widget appBarTitle = new Text(
    "Contacts",
    style: TextStyle(
        color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20.0),
  );
  Icon actionIcon = new Icon(
    Icons.search,
    color: AppColors.PRIMARY_COLOR,
  );

  @override
  void initState() {
    super.initState();
    // * Recents part
    _con.recentController.addListener(() {
      if (_con.recentController.position.pixels ==
          _con.recentController.position.maxScrollExtent) {
        _con.recentPage++;
        _con.getRecentData(_con.recentPage).then((list) {
          if (list != null) setState(() => _con.recentItemList.addAll(list));
        });
      }
    });
    loadRecents();
    // * Friends part
    _con.friendsController.addListener(() {
      if (_con.friendsController.position.pixels ==
          _con.friendsController.position.maxScrollExtent) {
        _con.friendsPage++;
        _con.getFriendsData(_con.friendsPage).then((list) {
          if (list != null) setState(() => _con.friendsItemList.addAll(list));
        });
      }
    });
    // setState(() => _con.isFriendsLoading = true);
    // _con.getFriendsData(_con.friendsPage).then((list) {
    //   setState(() {
    //     _con.friendsItemList = list;
    //     _con.isFriendsLoading = false;
    //   });
    // });
    loadFriends();
    // * Group part
    _con.groupController.addListener(() {
      if (_con.groupController.position.pixels ==
          _con.groupController.position.maxScrollExtent) {
        _con.groupPage++;
        _con.getGroupData(_con.groupPage).then((list) {
          if (list != null) setState(() => _con.groupItemList.addAll(list));
        });
      }
    });
    loadGroups();
    // setState(() => _con.isGroupLoading = true);
    // _con.getGroupData(_con.groupPage).then((list) {
    //   setState(() {
    //     _con.groupItemList = list;
    //     _con.isGroupLoading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: _appBar(),
      floatingActionButton: SpeedDial(
          marginBottom: 20,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          closeManually: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.3,
          backgroundColor: AppColors.PRIMARY_COLOR,
          foregroundColor: Colors.white,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
                child: Icon(Icons.add, size: 25.0),
                backgroundColor: AppColors.PRIMARY_COLOR,
                label: 'Add Friend',
                labelStyle: TextStyle(fontSize: 15.0),
                onTap: () =>
                    Navigator.of(context).pushNamed(RouteKeys.FRIEND_REQUEST)),
            SpeedDialChild(
              child: Icon(Icons.group_add),
              backgroundColor: AppColors.PRIMARY_COLOR,
              label: 'Create Group',
              labelStyle: TextStyle(fontSize: 15.0),
              onTap: () => _con.sendButtonClicked(context),
            )
          ]),
      body: Consumer<NetworkModel>(
        builder: (context, value, child) {
          if (value.connection) {
            return _body();
          } else {
            return NetworkErrorPage();
          }
        },
      ),
    );
  }

  AppBar _appBar() {
    return new AppBar(
      centerTitle: true,
      title: appBarTitle,
      leading: leadingIcon(context: context),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share,
            color: Colors.black,
          ),
          onPressed: () {
            shareInfo();
          },
        )
      ],
    );
  }

  Widget _body() {
    return SafeArea(
      child: DefaultTabController(
        length: 6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0)),
                elevation: 3.0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60.0,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(7.0)),
                  child: _topTabBar(),
                ),
              ),
            ),
            if (_con.topIndex == 0) listOfRecent(),
            if (_con.topIndex == 1) listOfFriends(),
            if (_con.topIndex == 2) listOfGroups()
          ],
        ),
      ),
    );
  }

  //* Top Tab Bar
  Widget _topTabBar() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_recents(), _friends(), _groupsAll()]);
  }

  Widget _recents() {
    return Expanded(
        child: Center(
            child: InkWell(
                onTap: () => _con.changeTopIndex(0),
                child: Container(
                    alignment: Alignment.center,
                    height: 70.0,
                    decoration: BoxDecoration(
                        color: (_con.topIndex == 0)
                            ? AppColors.PRIMARY_COLOR
                            : Colors.transparent,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(7.0),
                            bottomLeft: Radius.circular(7.0))),
                    child: Text("Recents",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: (_con.topIndex == 0)
                                ? Colors.white
                                : AppColors.PRIMARY_COLOR))))));
  }

  Widget _friends() {
    return Expanded(
        child: Center(
            child: InkWell(
                onTap: () => _con.changeTopIndex(1),
                child: Container(
                    alignment: Alignment.center,
                    height: 70.0,
                    decoration: BoxDecoration(
                        color: (_con.topIndex == 1)
                            ? AppColors.PRIMARY_COLOR
                            : Colors.transparent),
                    child: Text("Friends",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: (_con.topIndex == 1)
                                ? Colors.white
                                : AppColors.PRIMARY_COLOR))))));
  }

  Widget _groupsAll() {
    return Expanded(
      child: Center(
        child: GestureDetector(
          dragStartBehavior: DragStartBehavior.start,
          behavior: HitTestBehavior.opaque,
          onTap: () => _con.changeTopIndex(2),
          child: Container(
            alignment: Alignment.center,
            height: 70.0,
            decoration: BoxDecoration(
              color: (_con.topIndex == 2)
                  ? AppColors.PRIMARY_COLOR
                  : Colors.transparent,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(7.0),
                bottomRight: Radius.circular(7.0),
              ),
            ),
            child: Text(
              "Groups",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: (_con.topIndex == 2)
                    ? Colors.white
                    : AppColors.PRIMARY_COLOR,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget listOfRecent() {
    Size size = MediaQuery.of(context).size;

    return Expanded(
      child: _con.isRecentLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _con.recentItemList == null || _con.recentItemList.isEmpty
              ? Center(
                  child: Text("No recent friends or groups"),
                )
              : RefreshIndicator(
                  onRefresh: () => loadRecents(),
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: _con.recentController,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            if (_con.recentItemList[index].isGroup) {
                              Navigator.of(context).pushNamed(
                                  RouteKeys.GROUP_PARTICIPANTS_EV,
                                  arguments: RouteArgument(
                                      param:
                                          _con.recentItemList[index].userid));
                            } else {
                              Navigator.of(context).pushNamed(
                                RouteKeys.VIEW_PROFILE,
                                arguments: RouteArgument(
                                  param: _con.recentItemList[index].userid,
                                ),
                              );
                            }
                          },
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: (size.width < 330) ? 27.0 : 30.0,
                                      backgroundImage:
                                          CachedNetworkImageProvider(_con
                                              .recentItemList[index]
                                              .profileimage),
                                    ),
                                    wBox(10.0),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: size.width * 0.6,
                                            child: Text(
                                              _con.recentItemList[index].name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          hBox(3.0),
                                          _con.recentItemList[index].isGroup
                                              ? Text(
                                                  "@${_con.recentItemList[index]?.name ?? ''}",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.grey,
                                                  ),
                                                )
                                              : Text(
                                                  "@${_con.recentItemList[index]?.username ?? ''}",
                                                  style: TextStyle(
                                                      fontSize: 12.0,
                                                      color: Colors.grey))
                                        ])
                                  ])));
                    },
                    separatorBuilder: (context, index) => d(),
                    itemCount: _con.recentItemList.length,
                  ),
                ),
    );
  }

  Widget listOfFriends() {
    Size size = MediaQuery.of(context).size;
    return Expanded(
        child: _con.isFriendsLoading
            ? processing
            : _con.friendsItemList == null || _con.friendsItemList.isEmpty
                ? commonMsgFunc("No friends")
                : RefreshIndicator(
                    onRefresh: () => loadFriends(),
                    child: ListView.separated(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _con.friendsController,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () => Navigator.of(context)
                                .pushNamed(RouteKeys.VIEW_PROFILE,
                                    arguments: RouteArgument(
                                      param: _con.friendsItemList[index].userid,
                                    )),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                          radius:
                                              (size.width < 330) ? 27.0 : 30.0,
                                          backgroundImage: NetworkImage(_con
                                              .friendsItemList[index]
                                              .profileimage)),
                                      wBox(10.0),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                            Container(
                                                width: double.infinity,
                                                child: Text(
                                                    _con.friendsItemList[index]
                                                        .name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                            hBox(3.0),
                                            Container(
                                                width: double.infinity,
                                                child: Text(
                                                    '@${_con.friendsItemList[index].username}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.w500)))
                                          ]))
                                    ])));
                      },
                      separatorBuilder: (context, index) => d(),
                      itemCount: _con.friendsItemList.length,
                    ),
                  ));
  }

  Widget listOfGroups() {
    Size size = MediaQuery.of(context).size;
    return Expanded(
        child: _con.isGroupLoading
            ? processing
            : _con.groupItemList == null || _con.groupItemList.isEmpty
                ? commonMsgFunc("No groups")
                : RefreshIndicator(
                    onRefresh: () => loadGroups(),
                    child: ListView.separated(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _con.groupController,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () => Navigator.of(context).pushNamed(
                                  RouteKeys.GROUP_PARTICIPANTS_EV,
                                  arguments: RouteArgument(
                                      param: _con.groupItemList[index].userid)),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius:
                                              (size.width < 330) ? 27.0 : 30.0,
                                          backgroundImage: NetworkImage(
                                            _con.groupItemList[index]
                                                .profileimage,
                                          ),
                                        ),
                                        wBox(10.0),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                              Container(
                                                width: double.infinity,
                                                child: Text(
                                                  _con.groupItemList[index]
                                                      .name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              hBox(3.0),
                                              Row(children: [
                                                Container(
                                                    width: 80.0,
                                                    child: new Stack(children: <
                                                        Widget>[
                                                      firstGroupImg(_con
                                                          .groupItemList[index]
                                                          .groupImageList),
                                                      new Positioned(
                                                        left: 20.0,
                                                        child: new CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 15.0,
                                                          child: secondGroupImg(_con
                                                              .groupItemList[
                                                                  index]
                                                              .groupImageList),
                                                        ),
                                                      ),
                                                      new Positioned(
                                                          left: 40.0,
                                                          child: new CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              radius: 15.0,
                                                              child: thirdGroupImg(_con
                                                                  .groupItemList[
                                                                      index]
                                                                  .groupImageList)))
                                                    ]))
                                              ])
                                            ]))
                                      ])));
                        },
                        separatorBuilder: (context, index) => d(),
                        itemCount: _con.groupItemList.length),
                  ));
  }

  firstGroupImg(list) {
    if (list.isEmpty) {
      return Container();
    } else {
      return new CircleAvatar(
        backgroundImage: NetworkImage(
          list[0],
        ),
        radius: 14.0,
      );
    }
  }

  secondGroupImg(list) {
    if (list.length < 2) {
      return Container();
    } else {
      return new CircleAvatar(
        backgroundImage: NetworkImage(
          list[1],
        ),
        radius: 14.0,
      );
    }
  }

  thirdGroupImg(list) {
    if (list.length < 3) {
      return Container();
    } else {
      return new CircleAvatar(
        backgroundImage: NetworkImage(
          list[2],
        ),
        radius: 14.0,
      );
    }
  }

  loadRecents() {
    _con.recentPage = 1;
    setState(() => _con.isRecentLoading = true);
    _con.getRecentData(_con.recentPage).then((list) {
      setState(() {
        _con.recentItemList = list;
        _con.isRecentLoading = false;
      });
    });
  }

  loadFriends() {
    _con.friendsPage = 1;
    setState(() => _con.isFriendsLoading = true);
    _con.getFriendsData(_con.friendsPage).then((list) {
      setState(() {
        _con.friendsItemList = list;
        _con.isFriendsLoading = false;
      });
    });
  }

  loadGroups() {
    _con.groupPage = 1;
    setState(() => _con.isGroupLoading = true);
    _con.getGroupData(_con.groupPage).then((list) {
      setState(() {
        _con.groupItemList = list;
        _con.isGroupLoading = false;
      });
    });
  }
}
