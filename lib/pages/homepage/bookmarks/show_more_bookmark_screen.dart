import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/bookmarks/show_more_bookmark_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class ShowMoreBookMarkScreen extends StatefulWidget {
  ShowMoreBookMarkScreen({Key key}) : super(key: key);

  @override
  _ShowMoreBookMarkScreenState createState() => _ShowMoreBookMarkScreenState();
}

class _ShowMoreBookMarkScreenState extends StateMVC<ShowMoreBookMarkScreen> {
  ShowMoreBookmarkController _con;
  _ShowMoreBookMarkScreenState() : super(ShowMoreBookmarkController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();

    isInternet().then((value) {
      if (value) {
        _con.getBookmarks().then((bookmarkinfo) {
          setState(() {
            _con.isLoading = false;
            _con.bookMarkData = bookmarkinfo;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: _appBar(),
        body: _con.isLoading
            ? Center(child: shimmer(size))
            : _con.bookMarkData.isEmpty
                ? Center(
                    child: Text("Please Add Bookmark or Create Bookmark List"))
                : Container(
                    height: size.height,
                    child: ListView.builder(
                        cacheExtent: 99,
                        shrinkWrap: true,
                        itemCount: _con.bookMarkData.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) => InkWell(
                            onTap: () => Navigator.of(context).pushNamed(
                                  RouteKeys.BOOKMARKDETAILS,
                                  arguments: RouteArgument(
                                    param: _con.bookMarkData[index].bookmarkId,
                                  ),
                                ),
                            child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Column(children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(10.0),
                                        width: 100.0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            7.0,
                                          ),
                                          child: ImageWidget(
                                            imageUrl: _con.bookMarkData[index]
                                                .bookmarkImg,
                                            height: 100.0,
                                            width: 100.0,
                                          ),
                                        ),
                                      ),
                                      wBox(10.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _con.bookMarkData[index]
                                                  .bookmarkName,
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            hBox(5.0),
                                            Text(
                                              "${_con.bookMarkData[index].numberOfReco.length} bookmarks",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: AppColors.PRIMARY_COLOR,
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pushNamed(
                                          RouteKeys.CREATE_BOOKMARK,
                                          arguments: RouteArgument(param: [
                                            _con.bookMarkData[index].bookmarkId,
                                            _con.bookMarkData[index]
                                                .bookmarkImg,
                                            _con.bookMarkData[index]
                                                .bookmarkName,
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(endIndent: 10.0, indent: 10.0)
                                ]))))));
  }

  AppBar _appBar() {
    return AppBar(
        centerTitle: true,
        leading: leadingIcon(context: context),
        title: Text("Bookmarks List",
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.black)));
  }
}
