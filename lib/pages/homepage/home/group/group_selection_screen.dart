import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/home/group/group_selection_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/model/usermodel.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class GroupSelectionScreen extends StatefulWidget {
  GroupSelectionScreen({Key key}) : super(key: key);

  @override
  _GroupSelectionScreenState createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends StateMVC<GroupSelectionScreen> {
  GroupSelectionController _con;
  _GroupSelectionScreenState() : super(GroupSelectionController()) {
    _con = controller;
  }

//* list of users and selection of user home->+
  @override
  void initState() {
    super.initState();
    _con.pageScroll.addListener(() {
      if (_con.pageScroll.position.pixels ==
          _con.pageScroll.position.maxScrollExtent) {
        _con.page++;
        print(_con.page);
        setState(() => _con.isPaginationLoading = true);
        _con
            .fetchAllUser(
          query: _con.searchQuery,
          searchPage: _con.page,
        )
            .then((value) {
          if (value != null)
            setState(() {
              _con.showItemList.addAll(value);
              _con.isPaginationLoading = false;
            });
        });
      }
    });
    _con.isUserDataLoading = true;
    _con
        .fetchAllUser(query: _con.searchQuery, searchPage: _con.page)
        .then((value) {
      setState(() {
        _con.showItemList = value;
        _con.isUserDataLoading = false;
      });
    });
    _con.fToast = FToast();
    _con.fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
            title: Text("New Group",
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            leading: leadingIcon(context: context),
            centerTitle: true,
            actions: [
              _con.isDataColleting
                  ? Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Center(
                          child: CircularProgressIndicator(
                        backgroundColor: AppColors.PRIMARY_COLOR,
                      )),
                    )
                  : InkWell(
                      onTap: () => _con.addAndCheckGroupMember(context),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text("Done",
                            style: TextStyle(
                                fontSize: 15.0,
                                color: AppColors.PRIMARY_COLOR,
                                fontWeight: FontWeight.w500)),
                      ))
            ]),
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

  Widget _body() {
    return Container(
      child: Column(
        children: [
          hBox(10.0),
          _searchBox(),
          inviteFriends(context),
          hBox(20.0),
          _con.isUserDataLoading || _con.isSearchDataLoading
              ? userShimmer(context)
              : _con.showItemList == null
                  ? commonMsgFunc("No User Found")
                  : _con.showItemList.isEmpty
                      ? commonMsgFunc("No User Found")
                      : listofUser()
        ],
      ),
    );
  }

  Widget listofUser() {
    return Expanded(
        child: ListView.separated(
            itemCount: _con.showItemList.length,
            controller: _con.pageScroll,
            itemBuilder: (context, index) {
              if (_con.selectedPerson.length != 0) {
                for (var i = 0; i < _con.selectedPerson.length; i++) {
                  if (_con.selectedPerson[i].userid ==
                      _con.showItemList[index].userid) {
                    _con.showItemList[index].flag = true;
                  }
                }
              }
              return ListTile(
                  leading: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: CachedNetworkImageProvider(
                          _con.showItemList[index].profileimage)),
                  title: Text("${_con.showItemList[index].name}",
                      style: TextStyle(fontSize: 14.0)),
                  trailing: Checkbox(
                      activeColor: AppColors.PRIMARY_COLOR,
                      value: _con.showItemList[index].flag,
                      onChanged: (value) {
                        setState(() {
                          if (value) {
                            _con.showItemList[index].flag = value;
                            _con.selectedPerson.add(new UserInfo(
                                userid: _con.showItemList[index].userid,
                                name: _con.showItemList[index].name,
                                username: _con.showItemList[index].username,
                                profileimage:
                                    _con.showItemList[index].profileimage,
                                flag: value));
                          } else if (value == false) {
                            _con.selectedPerson.removeWhere((item) =>
                                item.userid == _con.showItemList[index].userid);
                            _con.showItemList[index].flag = value;
                          }
                        });
                      }));
            },
            separatorBuilder: (context, index) => d()));
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: TextField(
          onChanged: (value) {
            setState(() {
              _con.isSearchDataLoading = true;
              _con.showItemList = null;
              _con.page = 1;
            });
            _con.fetchAllUser(searchPage: _con.page, query: value).then((info) {
              setState(() {
                _con.showItemList = null;
                if (info == null || info.isEmpty) {
                  _con.showItemList = null;
                  _con.isSearchDataLoading = false;
                } else {
                  _con.showItemList = info;
                  _con.isSearchDataLoading = false;
                }
              });
            }).catchError(
                (err) => setState(() => _con.isUserDataLoading = false));
          },
          controller: _con.editingController,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            isDense: true,
            hintText: "Search by name and username",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
            prefixIcon: Icon(Icons.search, color: Colors.black, size: 24.0),
            focusColor: Colors.grey[400],
            focusedBorder: decor(colors: AppColors.PRIMARY_COLOR, width: 1.0),
            border: decor(
              colors: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
