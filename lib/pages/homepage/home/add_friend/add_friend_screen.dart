import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/home/add_friend/add_friend_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class AddFriendScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  AddFriendScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends StateMVC<AddFriendScreen> {
  AddFriendController _con;
  _AddFriendScreenState() : super(AddFriendController()) {
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
        _con.fetchAllUser(widget.routeArgument.param).then((value) {
          if (value != null)
            setState(() {
              _con.showItemList.addAll(value);
              _con.isPaginationLoading = false;
            });
        });
      }
    });
    _con.isUserDataLoading = true;
    _con.fetchAllUser(widget.routeArgument.param).then((value) {
      setState(() {
        _con.showItemList = value;
        _con.allSearchData = value;
        _con.isUserDataLoading = false;
      });
    });
    _con.fToast = FToast();
    _con.fToast.init(context);
  }

  @override
  void dispose() {
    _con.pageScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Friends",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: leadingIcon(context: context),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () => _con.addToNewList(
              context: context,
              gId: widget.routeArgument.param,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 18.0,
              ),
              child: Text(
                "Done",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.PRIMARY_COLOR,
                ),
              ),
            ),
          )
        ],
      ),
      body: Consumer<NetworkModel>(
        builder: (context, value, child) {
          if (value.connection) {
            return _con.isPersonAdding ? processing : _body();
          } else {
            return NetworkErrorPage();
          }
        },
      ),
    );
  }

  Widget _body() {
    return Container(
      child: Column(
        children: [
          hBox(10.0),
          _searchBox(),
          inviteFriends(context),
          _con.isUserDataLoading
              ? userShimmer(context)
              : _con.showItemList == null || _con.showItemList.isEmpty
                  ? commonMsgFunc("No User Found")
                  : listofUser(),
        ],
      ),
    );
  }

  Widget listofUser() {
    Size size = MediaQuery.of(context).size;
    return Expanded(
      child: ListView.separated(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _con.pageScroll,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: (size.width < 330) ? 25.0 : 30.0,
                  backgroundImage: NetworkImage(
                    _con.showItemList[index].profile,
                  ),
                ),
                wBox(10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _con.showItemList[index].name,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    hBox(3.0),
                  ],
                ),
                Spacer(),
                Checkbox(
                  activeColor: AppColors.PRIMARY_COLOR,
                  value: _con.showItemList[index].flag,
                  onChanged: (value) {
                    setState(() => _con.showItemList[index].flag = value);
                  },
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return d();
        },
        itemCount: _con.showItemList.length,
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: TextField(
          onChanged: (value) => _con.onSearch(value),
          controller: _con.editingController,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            isDense: true,
            hintText: "Search by username",
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
              size: 24.0,
            ),
            focusColor: Colors.grey[400],
            focusedBorder: decor(colors: Colors.grey[400], width: 1.0),
            border: decor(
              colors: AppColors.BORDER_COLOR,
            ),
          ),
        ),
      ),
    );
  }
}
