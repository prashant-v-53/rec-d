import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/common/view_profile_controller.dart';
import 'package:recd/controller/homepage/profile/friends_request_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class FriendRequestScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  FriendRequestScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends StateMVC<FriendRequestScreen> {
  FriendRequestController _con;
  _FriendRequestScreenState() : super(FriendRequestController()) {
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
            .fetchAllFriends(page: _con.page, searchQuery: _con.searchData)
            .then((value) {
          if (value != null) setState(() => _con.friendsList.addAll(value));
        });
      }
    });
    setState(() => _con.isFriendsLoading = true);
    _con
        .fetchAllFriends(page: _con.page, searchQuery: _con.searchData)
        .then((val) {
      if (mounted)
        setState(() => {_con.friendsList = val, _con.isFriendsLoading = false});
    });
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(key: _con.scaffoldKey, appBar: _appBar(), body: _body());

  Widget appBarTitle = new Text("Friends",
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600));
  Icon actionIcon = new Icon(Icons.search, color: AppColors.PRIMARY_COLOR);

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
                                  page: _con.page, searchQuery: _con.searchData)
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
                    this.appBarTitle = new Text("Friends",
                        style: TextStyle(color: Colors.black));
                    _con.fetchAllFriends(page: 1, searchQuery: "").then((val) {
                      _con.friendsList = val;
                      _con.isFriendsLoading = false;
                    });
                  }
                });
              })
        ]);
  }

  Widget _body() {
    return _con.isFriendsLoading
        ? processing
        : _con.friendsList == null || _con.friendsList.isEmpty
            ? commonMsgFunc("No friends found")
            : ListView.builder(
                controller: _con.pageScroll,
                itemBuilder: (context, index) {
                  return Container(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed(
                          RouteKeys.VIEW_PROFILE,
                          arguments:
                              RouteArgument(param: _con.friendsList[index].id)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: profileImage(index),
                          title: titleText(index),
                          subtitle: subTitle(index),
                          trailing: _con.friendsList[index].flag == false
                              ? _con.friendsList[index].isRequestPending
                                  ? Text("${_con.text}")
                                  : _con.friendsList[index].isRespondPending
                                      ? acceptRejectRequest(index)
                                      : addButton(index)
                              : Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    height: 28.0,
                                    width: 28.0,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: _con.friendsList.length);
  }

  acceptRejectRequest(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.highlight_remove_rounded,
            color: AppColors.PRIMARY_COLOR,
            size: 30.0,
          ),
          onPressed: () {
            setState(() => _con.friendsList[index].flag = true);
            ViewProfileController()
                .sendAcceptRejectRequest(
              id: _con.friendsList[index].id,
              type: "rejected",
            )
                .then((val) {
              setState(() {
                toast("Rejected");
                _con.friendsList[index].isRespondPending = false;
                _con.friendsList[index].flag = false;
              });
            });
          },
        ),
        IconButton(
            icon: Icon(
              Icons.how_to_reg_rounded,
              color: AppColors.PRIMARY_COLOR,
              size: 30.0,
            ),
            onPressed: () {
              setState(() => _con.friendsList[index].flag = true);
              ViewProfileController()
                  .sendAcceptRejectRequest(
                id: _con.friendsList[index].id,
                type: "accepted",
              )
                  .then((val) {
                toast("Accepted !!");
                setState(() {
                  _con.text = "View Profile";

                  _con.friendsList[index].isRequestPending = true;

                  _con.friendsList[index].flag = false;
                });
              });
            })
      ],
    );
  }

  Widget addButton(int index) {
    return IconButton(
      onPressed: () {
        setState(() => _con.friendsList[index].flag = true);
        _con.sendFriendRequest(_con.friendsList[index].id).then((val) {
          (val)
              ? setState(() => _con.friendsList[index].isRequestPending = true)
              : setState(
                  () => _con.friendsList[index].isRequestPending = false);
          setState(() => _con.friendsList[index].flag = false);
        });
      },
      icon: Icon(
        Icons.person_add_rounded,
        color: AppColors.PRIMARY_COLOR,
        size: 27.0,
      ),
    );
  }

  Widget profileImage(int index) {
    return CircleAvatar(
        radius: 30.0,
        backgroundImage: NetworkImage(_con.friendsList[index].profile));
  }

  Widget titleText(int index) {
    return Text(_con.friendsList[index].name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600));
  }

  Widget subTitle(int index) {
    return Text('@${_con.friendsList[index].username}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 12.0, color: Colors.grey, fontWeight: FontWeight.w500));
  }
}
