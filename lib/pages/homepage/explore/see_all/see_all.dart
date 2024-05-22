import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/explore/see_all/see_all_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class SeeAllScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  SeeAllScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _SeeAllScreenState createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends StateMVC<SeeAllScreen> {
  SeeAllController _con;
  _SeeAllScreenState() : super(SeeAllController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    isInternet().then((value) {
      setState(() => _con.isInternet = true);
      if (value) {
        _con.fetchMovie(widget.routeArgument.param).then((fetchMovie) {
          setState(() {
            _con.movieList = fetchMovie;
            _con.isDataLoaded = false;
            _con.isRecdByLoading = true;

            _con
                .getRelatedRecs(
                    info: _con.movieList, type: widget.routeArgument.param[1])
                .then((val) {
              _con.recdBy = val;
              _con.isRecdByLazyLoading = false;
            });
          });
        });
      } else {
        setState(() => _con.isInternet = false);
      }
    });
    _con.lazyLoadingListner(widget.routeArgument.param);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: appBar(),
        body: Container(
            child: _con.movieList == null
                ? commonMsgFunc("No data found")
                : _con.isDataLoaded
                    ? Center(child: shimmer(size))
                    : ListView.builder(
                        controller: _con.movieScrollController,
                        cacheExtent: 99,
                        itemCount: _con.isPageLoading
                            ? _con.movieList.length + 1
                            : _con.movieList.length,
                        itemBuilder: (context, index) {
                          if (index == _con.movieList.length) {
                            return buildProgressIndicator();
                          } else {
                            String title = "";
                            if (widget.routeArgument.param[1] == "movie") {
                              for (int i = 0;
                                  i < _con.movieList[index].category.length;
                                  i++) {
                                for (int j = 0;
                                    j < Global.movieCategory.length;
                                    j++) {
                                  if (Global.movieCategory[j].categoryId ==
                                      _con.movieList[index].category[i]) {
                                    if (i ==
                                        _con.movieList[index].category.length -
                                            1) {
                                      title = title +
                                          Global.movieCategory[j].categoryName;
                                    } else {
                                      title = title +
                                          Global.movieCategory[j].categoryName +
                                          ", ";
                                    }
                                  }
                                }
                              }
                            } else if (widget.routeArgument.param[1] == "tv") {
                              for (int i = 0;
                                  i < _con.movieList[index].category.length;
                                  i++) {
                                for (int j = 0;
                                    j < Global.tvShowCategory.length;
                                    j++) {
                                  if (Global.tvShowCategory[j].categoryId ==
                                      _con.movieList[index].category[i]) {
                                    if (i ==
                                        _con.movieList[index].category.length -
                                            1) {
                                      title = title +
                                          Global.tvShowCategory[j].categoryName;
                                    } else {
                                      title = title +
                                          Global
                                              .tvShowCategory[j].categoryName +
                                          ", ";
                                    }
                                  }
                                }
                              }
                            }
                            return cardDetails(index: index, title: title);
                          }
                        })));
  }

  Widget cardDetails({int index, String title}) {
    String recdBy = "";
    if (_con.isRecdByLazyLoading == false) {
      _con.movieList[index].isRecdLoading = false;

      _con.recdBy[index].recdUser.isEmpty
          ? recdBy = ""
          : _con.movieList[index].id == _con.recdBy[index].recId
              ? _con.recdBy[index].totalRecs == 1
                  ? recdBy =
                      "REC'd By ${_con.recdBy[index].recdUser[0]['created_by']['name']}"
                  : _con.recdBy[index].totalRecs >= 2
                      ? recdBy =
                          "REC'd By ${_con.recdBy[index].recdUser[0]['created_by']['name']} and ${_con.recdBy[index].totalRecs - 1} others"
                      : recdBy =
                          "REC'd By ${_con.recdBy[index].recdUser[0]['created_by']['name']}"
              : recdBy = "ß";
      _con.movieList[index].recdByInfo = recdBy;
    } else {
      if (_con.isRecdByLoading == false && _con.isRecdByLazyLoading == true) {
        _con.movieList[index].isRecdLoading = false;
        _con.movieList[index].recdByInfo = "";
      }
    }
    return GestureDetector(
        onTap: () {
          transferToPage(
              type: widget.routeArgument.param[1],
              id: _con.movieList[index].id.toString());
        },
        child: Card(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0)),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  wBox(10.0),
                  indexListing(index),
                  mainImage(index),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        hBox(10.0),
                        itemTitle(index),
                        hBox(5.0),
                        secText(title),
                        hBox(5.0),
                        _con.movieList[index].isRecdLoading
                            ? recdShimmer()
                            : Text("${_con.movieList[index].recdByInfo}",
                                style:
                                    TextStyle(color: AppColors.PRIMARY_COLOR))
                      ]))
                ])));
  }

  transferToPage({String type, String id}) {
    String t = "";
    if (type == "movie") {
      t = "Movie";
    } else if (type == "tv") {
      t = "Tv Show";
    }
    Navigator.of(context).pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [t, id]));
  }

  Widget placeHolderContainer() {
    return Container(
        height: 100.0,
        width: 100.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.0), color: Colors.grey[300]));
  }

  Widget mainImage(int index) {
    return Container(
        margin: EdgeInsets.all(10.0),
        width: 100.0,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(7.0),
            child: ImageWidget(
              imageUrl: '${Global.tmdbImgBaseUrl}'
                  '${_con.movieList[index].image}',
              height: 100.0,
              width: 100.0,
            )));
  }

  Text secText(String title) => Text(title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(color: Colors.grey));

  Widget itemTitle(int index) => Wrap(children: [
        Text(_con.movieList[index].title,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500))
      ]);

  AppBar appBar() => AppBar(
      leading: leadingIcon(context: context),
      title: Text(widget.routeArgument.param[0],
          style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w500)));
}
