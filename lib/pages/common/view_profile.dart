import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/common/view_profile_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';

class ViewProfile extends StatefulWidget {
  final RouteArgument routeArgument;
  ViewProfile({Key key, this.routeArgument}) : super(key: key);

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends StateMVC<ViewProfile> {
  ViewProfileController _con;
  _ViewProfileState() : super(ViewProfileController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();

    _con.getUserDetails(widget.routeArgument.param).then((value) {
      if (mounted)
        setState(() {
          _con.viewProfileList = value;
          _con.isLoading = false;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: appBar(),
        body: Consumer<NetworkModel>(
          builder: (context, value, child) {
            if (value.connection) {
              return body();
            } else {
              return NetworkErrorPage();
            }
          },
        ));
  }

  AppBar appBar() {
    return AppBar(
        centerTitle: true,
        title: Text("View Profile",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        leading: leadingIcon(context: context));
  }

  Widget body() {
    return _con.isLoading
        ? processing
        : _con.viewProfileList == null
            ? commonMsgFunc("No User Found")
            : Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                hBox(25.0),
                _con.viewProfileList.isRequestSendedByMe
                    ? pendingText()
                    : _con.viewProfileList.isRequestPending
                        ? requestSection()
                        : _con.viewProfileList.isMyFriend == false &&
                                _con.viewProfileList.isRequestPending ==
                                    false &&
                                _con.viewProfileList.isRequestSendedByMe ==
                                    false
                            ? _con.afterSentFriendRequest
                                ? alreadySentRequest(_con.viewProfileList.name)
                                : sendFriendRequest()
                            : hBox(0),
                Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        shape: BoxShape.circle),
                    child: CircleAvatar(
                        radius: 55.0,
                        backgroundImage: CachedNetworkImageProvider(
                            _con.viewProfileList.profile == null
                                ? Global.staticRecdImageUrl
                                : _con.viewProfileList.profile))),
                hBox(20.0),
                Text(
                    _con.viewProfileList.name == null
                        ? 'RECd'
                        : _con.viewProfileList.name,
                    maxLines: 1,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                hBox(7.0),
                Text(
                    _con.viewProfileList.username == null
                        ? "RECd"
                        : "@${_con.viewProfileList.username}",
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 1),
                hBox(10.0),
                Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 45.0,
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 1,
                                  color: Colors.grey.withOpacity(0.5))
                            ]),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(children: [
                                    topText(
                                        _con.viewProfileList.recs.toString()),
                                    hBox(2.0),
                                    bottomText("RECs")
                                  ])),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pushNamed(
                                    RouteKeys.GET_FRIENDS,
                                    arguments: RouteArgument(
                                        id: _con.viewProfileList.id)),
                                child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(children: [
                                      topText(_con.viewProfileList.friends
                                          .toString()),
                                      hBox(2.0),
                                      bottomText("Friends")
                                    ])),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(children: [
                                    topText(
                                        _con.viewProfileList.groups.toString()),
                                    hBox(2.0),
                                    bottomText("Groups")
                                  ]))
                            ]))),
                hBox(25.0),
                _con.viewProfileList.bio == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _con.viewProfileList.bio,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 15,
                        ),
                      )
              ]);
  }

  Widget alreadySentRequest(String username) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        text: TextSpan(
          text: "Sent request to ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          children: <TextSpan>[
            TextSpan(
              text: '$username',
              style: TextStyle(
                color: AppColors.PRIMARY_COLOR,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        softWrap: true,
      ),
    );
  }

  Widget sendFriendRequest() {
    return Container(
      child: Column(
        children: [
          MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0)),
              clipBehavior: Clip.none,
              color: AppColors.PRIMARY_COLOR,
              splashColor: AppColors.WHITE_COLOR,
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _con.addFriendFlag
                    ? processing
                    : Text("Add Friend", style: TextStyle(color: Colors.white)),
              ),
              onPressed: _con.addFriendFlag
                  ? null
                  : () {
                      setState(() => _con.addFriendFlag = true);
                      _con
                          .sendFriendRequest(_con.viewProfileList.id)
                          .then((val) {
                        if (val) {
                          toast("Friend request sent !!!");
                        } else {
                          toast("Try again after sometime !!!");
                        }
                        setState(() {
                          _con.addFriendFlag = false;
                          _con.afterSentFriendRequest = true;
                        });
                      });
                    }),
          hBox(5.0),
        ],
      ),
    );
  }

  Widget pendingText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Pending",
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 1,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
            color: Colors.grey,
          )),
    );
  }

  Text topText(String number) {
    return Text("$number",
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 1,
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 16.0, color: Colors.black));
  }

  Text commonText(String title) {
    return Text(
      "$title",
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 1,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15.0,
        color: Colors.black,
      ),
    );
  }

  Text bottomText(String title) {
    return Text(
      "$title",
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 1,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15.0,
      ),
    );
  }

  Widget requestSection() {
    return _con.viewProfileList.flag
        ? processing
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0)),
              clipBehavior: Clip.none,
              color: AppColors.WHITE_COLOR,
              splashColor: AppColors.PRIMARY_COLOR,
              elevation: 8.0,
              child: Text("Reject"),
              onPressed: () {
                setState(() => _con.viewProfileList.flag = true);
                _con
                    .sendAcceptRejectRequest(
                        id: _con.viewProfileList.id, type: "rejected")
                    .then(
                  (val) {
                    setState(() {
                      _con.viewProfileList.isMyFriend = false;
                      _con.viewProfileList.flag = false;
                      _con.viewProfileList.isRequestPending = false;
                      _con.viewProfileList.isRequestSendedByMe = false;
                    });
                  },
                );
              },
            ),
            wBox(5.0),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0)),
                clipBehavior: Clip.antiAlias,
                color: AppColors.PRIMARY_COLOR,
                splashColor: AppColors.WHITE_COLOR,
                elevation: 8.0,
                child: Text("Accept", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setState(() => _con.viewProfileList.flag = true);
                  _con
                      .sendAcceptRejectRequest(
                          id: _con.viewProfileList.id, type: "accepted")
                      .then((val) {
                    if (val)
                      setState(() {
                        _con.viewProfileList.isMyFriend = true;
                        _con.viewProfileList.flag = false;
                        _con.viewProfileList.isRequestPending = false;
                        _con.viewProfileList.isRespondPending = false;
                        _con.viewProfileList.isRequestSendedByMe = false;
                      });
                  });
                })
          ]);
  }
}
