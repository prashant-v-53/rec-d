import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/bookmarks/bookmark_details_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/bookmark/bookmark_details_model.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class BookMarkDetailScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  BookMarkDetailScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _BookMarkDetailScreenState createState() => _BookMarkDetailScreenState();
}

class _BookMarkDetailScreenState extends StateMVC<BookMarkDetailScreen> {
  BookMarkDetailController _con;

  _BookMarkDetailScreenState() : super(BookMarkDetailController()) {
    _con = controller;
  }
  // static String title = "";

  @override
  void initState() {
    super.initState();
    _con.appBarTitle = _con.getAppTitle(widget.routeArgument.param[1]);
    // setState(() => title = widget.routeArgument.param[1]);
    isInternet().then((value) {
      if (value) {
        _con
            .getBookmarksbyId(
                bookmarkid: widget.routeArgument.param[0],
                page: _con.page,
                query: _con.searchData)
            .then((details) {
          setState(() {
            _con.bookMarkData = details;
            _con.isLoading = false;
          });
        });
      }
    });

    _con.pageScroll.addListener(() {
      if (_con.pageScroll.position.pixels ==
          _con.pageScroll.position.maxScrollExtent) {
        _con.page++;

        setState(() => _con.isPageLoading = true);
        _con
            .getBookmarksbyId(
          bookmarkid: widget.routeArgument.param[0],
          page: _con.page,
          query: _con.searchData,
        )
            .then((value) {
          setState(() => _con.isPageLoading = false);

          if (value != null) if (mounted)
            setState(() => _con.bookMarkData.addAll(value));
        });
      }
    });
    setState(() => _con.isLoading = true);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => Navigator.of(context).maybePop(),
      child: Scaffold(
          key: _con.scaffoldKey,
          appBar: _appBar(),
          body: _con.removeLoading
              ? processing
              : _con.isLoading
                  ? Center(child: shimmer(size))
                  : _con.bookMarkData == null
                      ? errMsg()
                      : _con.bookMarkData.isEmpty
                          ? errMsg()
                          : data(size)),
    );
  }

  Widget data(Size size) {
    return Container(
        height: size.height,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            cacheExtent: 99,
            itemCount: _con.isPageLoading
                ? _con.bookMarkData.length + 1
                : _con.bookMarkData.length,
            controller: _con.pageScroll,
            itemBuilder: (context, index) {
              if (index == _con.bookMarkData.length) {
                return buildProgressIndicator();
              } else {
                BookMarkDetails data = _con.bookMarkData[index];
                return InkWell(
                    onTap: () {
                      transferToPage(type: data.type, id: data.typeId);
                    },
                    child: Column(
                      children: [
                        Container(
                          color: Colors.grey,
                          height: 0.2,
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Column(children: [
                              Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    bookmarkImage(
                                        index: index, type: data.type),
                                    titleAndSubTitle(
                                      bname: data.bookmarkName,
                                      type: data.type,
                                    ),
                                    removeBookmark(index)
                                  ]),
                              data.recdBy.length > 0
                                  ? _thirdSection(data.recdBy, data.totalUsers)
                                  : Container(),
                            ])),
                      ],
                    ));
              }
            }));
  }

  Widget bookmarkImage({int index, String type}) {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: 100.0,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(
            7.0,
          ),
          child: ImageWidget(
            imageUrl: type == "Movie" || type == "Tv Show"
                ? "${_con.bookMarkData[index].bookmarkImage}"
                : _con.bookMarkData[index].bookmarkImage,
            height: 100.0,
            width: 100.0,
          )),
    );
  }

  Center errMsg() => Center(child: Text("No Bookmarks Found"));

  Widget titleAndSubTitle({
    String bname,
    String type,
  }) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$bname",
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(fontSize: 16.0)),
        hBox(5.0),
        Text(type,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: Colors.grey)),
        hBox(5.0),
      ],
    ));
  }

  Widget removeBookmark(int index) => Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          setState(() => _con.removeLoading = true);
          _con.removeBookMark(
              bookmarkId: widget.routeArgument.param[0],
              recDId: _con.bookMarkData[index].id,
              index: index);
        },
        child: svgIcon(hw: 20.0, str: ImagePath.BOOKMARK1),
      ));

  Icon actionIcon = new Icon(Icons.search, color: AppColors.PRIMARY_COLOR);

  AppBar _appBar() {
    return AppBar(
        leading: leadingIcon(context: context, isPopTrue: _con.isUpdated),
        backgroundColor: Colors.white,
        title: _con.appBarTitle,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          new IconButton(
              icon: actionIcon,
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (this.actionIcon.icon == Icons.search) {
                    this.actionIcon =
                        new Icon(Icons.close, color: AppColors.PRIMARY_COLOR);
                    _con.appBarTitle = new TextField(
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
                              .getBookmarksbyId(
                                  bookmarkid: widget.routeArgument.param[0],
                                  page: _con.page,
                                  query: _con.searchData)
                              .then((search) {
                            _con.bookMarkData = search;
                            _con.isLoading = false;
                          }).catchError((err) => err);
                        },
                        decoration: new InputDecoration(
                            hintText: "Search Bookmarks...",
                            hintStyle: new TextStyle(color: Colors.black),
                            border: InputBorder.none));
                  } else {
                    _con.isLoading = true;
                    this.actionIcon = new Icon(Icons.search);
                    _con.appBarTitle =
                        _con.getAppTitle(widget.routeArgument.param[1]);
                    _con
                        .getBookmarksbyId(
                            bookmarkid: widget.routeArgument.param[0],
                            page: 1,
                            query: "")
                        .then((val) {
                      _con.bookMarkData = val;
                      _con.isLoading = false;
                    });
                  }
                });
              })
        ]);
  }

  transferToPage({String type, String id}) {
    Navigator.of(context).pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [type, id]));
  }

//* include photo overlay and name
  Widget _thirdSection(List list, int totalUsers) {
    double w = getUserImageListWidth(list);
    String recdByTitle = "";
    if (totalUsers == 1) {
      recdByTitle = "REC'd by ${list[0]['created_by']['name']}";
    } else if (totalUsers == 2) {
      recdByTitle =
          "REC'd by ${list[0]['created_by']['name']} and ${totalUsers - 1} other";
    } else if (totalUsers >= 3) {
      recdByTitle =
          "REC'd by ${list[0]['created_by']['name']} and ${totalUsers - 1} others";
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Container(
              width: w,
              child: new Stack(children: <Widget>[
                list.length >= 1
                    ? CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16.0,
                        child: new CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            list[0]['created_by']['profile_path'] == null
                                ? Global.staticRecdImageUrl
                                : list[0]['created_by']['profile_path'],
                          ),
                          radius: 15.0,
                        ),
                      )
                    : null,
                list.length >= 2
                    ? new Positioned(
                        left: 20.0,
                        child: new CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16.0,
                            child: new CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  list[1]['created_by']['profile_path'] == null
                                      ? Global.staticRecdImageUrl
                                      : list[1]['created_by']['profile_path'],
                                ),
                                radius: 15.0)))
                    : Container(),
                list.length >= 3
                    ? new Positioned(
                        left: 40.0,
                        child: new CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16.0,
                            child: new CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  list[2]['created_by']['profile_path'] == null
                                      ? Global.staticRecdImageUrl
                                      : list[2]['created_by']['profile_path']),
                              radius: 15.0,
                            )))
                    : hBox(0.0)
              ])),
          Flexible(
            child: Text(
              recdByTitle,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
              style: TextStyle(
                color: AppColors.PRIMARY_COLOR,
                fontSize: 12.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
