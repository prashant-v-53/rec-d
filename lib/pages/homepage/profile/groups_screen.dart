import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/profile/groups_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class GroupScreen extends StatefulWidget {
  GroupScreen({Key key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends StateMVC<GroupScreen> {
  GroupsController _con;
  _GroupScreenState() : super(GroupsController()) {
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
            .fetchAllGroups(page: _con.page, searchQuery: _con.searchData)
            .then((value) {
          if (value != null) if (mounted)
            setState(() => _con.groupItemList.addAll(value));
        });
      }
    });
    setState(() => _con.isGroupsLoading = true);
    _con
        .fetchAllGroups(page: _con.page, searchQuery: _con.searchData)
        .then((val) {
      if (mounted)
        setState(() {
          _con.groupItemList = val;
          _con.isGroupsLoading = false;
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

  Widget appBarTitle = new Text(
    "Groups",
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
                              .fetchAllGroups(
                                  page: _con.page, searchQuery: _con.searchData)
                              .then((search) {
                            _con.groupItemList = search;
                            _con.isGroupsLoading = false;
                          }).catchError((err) => err);
                        },
                        decoration: new InputDecoration(
                            hintText: "Search Groups...",
                            hintStyle: new TextStyle(color: Colors.black),
                            border: InputBorder.none));
                  } else {
                    _con.isGroupsLoading = true;
                    this.actionIcon = new Icon(Icons.search);
                    this.appBarTitle = new Text("Groups",
                        style: TextStyle(color: Colors.black));
                    _con.fetchAllGroups(page: 1, searchQuery: "").then((val) {
                      _con.groupItemList = val;
                      _con.isGroupsLoading = false;
                    });
                  }
                });
              })
        ]);
  }

  Widget _body() {
    Size size = MediaQuery.of(context).size;
    return _con.isGroupsLoading
        ? Center(child: CircularProgressIndicator())
        : _con.groupItemList == null || _con.groupItemList.isEmpty
            ? Center(child: Text("No groups"))
            : ListView.separated(
                controller: _con.pageScroll,
                itemBuilder: (context, index) {
                  if (index == _con.groupItemList.length) {
                    return buildProgressIndicator();
                  } else {
                    return InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                            RouteKeys.GROUP_PARTICIPANTS_EV,
                            arguments: RouteArgument(
                                param: _con.groupItemList[index].id)),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: (size.width < 330) ? 27.0 : 30.0,
                                    backgroundImage: NetworkImage(
                                        _con.groupItemList[index].image),
                                  ),
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
                                                _con.groupItemList[index].name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        hBox(3.0),
                                        Row(children: [
                                          Container(
                                              width: 80.0,
                                              child:
                                                  new Stack(children: <Widget>[
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
                                                            .groupImageList))),
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
                                        ]),
                                        hBox(3.0)
                                      ])),
                                  wBox(5.0)
                                ])));
                  }
                },
                separatorBuilder: (context, index) => d(),
                itemCount: _con.isPaginationLoading
                    ? _con.groupItemList.length + 1
                    : _con.groupItemList.length);
  }

  firstGroupImg(list) {
    if (list.isEmpty) {
      return Container();
    } else {
      return new CircleAvatar(
          backgroundImage: NetworkImage(list[0]), radius: 14.0);
    }
  }

  secondGroupImg(list) {
    if (list.length < 2) {
      return Container();
    } else {
      return new CircleAvatar(
        backgroundImage: NetworkImage(list[1]),
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
}
