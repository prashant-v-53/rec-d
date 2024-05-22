import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/explore/category_list/category_info_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class CategoryInfoScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  CategoryInfoScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _CategoryInfoScreenState createState() => _CategoryInfoScreenState();
}

class _CategoryInfoScreenState extends StateMVC<CategoryInfoScreen> {
  CategoryInfoController _con;
  _CategoryInfoScreenState() : super(CategoryInfoController()) {
    _con = controller;
  }

  //* type[0] -> id[1]  -> category name[2]
  @override
  void initState() {
    super.initState();

    setState(() {
      _con.isDataLoading = true;
      _con.appBarTitle = widget.routeArgument.param[0];
    });

    _con
        .fetchCategoryData(
      type: widget.routeArgument.param[0],
      catId: widget.routeArgument.param[1],
      page: _con.page,
    )
        .then((val) {
      if (mounted)
        setState(() {
          _con.info = val;
          _con.isDataLoading = false;
        });
    });

    _con.pageScroll.addListener(() {
      if (_con.pageScroll.position.pixels ==
          _con.pageScroll.position.maxScrollExtent) {
        _con.page++;
        _con
            .fetchCategoryData(
          type: widget.routeArgument.param[0],
          catId: widget.routeArgument.param[1],
          page: _con.page,
        )
            .then((value) {
          if (value != null) if (mounted)
            setState(() => _con.info.addAll(value));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _con.scafffoldKey, appBar: appBar(), body: _body());
  }

  AppBar appBar() {
    return AppBar(
      leading: leadingIcon(context: context),
      title: Text(
        "${widget.routeArgument.param[2]}",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _body() {
    Size size = MediaQuery.of(context).size;
    return _con.isDataLoading
        ? shimmer(size)
        : _con.info == null
            ? commonMsgFunc("No item found")
            : _con.info.isEmpty
                ? commonMsgFunc("No item found")
                : ListView.builder(
                    cacheExtent: 99,
                    controller: _con.pageScroll,
                    itemCount: _con.info.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _con.info.length) {
                        return buildProgressIndicator();
                      } else {
                        String year;
                        if (_con.info[index].releaseDate != "") {
                          year = DateTime.parse(_con.info[index].releaseDate)
                              .year
                              .toString();
                        } else {
                          year = "N/A";
                        }

                        String title = "";
                        if (widget.routeArgument.param[0] == "tv") {
                          for (int i = 0;
                              i < _con.info[index].category.length;
                              i++) {
                            for (int j = 0;
                                j < Global.tvShowCategory.length;
                                j++) {
                              if (Global.tvShowCategory[j].categoryId ==
                                  _con.info[index].category[i]) {
                                if (i == _con.info[index].category.length - 1) {
                                  title = title +
                                      Global.tvShowCategory[j].categoryName;
                                } else {
                                  title = title +
                                      Global.tvShowCategory[j].categoryName +
                                      ", ";
                                }
                              }
                            }
                          }
                        } else {
                          for (int i = 0;
                              i < _con.info[index].category.length;
                              i++) {
                            for (int j = 0;
                                j < Global.movieCategory.length;
                                j++) {
                              if (Global.movieCategory[j].categoryId ==
                                  _con.info[index].category[i]) {
                                if (i == _con.info[index].category.length - 1) {
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
                        }
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(
                            RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                            arguments: RouteArgument(
                              param: [
                                widget.routeArgument.param[0] == "tv"
                                    ? "Tv Show"
                                    : "Movie",
                                _con.info[index].id.toString()
                              ],
                            ),
                          ),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
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
                                imageBox('${Global.tmdbImgBaseUrl}'
                                    '${_con.info[index].image}'),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      hBox(7.0),
                                      Text(_con.info[index].title,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w500)),
                                      hBox(5.0),
                                      Wrap(children: [
                                        Text(title.isEmpty ? "N/A" : title,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13.0))
                                      ]),
                                      hBox(5.0),
                                      Text(
                                        year,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
  }

  Widget imageBox(String imagePath) {
    return Container(
        margin: EdgeInsets.all(10.0),
        width: 100.0,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(7.0),
            child: ImageWidget(
              imageUrl: imagePath,
              height: 100.0,
              width: 100.0,
            )));
  }

  transferToPage({String type, String id}) {
    Navigator.of(context).pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [type, id]));
  }

  Text commonText(String title) => Text(title,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: TextStyle(color: Colors.grey));
}
