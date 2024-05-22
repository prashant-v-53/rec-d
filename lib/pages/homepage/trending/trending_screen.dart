import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/trending/trending%20_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class TrendingScreen extends StatefulWidget {
  TrendingScreen({Key key}) : super(key: key);
  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends StateMVC<TrendingScreen>
    with TickerProviderStateMixin {
  TrendingController _con;
  _TrendingScreenState() : super(TrendingController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();

    _con.controller = TabController(length: 4, vsync: this);
    isInternet().then((value) {
      if (value) {
        _con.fetchMovie().then((fetchMovie) {
          if (mounted)
            setState(() {
              _con.isInternet = true;
              _con.movieList = fetchMovie;
              _con.isDataLoaded = false;
            });
        });
      } else {
        setState(() => _con.isInternet = false);
      }
    });
    _con.tabListner();
    _con.loadingListener();
  }

  @override
  void dispose() {
    _con.movieSC.dispose();
    _con.tvShowSC.dispose();
    _con.podCastSC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: getAppbar("Trending"),
      body: Consumer<NetworkModel>(
        builder: (context, value, child) {
          if (value.connection) {
            return (_con.isDataLoaded) ? trendingShimmer(size) : _body();
          } else {
            return NetworkErrorPage();
          }
        },
      ),
    );
  }

  Widget _body() {
    return SafeArea(
        child: DefaultTabController(
            length: 4,
            child: Column(children: [
              hBox(10.0),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 6.0),
                  child: Container(
                      height: 40.0,
                      child: TabBar(
                          physics: BouncingScrollPhysics(),
                          indicatorColor: AppColors.PRIMARY_COLOR,
                          indicatorSize: TabBarIndicatorSize.tab,
                          unselectedLabelColor: Colors.grey,
                          labelColor: AppColors.PRIMARY_COLOR,
                          labelStyle: TextStyle(fontWeight: FontWeight.w500),
                          labelPadding: EdgeInsets.symmetric(horizontal: 0.0),
                          controller: _con.controller,
                          tabs: _con.tabbar,
                          indicatorWeight: 1.0,
                          isScrollable: false))),
              Expanded(
                  child: TabBarView(controller: _con.controller, children: [
                moviesTab(),
                tvShowsTab(),
                booksTab(),
                podcastsTab()
              ]))
            ])));
  }

  Widget moviesTab() {
    return (_con.movieList == null || _con.movieList.isEmpty)
        ? commonMsgFunc("No data Fetch")
        : ListView.builder(
            cacheExtent: 99,
            controller: _con.movieSC,
            itemCount: _con.isMoviePaginationStop
                ? _con.movieList.length
                : _con.movieList.length + 1,
            itemBuilder: (context, index) {
              if (index == _con.movieList.length) {
                return buildProgressIndicator();
              } else {
                DateTime year =
                    DateTime.parse(_con.movieList[index].releaseDate);

                String title = "";
                if (Global.movieCategory != null) {
                  for (int i = 0;
                      i < _con.movieList[index].movieCategory.length;
                      i++) {
                    for (int j = 0; j < Global.movieCategory.length; j++) {
                      if (Global.movieCategory[j].categoryId ==
                          _con.movieList[index].movieCategory[i]) {
                        if (i ==
                            _con.movieList[index].movieCategory.length - 1) {
                          title = title + Global.movieCategory[j].categoryName;
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
                        arguments: RouteArgument(param: [
                          "Movie",
                          _con.movieList[index].movieId.toString()
                        ])),
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
                                  '${_con.movieList[index].movieImage}'),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    hBox(7.0),
                                    Text(_con.movieList[index].movieTitle,
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
                                    Text(year.year.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0))
                                  ]))
                            ])));
              }
            },
          );
  }

  // * Bottom box information
  Widget tvShowsTab() {
    Size size = MediaQuery.of(context).size;
    return (_con.isTvShowsLoaded)
        ? shimmer(size)
        : _con.tvShowList == null || _con.tvShowList.isEmpty
            ? commonMsgFunc("No data found")
            : ListView.builder(
                controller: _con.tvShowSC,
                cacheExtent: 99,
                itemCount: _con.isTvPaginationStop
                    ? _con.tvShowList.length
                    : _con.tvShowList.length + 1,
                itemBuilder: (context, index) {
                  if (index == _con.tvShowList.length) {
                    return buildProgressIndicator();
                  } else {
                    String title = "";
                    String year = "";
                    try {
                      year = _con.tvShowList[index].releaseDate != null
                          ? DateTime.parse(_con.tvShowList[index].releaseDate)
                              .year
                              .toString()
                          : '';
                    } catch (e) {
                      year = "N/A";
                    }
                    if (Global.tvShowCategory != null) {
                      for (int i = 0;
                          i < _con.tvShowList[index].category.length;
                          i++) {
                        for (int j = 0; j < Global.tvShowCategory.length; j++) {
                          if (Global.tvShowCategory[j].categoryId ==
                              _con.tvShowList[index].category[i]) {
                            if (_con.tvShowList[index].category.length == 1) {
                              title = Global.tvShowCategory[j].categoryName;
                            } else if (i ==
                                _con.tvShowList[index].category.length - 1) {
                              title =
                                  title + Global.tvShowCategory[j].categoryName;
                            } else {
                              title = title +
                                  Global.tvShowCategory[j].categoryName +
                                  ", ";
                            }
                          }
                        }
                      }
                    }
                    return GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                              arguments: RouteArgument(param: [
                                "Tv Show",
                                _con.tvShowList[index].id.toString(),
                              ])),
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
                            Container(
                              margin: EdgeInsets.all(10.0),
                              width: 100.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  7.0,
                                ),
                                child: ImageWidget(
                                  imageUrl: '${Global.tmdbImgBaseUrl}'
                                      '${_con.tvShowList[index].image}',
                                  height: 100.0,
                                  width: 100.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  hBox(7.0),
                                  Text(
                                    _con.tvShowList[index].name,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  hBox(5.0),
                                  Text(title.isEmpty ? "N/A" : title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.grey,
                                      )),
                                  hBox(5.0),
                                  Text(
                                    year,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
  }

  Widget placeHolderContainer() {
    return Container(
      height: 100.0,
      width: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        color: Colors.grey[300],
      ),
    );
  }

  Widget podcastsTab() {
    Size size = MediaQuery.of(context).size;
    return (_con.isPodCastLoaded)
        ? shimmer(size)
        : (_con.podcastList == null || _con.podcastList.isEmpty)
            ? commonMsgFunc("No data Fetch")
            : ListView.builder(
                cacheExtent: 99,
                controller: _con.podCastSC,
                itemCount: _con.podcastList.length + 1,
                itemBuilder: (context, index) {
                  if (index == _con.podcastList.length) {
                    return buildProgressIndicator();
                  } else {
                    String title = "";
                    if (Global.podCastCategory != null) {
                      for (int i = 0;
                          i < _con.podcastList[index].category.length;
                          i++) {
                        for (int j = 0;
                            j < Global.podCastCategory.length;
                            j++) {
                          if (Global.podCastCategory[j].categoryId ==
                              _con.podcastList[index].category[i]) {
                            title = title +
                                Global.podCastCategory[j].categoryName +
                                ", ";
                          }
                        }
                      }
                    }

                    bool t;
                    t = title.endsWith(', ');
                    int len = title.length - 2;
                    if (t) {
                      title = title.substring(0, len);
                    }
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                        arguments: RouteArgument(param: [
                          "Podcast",
                          _con.podcastList[index].podCastId.toString()
                        ]),
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
                            Container(
                              margin: EdgeInsets.all(10.0),
                              width: 100.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  7.0,
                                ),
                                child: Hero(
                                  tag: _con.podcastList[index].podCastId,
                                  child: ImageWidget(
                                    imageUrl:
                                        '${_con.podcastList[index].podCastImage}',
                                    height: 100.0,
                                    width: 100.0,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  hBox(7.0),
                                  Text(
                                    _con.podcastList[index].podCastName,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  hBox(5.0),
                                  Wrap(
                                    children: [
                                      Text(
                                        title.isEmpty ? "N/A" : title,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  hBox(5.0),
                                  Text(
                                    _con.podcastList[index].publisher,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
  }

  Widget booksTab() {
    Size size = MediaQuery.of(context).size;
    return _con.isbookLoaded == true
        ? shimmer(size)
        : (_con.booksList == null)
            ? commonMsgFunc("No book fetch")
            : _con.booksList.isEmpty
                ? commonMsgFunc("No data found")
                : ListView.builder(
                    cacheExtent: 99,
                    itemCount: _con.booksList.length,
                    // controller: _con.bookSC,
                    itemBuilder: (context, index) {
                      String year;
                      try {
                        year = DateTime.parse(_con.booksList[index].releaseDate)
                            .year
                            .toString();
                      } catch (e) {
                        year = _con.booksList[index].releaseDate;
                      }
                      String title = "";
                      if (_con.booksList[index].authors != null) {
                        for (var i = 0;
                            i < _con.booksList[index].authors.length;
                            i++) {
                          if (i == _con.booksList[index].authors.length - 1) {
                            title = title + _con.booksList[index].authors[i];
                          } else {
                            title =
                                title + _con.booksList[index].authors[i] + ", ";
                          }
                        }
                      }
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                            RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                            arguments: RouteArgument(param: [
                              "Book",
                              _con.booksList[index].id.toString()
                            ])),
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
                              imageBox('${_con.booksList[index].image}'),
                              commonTexts(
                                  firstTitle: _con.booksList[index].title,
                                  secTitle: title,
                                  thirdTitle: year)
                            ],
                          ),
                        ),
                      );
                    });
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
        ),
      ),
    );
  }

  Widget commonTexts({String firstTitle, String secTitle, String thirdTitle}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          hBox(7.0),
          Text(
            firstTitle,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          hBox(5.0),
          Wrap(
            children: [
              Text(
                secTitle,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
          hBox(5.0),
          Text(
            thirdTitle ?? '',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
