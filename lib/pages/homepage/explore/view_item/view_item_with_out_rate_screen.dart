import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/explore/view_item/view_item_with_out_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/books/books.dart';
import 'package:recd/model/group/group.dart';
import 'package:recd/model/movie/view_movie.dart';
import 'package:recd/model/podcast/podcast_model.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/model/tv_show/tv_show_model.dart';
import 'package:recd/model/view_item.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class ViewItemWithOutRateScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  ViewItemWithOutRateScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _ViewItemWithOutRateScreenState createState() =>
      _ViewItemWithOutRateScreenState();
}

class _ViewItemWithOutRateScreenState
    extends StateMVC<ViewItemWithOutRateScreen> with TickerProviderStateMixin {
  ViewItemWithOutController _con;
  _ViewItemWithOutRateScreenState() : super(ViewItemWithOutController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();

    //* type and id = params[0] and parmas[1]
    _con.controller = TabController(length: 2, vsync: this);
    setState(() => _con.isViewItemLoading = true);
    _con
        .fetchItems(
            type: widget.routeArgument.param[0],
            id: widget.routeArgument.param[1])
        .then((value) {
      if (widget.routeArgument.param[0] != "Book") {
        _con
            .fetchRelated(
                type: widget.routeArgument.param[0],
                id: widget.routeArgument.param[1])
            .then((releted) {
          _con
              .getStatusFunction(
                  type: widget.routeArgument.param[0],
                  id: widget.routeArgument.param[1])
              .then((val) {
            setState(() {
              _con.viewItems = value;
              _con.isViewItemLoading = false;
              _con.relatedItems = releted;
            });
          });
        });
      } else {
        log(value.image.toString());
        setState(() {
          _con.viewItems = value;
          _con.isViewItemLoading = false;
        });
      }
    });
    setState(() => _con.isRecdByLoading = true);
    _con
        .getRelatedRecd(
            type: widget.routeArgument.param[0],
            id: widget.routeArgument.param[1])
        .then((details) {
      setState(() {
        _con.relatedRec = details;
        _con.isRecdByLoading = false;
      });
    });
    _con.tabListner(
      widget.routeArgument.param[0],
      widget.routeArgument.param[1],
    );

    if (widget.routeArgument.param[0] == "Movie") {
      _con.getWatchProvider(type: "movie", id: widget.routeArgument.param[1]);
    } else if (widget.routeArgument.param[0] == "Tv Show") {
      _con.getWatchProvider(type: "tv", id: widget.routeArgument.param[1]);
    }
  }

  @override
  void dispose() {
    _con.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

  Widget _body() {
    Size size = MediaQuery.of(context).size;
    String type = widget.routeArgument.param[0];
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: _con.isViewItemLoading
            ? processing
            : Column(
                children: [
                  Stack(
                    children: [
                      mainImage(),
                      backButton(),
                      moreButton(),
                      iconRectangle(size),
                      tabBarContainer()
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _con.controller,
                      children: [
                        infoTab(type),
                        ratingTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget tabBarContainer() {
    Radius radius = Radius.circular(15.0);
    return Positioned(
      bottom: 0.0,
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
            color: Colors.white),
        child: TabBar(
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
          labelColor: AppColors.PRIMARY_COLOR,
          indicatorWeight: 1.0,
          indicatorColor: AppColors.PRIMARY_COLOR,
          controller: _con.controller,
          tabs: [
            Tab(text: "Info"),
            Tab(text: "Ratings"),
          ],
        ),
      ),
    );
  }

  Widget iconRectangle(Size size) {
    return Positioned(
      bottom: 60.0,
      child: Container(
        height: 60.0,
        width: size.width,
        child: Center(
          child: Container(
            width: size.width / 1.50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [BoxShadow(blurRadius: 0.5, spreadRadius: 0.05)],
                color: Colors.white),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  bookMarkIcon(),
                  rateIcon(),
                  sendRecoIcon(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sendRecoIcon() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        RouteKeys.CONTACT,
        arguments: RouteArgument(
          param: [widget.routeArgument.param[0], getDataObject(_con.viewItems)],
        ),
      ),
      child: svgIcon(
        hw: 25.0,
        str: ImagePath.RECO,
      ),
    );
  }

  Widget rateIcon() {
    double hw = 25.0;
    return Material(
      child: Ink(
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: InkWell(
          onTap: () async {
            Object result =
                await Navigator.of(context).pushNamed(RouteKeys.RATEITEM,
                    arguments: RouteArgument(param: [
                      widget.routeArgument.param[0],
                      widget.routeArgument.param[1],
                      '${_con.viewItems.image}'
                    ]));
            _con.ratingStatusUpdate(
                result: result,
                type: widget.routeArgument.param[0],
                id: widget.routeArgument.param[1]);
          },
          child: _con.isRated == "" || _con.isRated.isEmpty
              ? svgIcon(hw: hw, str: ImagePath.VERIFIED)
              : CircleAvatar(
                  radius: 17.0,
                  backgroundColor: AppColors.PRIMARY_COLOR,
                  child: Text(
                    _con.isRated,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget bookMarkIcon() {
    return GestureDetector(
      onTap: () async {
        Object result = await Navigator.of(context).pushNamed(
          RouteKeys.BOOKMARK_LIST,
          arguments: RouteArgument(
            param: [
              widget.routeArgument.param[0],
              _con.viewItems.id,
            ],
          ),
        );
        _con.bookmarkStatusUpdate(result);
      },
      child: _con.isBookMarked
          ? svgIcon(hw: 25.0, str: ImagePath.BOOKMARK1)
          : svgIcon(hw: 25.0, str: ImagePath.BOOK),
    );
  }

  Widget mainImage() {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => _showOverlay(context),
      child: Hero(
        tag: _con.viewItems.image,
        child: CachedNetworkImage(
          imageUrl: _con.viewItems.image,
          height: size.height / 2,
          width: size.width,
          fit: BoxFit.cover,
          placeholder: (context, url) => mainImageShimmer(size),
          errorWidget: (context, url, error) => Image.asset(
            ImagePath.RECDLOGO,
            filterQuality: FilterQuality.low,
          ),
        ),
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(TutorialOverlay(_con.viewItems.image));
  }

  Widget moreButton() {
    return Positioned(
      top: 10.0,
      right: 10.0,
      child: IconButton(
        icon: Icon(
          Icons.share,
          color: Colors.white,
        ),
        onPressed: () => shareItem(
          type: widget.routeArgument.param[0],
          id: widget.routeArgument.param[1],
          itemName: _con.viewItems.name,
        ),
      ),
    );
  }

  Widget backButton() {
    return Positioned(
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
    );
  }

  Widget ratingTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            hBox(5.0),
            _con.isRatingLoading
                ? processing
                : _con.ratingDetails == null || _con.ratingDetails.isEmpty
                    ? commonMsgFunc("Be the first to rate this title")
                    : ratingList(),
          ],
        ),
      ),
    );
  }

  Widget infoTab(String type) {
    // try {
    String text1 = "";
    String text2 = "";
    String text3 = "";

    if (type == "Movie") {
      //! Movie
      final formatCurrency = new NumberFormat.simpleCurrency();

      if (_con.viewItems?.str1 == 'null' ||
          _con.viewItems?.str2 == 'null' ||
          _con.viewItems?.str3 == 'null') {
        text1 = "N/A";
        text2 = "N/A";
        text3 = "N/A";
      } else {
        int runtime = int.parse(_con.viewItems.str1);
        final int hour = runtime ~/ 60;
        final int minutes = runtime % 60;
        text1 = "${hour.toString()}h ${minutes.toString()}m";
        text2 = _con.viewItems.str2 != ""
            ? DateTime.parse(_con.viewItems.str2).year.toString()
            : "N/A";
        text3 = "${formatCurrency.format(int.parse(_con.viewItems.str3))}";
      }
    } else if (type == "Tv Show") {
      //! Tv Shows
      text1 = _con.viewItems.str1;
      text2 = _con.viewItems.str2 != ""
          ? DateTime.parse(_con.viewItems.str2).year.toString()
          : "N/A";
      text3 = "${_con.viewItems.str3}";
    } else if (type == "Book") {
      //! Books
      text1 = _con.viewItems.str1;
      try {
        text2 = _con.viewItems.str2 != ""
            ? DateTime.parse(_con.viewItems.str2).year.toString()
            : "N/A";
      } catch (e) {
        text2 = "N/A";
      }
      text3 = "${_con.viewItems.str3}";
    } else if (type == "Podcast") {
      //! Podcast
      text1 = _con.viewItems.str1;
      text2 = _con.viewItems.str2;
      text3 = "${_con.viewItems.str3}";
    } else {
      text1 = text2 = text3 = "";
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          hBox(15),
          _theMovieName(),
          if (text1.isNotEmpty)
            itemInfo(title: _con.str1Title1, text: "$text1", type: type),
          if (text2.isNotEmpty)
            itemInfo(title: _con.str2Title2, text: "$text2", type: type),
          if (text3.isNotEmpty)
            itemInfo(title: _con.str3Title3, text: "$text3", type: type),
          _con.relatedRec.isEmpty || _con.relatedRec == null
              ? Container()
              : _by(),
          _bottomMainContainer(type),
        ],
      ),
    );
    // } catch (e) {
    //   print(e);
    //   return Text('$e');
    // }
  }

  // Widget ratingList() {
  //   return Expanded(
  //     child: ListView.builder(
  //       itemExtent: 9999,
  //       itemCount: _con.ratingDetails.length,
  //       itemBuilder: (context, index) => Expanded(
  //         child: ratingBox(
  //           title: _con.ratingDetails[index].name,
  //           circleImage: _con.ratingDetails[index].profileImage,
  //           rating: _con.ratingDetails[index].totalRating,
  //           updateDate: _con.ratingDetails[index].updatedDate,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget itemInfo({String title, String text, String type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title: ",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Text(
                  "$text",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ratingList() {
    return Column(
      children: _con.ratingDetails
          .asMap()
          .map(
            (index, element) => MapEntry(
              index,
              ratingBox(
                  title: _con.ratingDetails[index].name,
                  circleImage: _con.ratingDetails[index].profileImage,
                  rating: _con.ratingDetails[index].totalRating,
                  updateDate: _con.ratingDetails[index].updatedDate,
                  userId: _con.ratingDetails[index].userId),
            ),
          )
          .values
          .toList(),
    );
  }

  Widget ratingBox({
    String title,
    String circleImage,
    String rating,
    String updateDate,
    String userId,
  }) {
    DateTime dateTime = DateTime.parse(updateDate.toString());
    var data = DateFormat('dd.MM.yyyy').format(dateTime);
    var convertedDate = data.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    RouteKeys.VIEW_PROFILE,
                    arguments: RouteArgument(param: userId)),
                child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(circleImage)),
              ),
              title: Text(
                "$title",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "$convertedDate",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              trailing: Container(
                width: 70.0,
                alignment: Alignment.center,
                child: Center(
                  child: Stack(
                    children: [
                      Icon(Icons.star,
                          color: AppColors.PRIMARY_COLOR, size: 55.0),
                      Positioned(
                        top: 0,
                        left: 0.0,
                        bottom: 0,
                        right: 0,
                        child: Container(
                          child: Center(
                              child: Text("$rating",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12.0))),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 15.0),
              child: Text(
                "Rate it $rating / 5",
                style: TextStyle(fontSize: 14.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _theMovieName() {
    Size size = MediaQuery.of(context).size;
    String title = "";
    String type = widget.routeArgument.param[0];
    if (type == "Movie" || type == "Tv Show") {
      for (var i = 0; i < _con.viewItems.category.length; i++) {
        if (i == _con.viewItems.category.length - 1) {
          title = title + _con.viewItems.category[i]['name'];
        } else {
          title = title + _con.viewItems.category[i]['name'] + ', ';
        }
      }
    } else if (type == "Podcast") {
      for (int i = 0; i < _con.viewItems.category.length; i++) {
        for (int j = 0; j < Global.podCastCategory.length; j++) {
          if (Global.podCastCategory[j].categoryId ==
              _con.viewItems.category[i]) {
            if (i == _con.viewItems.category.length - 1) {
              title = title + Global.podCastCategory[j].categoryName;
            } else {
              title = title + Global.podCastCategory[j].categoryName + ", ";
            }
          }
        }
      }
    } else if (type == "Book") {
      for (var i = 0; i < _con.viewItems.bookAutherName.length; i++) {
        title = title + _con.viewItems.bookAutherName[i];
      }
    }
    return Container(
      width: size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _con.viewItems.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w600),
              softWrap: true,
            ),
            hBox(10.0),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
              softWrap: true,
            ),
          ],
        ),
      ),
    );

    // return Padding(
    //   padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       Flexible(
    //         child: Container(
    //           child: Text(
    //             _con.viewItems.name,
    //             maxLines: 4,
    //             overflow: TextOverflow.ellipsis,
    //             style: TextStyle(
    //               fontSize: 19.0,
    //               fontWeight: FontWeight.w600,
    //             ),
    //             softWrap: true,
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         child: Text(
    //           title,
    //           maxLines: 2,
    //           overflow: TextOverflow.ellipsis,
    //           textAlign: TextAlign.end,
    //           style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    //           softWrap: true,
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }

  Widget whereToSection() {
    String where = "";
    String type = widget.routeArgument.param[0];
    if (type == "Movie" || type == "Tv Show") {
      where = "Watch";
    } else if (type == "Podcast") {
      where = "Listen";
    }

    return Padding(
      padding: _con.padding,
      child: Text(
        "Where To $where",
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget releteditems() {
    return (_con.relatedItems.isEmpty)
        ? commonMsgFunc("No Related Deep Dives")
        : SizedBox(
            height: 145.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _con.relatedItems.length,
              padding: _con.padding,
              itemBuilder: (_, index) {
                String subTitle = "";
                ViewItem obj = _con.relatedItems[index];

                if (_con.relatedItems[index].category != null) {
                  for (int i = 0;
                      i < _con.relatedItems[index].category.length;
                      i++) {
                    if (Global.movieCategory != null)
                      for (int j = 0; j < Global.movieCategory.length; j++) {
                        if (Global.movieCategory[j].categoryId ==
                            _con.relatedItems[index].category[i]) {
                          if (i ==
                              _con.relatedItems[index].category.length - 1) {
                            subTitle =
                                subTitle + Global.movieCategory[j].categoryName;
                          } else {
                            subTitle = subTitle +
                                Global.movieCategory[j].categoryName +
                                ", ";
                          }
                        }
                      }
                  }
                }
                return Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          String type = widget.routeArgument.param[0];
                          transferToPage(
                              index: index,
                              type: type,
                              itemId: _con.relatedItems[index].id);
                        },
                        child: relatedImages(
                            img: "${obj.image}",
                            title: "${obj.name}",
                            subTitle: subTitle)),
                    wBox(6.0),
                  ],
                );
              },
            ),
          );
  }

  getDataObject(ViewItem viewItems) {
    String type = widget.routeArgument.param[0];

    if (type == "Movie") {
      return ViewMovie(
          movieId: int.parse(viewItems.id),
          movieImage: viewItems.image,
          movieName: viewItems.name);
    } else if (type == "Tv Show") {
      return ViewTvShow(
          tvShowId: int.parse(viewItems.id),
          tvShowImage: viewItems.image,
          tvShowName: viewItems.name);
    } else if (type == "Book") {
      return BookModel(
          id: viewItems.id, image: viewItems.image, title: viewItems.name);
    } else if (type == "Podcast") {
      return ViewPodCast(
          podCastId: viewItems.id,
          podCastImage: viewItems.image,
          podCastName: viewItems.name);
    }
  }

  transferToPage({String type, int index, String itemId}) {
    Navigator.of(context).pushReplacementNamed(
        RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [type, itemId]));
  }

  // Widget relatedImages(String image, String name) {
  //   return Card(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(10.0),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(10.0),
  //       child: ImageWidget(
  //         imageUrl: image,
  //         placeholder: (context, url) => Container(child: relatedItemShimmer()),
  //         height: 140.0,
  //         width: 240.0,
  //         fit: BoxFit.cover,
  //         errorWidget: (context, url, error) => Icon(Icons.error),
  //       ),
  //     ),
  //   );
  // }

  Widget relatedImages({String img, String title, String subTitle}) {
    return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(7.0),
            child: Stack(children: [
              ImageWidget(
                imageUrl: img,
                width: 200,
              ),
              Positioned(
                  bottom: 20.0,
                  left: 0.0,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          padding: EdgeInsets.all(3),
                          width: 180,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Center(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Text(" $title",
                                      style: TextStyle(fontSize: 10.0),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: true)))))),
              Positioned(
                  bottom: 6.0,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text('$subTitle',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.0,
                            )),
                      )))
            ])));
  }

  Widget relatedDeepDives() {
    return Padding(
      padding: _con.padding,
      child: Text(
        "Related Deep Dives",
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Padding aboutSection(EdgeInsetsGeometry padding, String str) {
    return Padding(
        padding: padding,
        child: Text("About the $str",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)));
  }

  Widget whereToWatchImage({EdgeInsetsGeometry padding, List<String> image}) {
    Size size = MediaQuery.of(context).size;
    return image == null
        ? Container()
        : image.isEmpty
            ? Container()
            : Container(
                width: size.width,
                child: Padding(
                    padding: padding,
                    child: Wrap(
                      children: image
                          .asMap()
                          .map((index, key) {
                            return MapEntry(
                              index,
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  hBox(8.0),
                                  Container(
                                    margin: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 0.5,
                                          spreadRadius: 0.2,
                                        )
                                      ],
                                    ),
                                    child: ImageWidget(
                                      imageUrl: image[index],
                                      height: 35.0,
                                      width: 35.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                          .values
                          .toList(),
                    )),
              );
  }

  Container _bottomMainContainer(String type) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black38)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hBox(10.0),
          type == "Book" || type == "Podcast"
              ? Container()
              : _con.isWhereToWatchAvailable
                  ? whereToSection()
                  : Container(),
          type == "Book" || type == "Podcast"
              ? Container()
              : _con.isWhereToWatchAvailable
                  ? whereToWatchImage(
                      padding: _con.padding, image: _con.whereToWatch)
                  : Container(),
          aboutSection(_con.padding, widget.routeArgument.param[0]),
          Padding(
              padding: _con.padding,
              child: Html(data: _con.viewItems.overview)),
          type == "Book" ? Container() : relatedDeepDives(),
          type == "Book"
              ? Container()
              : _con.relatedItems.isEmpty
                  ? commonMsgFunc("No Related Item Found")
                  : releteditems(),
        ],
      ),
    );
  }

  Widget _by() {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        RouteKeys.RECD_BY_FRIEND_LIST,
        arguments: RouteArgument(
          param: [
            widget.routeArgument.param[1],
            widget.routeArgument.param[0],
          ],
        ),
      ),
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 10.0,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                images(
                  _con.relatedRec,
                ),
                Text("REC'd by",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true),
                wBox(5.0),
                _con.isRecdByLoading
                    ? recdByShimmerEffect(size)
                    : recdByText(
                        "${_con.relatedRec[0].title} ",
                        _con.totalRecd,
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget images(List<RelatedRecsModel> list) {
    double w = getUserImageListWidth(list);

    return Container(
      width: w,
      child: new Stack(
        children: <Widget>[
          list.length >= 1
              ? CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16.0,
                  child: new CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          list[0].image == null
                              ? Global.staticRecdImageUrl
                              : list[0].image),
                      radius: 15.0))
              : Container(),
          list.length >= 2
              ? new Positioned(
                  left: 20.0,
                  child: new CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16.0,
                    child: new CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        list[1].image == null
                            ? Global.staticRecdImageUrl
                            : list[1].image,
                      ),
                      radius: 15.0,
                    ),
                  ),
                )
              : Container(),
          list.length >= 3
              ? new Positioned(
                  left: 40.0,
                  child: new CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16.0,
                    child: new CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        list[2].image == null
                            ? Global.staticRecdImageUrl
                            : list[2].image,
                      ),
                      radius: 15.0,
                    ),
                  ),
                )
              : hBox(0.0)
        ],
      ),
    );
  }

  Widget recdByText(String name, int total) {
    String title = "";
    title = title + name;
    if (total == 1) {
      title = "$name";
    } else if (total == 2) {
      title = "$name and ${total - 1} other";
    } else if (total >= 3) {
      title = "$name and ${total - 1} others";
    }
    return Flexible(
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.0, color: Colors.grey),
        softWrap: true,
      ),
    );
  }
}

class TutorialOverlay extends ModalRoute<void> {
  TutorialOverlay(this.image);
  String image;
  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: image,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      7.0,
                    ),
                  ),
                  child: CachedNetworkImage(
                      imageUrl: '$image',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(
                            ImagePath.RECDLOGO,
                            filterQuality: FilterQuality.low,
                          ),
                      fadeInDuration: Duration(microseconds: 10),
                      fadeInCurve: Curves.easeIn,
                      placeholder: (context, url) => popularMovieShimmer()),
                ),
              ),
            ),
            // hBox(15.0),
            // CircleAvatar(
            //   backgroundColor: Colors.white,
            //   child: IconButton(
            //     icon: Icon(
            //       Icons.close,
            //       color: Colors.black,
            //     ),
            //     onPressed: () => Navigator.of(context).pop(),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
