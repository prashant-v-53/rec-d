import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/profile/recdby_friends_list_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class RecdByFriendListScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  RecdByFriendListScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _RecdByFriendListScreenState createState() => _RecdByFriendListScreenState();
}

class _RecdByFriendListScreenState extends StateMVC<RecdByFriendListScreen> {
  RecdByFriendsController _con;
  _RecdByFriendListScreenState() : super(RecdByFriendsController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();

    //* id and type = params[0] and parmas[1]

    _con.pageScroll.addListener(() {
      if (_con.pageScroll.position.pixels ==
          _con.pageScroll.position.maxScrollExtent) {
        _con.page++;
        setState(() => _con.isPaginationLoading = true);
        _con
            .fetchRecdyFriends(
          id: widget.routeArgument.param[0],
          type: widget.routeArgument.param[1],
          page: _con.page,
        )
            .then((value) {
          if (value != null) setState(() => _con.friendsList.addAll(value));
        });
      }
    });
    setState(() => _con.isFriendsLoading = true);
    _con
        .fetchRecdyFriends(
      id: widget.routeArgument.param[0],
      type: widget.routeArgument.param[1],
      page: _con.page,
    )
        .then((val) {
      if (mounted)
        setState(() {
          _con.friendsList = val;
          _con.isFriendsLoading = false;
        });
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

  AppBar _appBar() {
    return AppBar(
      leading: leadingIcon(context: context),
      backgroundColor: Colors.white,
      title: Text("REC'd By",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }

  Widget _body() {
    Size size = MediaQuery.of(context).size;
    return _con.isFriendsLoading
        ? Center(child: CircularProgressIndicator())
        : _con.friendsList == null || _con.friendsList.isEmpty
            ? Center(child: Text("No friends"))
            : ListView.separated(
                controller: _con.pageScroll,
                itemBuilder: (context, index) {
                  return Container(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed(
                          RouteKeys.VIEW_PROFILE,
                          arguments:
                              RouteArgument(param: _con.friendsList[index].id)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: (size.width < 330) ? 27.0 : 30.0,
                              backgroundImage: NetworkImage(
                                _con.friendsList[index].profile,
                              ),
                            ),
                            wBox(10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    child: Text(_con.friendsList[index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  hBox(3.0),
                                  Container(
                                    width: double.infinity,
                                    child: Text(
                                        '@${_con.friendsList[index].username}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  hBox(3.0),
                                ],
                              ),
                            ),
                            wBox(5.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return d();
                },
                itemCount: _con.friendsList.length,
              );
  }
}
