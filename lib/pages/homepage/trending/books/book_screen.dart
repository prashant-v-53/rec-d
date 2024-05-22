import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/trending/books/book_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';

class ViewBookScreen extends StatefulWidget {
  final RouteArgument routeArgument;

  ViewBookScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _ViewBookScreenState createState() => _ViewBookScreenState();
}

class _ViewBookScreenState extends StateMVC<ViewBookScreen> {
  BookController _con;
  _ViewBookScreenState() : super(BookController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.iniFunc(value: widget.routeArgument.param, context: context);
    _con.fToast = FToast();
    _con.fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: (_con.bookDetails == null)
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ImageWidget(
                          imageUrl: _con.bookDetails.image == null
                              ? Global.staticRecdImageUrl
                              : '${_con.bookDetails.image}',
                          height: size.height / 2,
                          width: size.width,
                        ),
                        Positioned(
                          top: 10.0,
                          left: 10.0,
                          child: Container(
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 35.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          child: Container(
                            color: Colors.white,
                            height: 25,
                            width: size.width,
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          child: Container(
                            height: 60.0,
                            width: size.width,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: AppColors.PRIMARY_COLOR,
                                ),
                                width: size.width / 1.25,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                          onTap: () => Navigator.of(context)
                                              .pushNamed(
                                                  RouteKeys.BOOKMARK_LIST,
                                                  arguments: RouteArgument(
                                                      param: [
                                                        'Book',
                                                        _con.bookDetails.id
                                                      ])),
                                          child: SvgPicture.asset(
                                            ImagePath.BOOK,
                                            color: Colors.white,
                                            height: 28.0,
                                            width: 28.0,
                                          )),
                                      GestureDetector(
                                        onTap: () => _con.isRated
                                            ? Navigator.of(context).pushNamed(
                                                RouteKeys
                                                    .VIEW_ITEM_WITH_OUT_RATE,
                                                arguments: RouteArgument(
                                                  param: [
                                                    "Book",
                                                    _con.bookDetails.id
                                                        .toString()
                                                  ],
                                                ),
                                              )
                                            : Navigator.of(context).pushNamed(
                                                RouteKeys.RATEITEM,
                                                arguments: RouteArgument(
                                                  param: [
                                                    'Book',
                                                    _con.bookDetails.id,
                                                    '${_con.bookDetails.image}',
                                                  ],
                                                ),
                                              ),
                                        child: SvgPicture.asset(
                                          ImagePath.VERIFIED,
                                          color: Colors.white,
                                          height: 30.0,
                                          width: 30.0,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            Navigator.of(context).pushNamed(
                                          RouteKeys.CONTACT,
                                          arguments: RouteArgument(
                                            param: [
                                              'Book',
                                              _con.bookDetails,
                                            ],
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          ImagePath.RECO,
                                          color: Colors.white,
                                          height: 28.0,
                                          width: 28.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    hBox(25),
                    _theMovieName(),
                    hBox(2.0),
                    _con.relatedRec.isEmpty || _con.relatedRec == null
                        ? Container()
                        : _by(),
                    hBox(25.0),
                    _box(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _by() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Text(
              "REC'd by",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
            ),
            wBox(5.0),
            Text(
              "${_con.relatedRec[0].title} and ${_con.total} others",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey,
              ),
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _theMovieName() {
    // Size size = MediaQuery.of(context).size;
    // String title = "";
    // for (var i = 0; i < _con.bookDetails.podCastCategory.length; i++) {
    //   if (i == _con.bookDetails.podCastCategory.length - 1) {
    //     title = title + _con.bookDetails.podCastCategory[i]['id'];
    //   } else {
    //     title = title + _con.bookDetails.podCastCategory[i]['id'] + ', ';
    //   }
    // }

    // String title = "";
    // for (int i = 0; i < _con.bookDetails.podCastCategory.length; i++) {
    //   for (int j = 0; j < Global.podCastCategory.length; j++) {
    //     if (Global.podCastCategory[j].categoryId ==
    //         _con.bookDetails.podCastCategory[i]) {
    //       if (i == _con.bookDetails.podCastCategory.length - 1) {
    //         title = title + Global.podCastCategory[j].categoryName;
    //       } else {
    //         title = title + Global.podCastCategory[j].categoryName + ",";
    //       }
    //     }
    //   }
    // }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Text(
                _con.bookDetails.title.toString(),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            20.0,
          ),
          topRight: Radius.circular(
            20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hBox(10.0),
          // _wheretoWatchText(),
          // _whereToWatch(),
          _aboutTheMovieText(),
          _aboutMovie(),
          // reletedItemsText("Related Deep Dives"),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _wheretoWatchText() {
    return Padding(
      padding: _con.padding,
      child: Text(
        "Where To Read",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _whereToWatch() {
    return Padding(
      padding: _con.padding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            5.0,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black26,
            )
          ],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            5.0,
          ),
          child: ImageWidget(
            imageUrl: _con.where,
            width: 100.0,
            height: 40.0,
          ),
        ),
      ),
    );
  }

  Widget reletedItemsText(String title) {
    return Padding(
      padding: _con.padding,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _aboutTheMovieText() {
    return Padding(
      padding: _con.padding,
      child: Text(
        "About the book",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _aboutMovie() {
    return _con.bookDetails.desc == null
        ? "sample"
        : Padding(
            padding: _con.padding,
            child: Html(
              data: _con.bookDetails.desc,
              shrinkWrap: true,
            ),
          );
  }
}
