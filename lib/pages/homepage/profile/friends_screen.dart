import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/profile/friends_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class FriendsScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  FriendsScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends StateMVC<FriendsScreen> {
  FriendsController _con;
  _FriendsScreenState() : super(FriendsController()) {
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
        _con
            .fetchAllFriends(
                page: _con.page,
                searchQuery: _con.searchData,
                userId: widget.routeArgument.id)
            .then((value) {
          if (value != null) setState(() => _con.friendsList.addAll(value));
        });
      }
    });
    setState(() => _con.isFriendsLoading = true);
    _con
        .fetchAllFriends(
            page: _con.page,
            searchQuery: _con.searchData,
            userId: widget.routeArgument.id)
        .then((val) {
      if (mounted)
        setState(() => {_con.friendsList = val, _con.isFriendsLoading = false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  Widget appBarTitle = new Text(
    "Friends",
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
  );
  Icon actionIcon = new Icon(
    Icons.search,
    color: AppColors.PRIMARY_COLOR,
  );

  AppBar _appBar() {
    return AppBar(
      leading: leadingIcon(context: context),
      backgroundColor: Colors.white,
      title: appBarTitle,
      automaticallyImplyLeading: false,
      centerTitle: true,
      actions: <Widget>[
        new IconButton(
          icon: actionIcon,
          color: Colors.black,
          onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon =
                    new Icon(Icons.close, color: AppColors.PRIMARY_COLOR);

                this.appBarTitle = new TextField(
                    autofocus: true,
                    style: new TextStyle(color: Colors.black),
                    inputFormatters: [
                      new FilteringTextInputFormatter.allow(
                          RegExp("[a-zA-Z0-9 ]"))
                    ],
                    onChanged: (value) {
                      _con.page = 1;
                      _con.searchData = value;
                      _con
                          .fetchAllFriends(
                              page: _con.page,
                              searchQuery: _con.searchData,
                              userId: widget.routeArgument.id)
                          .then((search) {
                        _con.friendsList = search;
                        _con.isFriendsLoading = false;
                      }).catchError((err) => err);
                    },
                    decoration: new InputDecoration(
                        hintText: "Search Friends...",
                        hintStyle: new TextStyle(color: Colors.black),
                        border: InputBorder.none));
              } else {
                _con.isFriendsLoading = true;
                this.actionIcon = new Icon(Icons.search);
                this.appBarTitle =
                    new Text("Friends", style: TextStyle(color: Colors.black));

                _con
                    .fetchAllFriends(
                        page: 1,
                        searchQuery: "",
                        userId: widget.routeArgument.id)
                    .then((val) {
                  _con.friendsList = val;
                  _con.isFriendsLoading = false;
                });
              }
            });
          },
        ),
      ],
    );
  }

  Widget _body() {
    Size size = MediaQuery.of(context).size;
    return _con.isFriendsLoading
        ? processing
        : _con.friendsList == null || _con.friendsList.isEmpty
            ? commonMsgFunc("No friends")
            : ListView.separated(
                controller: _con.pageScroll,
                itemBuilder: (context, index) {
                  if (index == _con.friendsList.length) {
                    return buildProgressIndicator();
                  } else {
                    return Container(
                        child: InkWell(
                            onTap: () => Navigator.of(context).pushNamed(
                                RouteKeys.VIEW_PROFILE,
                                arguments: RouteArgument(
                                    param: _con.friendsList[index].id)),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                          radius:
                                              (size.width < 330) ? 27.0 : 30.0,
                                          backgroundImage: NetworkImage(
                                              _con.friendsList[index].profile)),
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
                                                    _con.friendsList[index]
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
                                                  '@${_con.friendsList[index].username}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12.0,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )),
                                            hBox(3.0),
                                          ])),
                                      wBox(5.0),
                                    ]))));
                  }
                },
                separatorBuilder: (context, index) => d(),
                itemCount: _con.isPaginationLoading
                    ? _con.friendsList.length + 1
                    : _con.friendsList.length);
  }
}
