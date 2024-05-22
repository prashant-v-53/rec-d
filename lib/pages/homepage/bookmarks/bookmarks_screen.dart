import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/bookmarks/bookmarks_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/bookmark/bookmark_details_model.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class BookMarksScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  BookMarksScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _BookMarksScreenState createState() => _BookMarksScreenState();
}

class _BookMarksScreenState extends StateMVC<BookMarksScreen> {
  BookMarksController _con;
  _BookMarksScreenState() : super(BookMarksController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.pageScroller.addListener(() {
      if (_con.pageScroller.position.pixels ==
          _con.pageScroller.position.maxScrollExtent) {
        setState(() => _con.isPageLoading = true);
        _con.page++;
        _con
            .getAllBookmarks(page: _con.page, search: _con.searchData)
            .then((value) {
          setState(() => _con.isPageLoading = false);
          if (value != null) setState(() => _con.allBookMarks.addAll(value));
        });
      }
    });
    getData();
  }

  getData() async {
    _con.page = 1;
    setState(() => _con.isAllDataLoading = true);
    isInternet().then((value) {
      if (value) {
        _con
            .getAllBookmarks(page: _con.page, search: _con.searchData)
            .then((value) {
          _con.getBookmarks().then((val) {
            if (mounted)
              setState(() {
                _con.allBookMarks = value;
                _con.bookmarkData = val;
                _con.isAllDataLoading = false;
              });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: _appBar(),
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
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "Bookmarks",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 5.0,
    );
  }

  Widget _body() {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: _con.removeLoading
          ? Container(
              height: size.height,
              width: size.width,
              child: Center(
                child: processing,
              ),
            )
          : _con.isAllDataLoading
              ? shimmer(size)
              : SingleChildScrollView(
                  controller: _con.pageScroller,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          itemNameDisplay(
                            "Bookmark List",
                          ),
                          // Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: GestureDetector(
                                onTap: () async {
                                  var res = await Navigator.of(context)
                                      .pushNamed(RouteKeys.CREATE_BOOKMARK);
                                  if (res != null) {
                                    getData();
                                  }
                                },
                                child: SvgPicture.asset(
                                  ImagePath.PLAYLIST,
                                  height: 18.0,
                                  width: 18.0,
                                )),
                          ),
                        ],
                      ),
                      data(),
                      itemNameDisplay(
                        "Uncategorized Bookmarks",
                      ),
                      uncat(size)
                    ],
                  ),
                ),
    );
  }

  Widget itemNameDisplay(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget data() {
    return _con.bookmarkData.isEmpty
        ? commonMsgFunc("No Bookmarks Found")
        : Column(
            children: _con.bookmarkData
                .asMap()
                .map((index, key) => MapEntry(
                      index,
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(7),
                              onTap: () async {
                                var res = await Navigator.of(context).pushNamed(
                                    RouteKeys.BOOKMARKDETAILS,
                                    arguments: RouteArgument(param: [
                                      _con.bookmarkData[index].bookmarkId,
                                      _con.bookmarkData[index].bookmarkName
                                    ]));
                                if (res != null && res) {
                                  getData();
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(10.0),
                                    width: 100.0,
                                    child: Hero(
                                      tag: _con.bookmarkData[index].bookmarkId,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        child: ImageWidget(
                                          imageUrl: _con
                                              .bookmarkData[index].bookmarkImg,
                                          height: 100.0,
                                          width: 100.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  wBox(5.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _con.bookmarkData[index].bookmarkName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        hBox(5.0),
                                        Text(
                                          "${_con.bookmarkData[index].numberOfReco.length} bookmarks",
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      var res =
                                          await Navigator.of(context).pushNamed(
                                        RouteKeys.CREATE_BOOKMARK,
                                        arguments: RouteArgument(
                                          param: [
                                            _con.bookmarkData[index].bookmarkId,
                                            _con.bookmarkData[index]
                                                .bookmarkImg,
                                            _con.bookmarkData[index]
                                                .bookmarkName,
                                          ],
                                        ),
                                      );
                                      if (res != null && res) {
                                        getData();
                                      }
                                    },
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.PRIMARY_COLOR,
                                      size: 24.0,
                                    ),
                                  ),
                                  wBox(10.0)
                                ],
                              ),
                            ),
                            d()
                          ],
                        ),
                      ),
                    ))
                .values
                .toList(),
          );
  }

  Widget uncat(size) {
    return _con.allBookMarks == null
        ? commonMsgFunc("No Bookmarks Found")
        : _con.allBookMarks.isEmpty
            ? commonMsgFunc("No Bookmarks Found")
            : Column(
                children: [
                  Column(
                    children: _con.allBookMarks
                        .asMap()
                        .map((index, key) {
                          BookMarkDetails data = _con.allBookMarks[index];
                          return MapEntry(
                              index,
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                child: Column(
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(7),
                                      onTap: () => transferToPage(
                                          type: data.type, id: data.typeId),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(10.0),
                                            width: 100.0,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              child: ImageWidget(
                                                imageUrl: data.type == "Podcast"
                                                    ? data.bookmarkImage
                                                    : data.type == "Book"
                                                        ? data.bookmarkImage
                                                        : "${Global.tmdbImgBaseUrl}${data.bookmarkImage}",
                                                height: 100.0,
                                                width: 100.0,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("${data.bookmarkName}",
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 16.0)),
                                                hBox(5.0),
                                                commonText(data.type),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            onTap: () {
                                              setState(
                                                () => _con.removeLoading = true,
                                              );
                                              _con.removeBookMark(
                                                bookmarkId: data.id,
                                                index: index,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: svgIcon(
                                                hw: 20.0,
                                                str: ImagePath.BOOKMARK1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    data.recdBy.length > 0
                                        ? _thirdSection(
                                            data.recdBy, data.totalUsers)
                                        : Container(),
                                    d(),
                                  ],
                                ),
                              ));
                        })
                        .values
                        .toList(),
                  ),
                  _con.isPageLoading ? buildProgressIndicator() : Container()
                ],
              );
  }

  transferToPage({String type, String id}) {
    Navigator.of(context).pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [type, id]));
  }

  Text commonText(String title) => Text(
        title,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          color: Colors.grey,
        ),
      );

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
