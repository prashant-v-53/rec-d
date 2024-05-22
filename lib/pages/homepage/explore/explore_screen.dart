import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/explore/explore_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/movie/view_movie.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/model/trending/movie.dart';
import 'package:recd/model/tv_show/tv_show_model.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class ExploreScreen extends StatefulWidget {
  ExploreScreen({Key key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends StateMVC<ExploreScreen>
    with TickerProviderStateMixin {
  ExploreController _con;
  _ExploreScreenState() : super(ExploreController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();

    _con.controller = TabController(length: 4, vsync: this);
    _con.podCastSC = ScrollController();
    setState(() => _con.isCategoryLoading = true);
    isInternet().then((internet) {
      if (internet) {
        setState(() => _con.isInternet = true);
        _con.fetchTopRatedMovies().then((fetchTopRatedMovie) {
          _con.fetchUpComingMovie().then((fetchUpComingMovie) {
            _con.fetchTopPopularMovies().then((value) {
              _con.fetchCategory("Movie").then((val) {
                if (mounted) {
                  setState(() {
                    _con.popularMovie = value;
                    _con.topRatedMovie = fetchTopRatedMovie;
                    _con.upComingMovie = fetchUpComingMovie;
                    _con.isDataLoaded = true;
                    _con.movieCategory = val;
                    _con.isCategoryLoading = false;
                  });
                }
              });
            });
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
    _con.podCastSC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: getAppbar("Explore"),
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
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            _searchBox(),
            _tabbar(),
            Expanded(
              child: TabBarView(
                controller: _con.controller,
                children: [
                  movieTab(),
                  tvShowTab(),
                  // bookTab(),
                  booksTab(),
                  podCasts(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: _con.padding,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: TextField(
          controller: _con.searchController,
          onSubmitted: (searchInfo) async {
            String searchType = _con.controller.index == 0
                ? "movie"
                : _con.controller.index == 1
                    ? "tv"
                    : _con.controller.index == 2
                        ? "Book"
                        : _con.controller.index == 3
                            ? "Podcast"
                            : null;

            if (searchInfo.isNotEmpty) {
              Navigator.of(context)
                  .pushNamed(
                    RouteKeys.SEARCH,
                    arguments: RouteArgument(param: [
                      searchInfo,
                      searchType,
                    ]),
                  )
                  .then((value) => _con.searchController.text = '');
            }
          },
          textAlign: TextAlign.start,
          textInputAction: TextInputAction.go,
          decoration: InputDecoration(
            isDense: true,
            hintText: "Search",
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
              colors: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabbar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 6.0,
      ),
      child: TabBar(
        unselectedLabelColor: Colors.grey,
        labelColor: AppColors.PRIMARY_COLOR,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 0.0),
        indicatorWeight: 1.0,
        controller: _con.controller,
        indicatorColor: AppColors.PRIMARY_COLOR,
        isScrollable: false,
        tabs: [
          Tab(text: "Movies"),
          Tab(text: "TV Shows"),
          Tab(text: "Books"),
          Tab(text: "Podcasts")
        ],
      ),
    );
  }

  Widget movieTab() {
    return _con.isInternet == false
        ? commonMsgFunc("No Internet !!!")
        : _con.isDataLoaded == false
            ? processing
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    popularSlider(),
                    movieSlider(),
                    findNowMovie(),
                    movieCategory(),
                    hBox(10.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(blurRadius: 5, color: Colors.black12),
                        ],
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          commonTitle(
                              title: 'Top Rated Movies',
                              list: ['Top Rated Movies', 'movie', 'top_rated']),
                          topMovieList(),
                          commonTitle(
                              title: 'Upcoming Movies',
                              list: ['Upcoming Movies', 'movie', 'upcoming']),
                          upComeingMovieList()
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }

  Widget movieSlider() {
    return Padding(
      padding: _con.padding,
      child: Container(
        height: 130.0,
        color: Colors.transparent,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _con.popularMovie.length,
          itemBuilder: (context, index) {
            String title = "";
            for (int i = 0;
                i < _con.popularMovie[index].movieCategory.length;
                i++) {
              if (Global.movieCategory != null)
                for (int j = 0; j < Global.movieCategory.length; j++) {
                  if (Global.movieCategory[j].categoryId ==
                      _con.popularMovie[index].movieCategory[i]) {
                    if (i ==
                        _con.popularMovie[index].movieCategory.length - 1) {
                      title = title + Global.movieCategory[j].categoryName;
                    } else {
                      title =
                          title + Global.movieCategory[j].categoryName + ", ";
                    }
                  }
                }
            }
            Movie data = _con.popularMovie[index];
            return movieCard(data, title);
          },
        ),
      ),
    );
  }

  Widget movieCard(Movie data, String title) {
    return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
            RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
            arguments:
                RouteArgument(param: ["Movie", data.movieId.toString()])),
        child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(7.0),
                child: Stack(children: [
                  ImageWidget(
                    imageUrl: '${Global.tmdbBackdropBaseUrl}${data.movieImage}',
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
                                      child: Text(" ${data.movieTitle}",
                                          style: TextStyle(fontSize: 10.0),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: true)))))),
                  Positioned(
                      bottom: 8.0,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.0,
                              ))))
                ]))));
  }

  Widget findNowMovie() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: Text("Search by Genre",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)));
  }

  Widget popularSlider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      child: Text(
        "Popular Movies",
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget movieCategory() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      child: Container(
        height: 90.0,
        color: Colors.transparent,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => _categoryList(
            cat: _con.movieCategory[index].name,
            genresId: _con.movieCategory[index].genresId,
            image: _con.movieCategory[index].image,
            type: "movie",
          ),
          itemCount: _con.movieCategory.length,
          cacheExtent: 99,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
        ),
      ),
    );
  }

  Widget tvShowCategory() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      child: Container(
        height: 90.0,
        color: Colors.transparent,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => _categoryList(
            cat: _con.tvShowCategory[index].name,
            genresId: _con.tvShowCategory[index].genresId,
            image: _con.tvShowCategory[index].image,
            type: "tv",
          ),
          itemCount: _con.tvShowCategory.length,
          cacheExtent: 99,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
        ),
      ),
    );
  }

  Widget _categoryList(
      {String image, String cat, String type, String genresId}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        RouteKeys.CATEGORY_INFO,
        arguments: RouteArgument(
          param: [type, genresId, cat],
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          color: Colors.white,
          boxShadow: [
            const BoxShadow(
              blurRadius: 5,
              color: Colors.black12,
            ),
          ],
        ),
        height: 95.0,
        width: 95.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageWidget(
              imageUrl: image,
              height: 35,
              width: 35,
            ),
            hBox(1.0),
            Text(
              cat,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commonTitle({String title, List<String> list}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(RouteKeys.SEE_ALL,
                arguments: RouteArgument(param: list)),
            child: Container(
              width: 60.0,
              alignment: Alignment.centerRight,
              child: Text(
                "See All",
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.PRIMARY_COLOR,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topMovieList() {
    return (_con.topRatedMovie == null)
        ? commonMsgFunc("No Data Found !!")
        : Padding(
            padding: _con.padding,
            child: Container(
              height: 225.0,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                cacheExtent: 99,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.of(context).pushNamed(
                        RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                        arguments: RouteArgument(param: [
                          "Movie",
                          _con.topRatedMovie[index].movieId.toString()
                        ])),
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 175,
                            child: Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: ImageWidget(
                                      imageUrl: '${Global.tmdbImgBaseUrl}'
                                          '${_con.topRatedMovie[index].movieImage}',
                                      height: 160.0,
                                      width: 160.0,
                                    )),
                                movieThreeButtton(
                                  'Movie',
                                  _con.topRatedMovie[index].movieId.toString(),
                                  ViewMovie(
                                    movieId: _con.upComingMovie[index].movieId,
                                    category:
                                        _con.upComingMovie[index].movieCategory,
                                    movieImage:
                                        _con.upComingMovie[index].movieImage,
                                    movieName:
                                        _con.upComingMovie[index].movieTitle,
                                    overview: _con.upComingMovie[index].desc,
                                  ),
                                )
                              ],
                            ),
                          ),
                          hBox(7.0),
                          Container(
                            width: 150,
                            child: Text(
                              _con.topRatedMovie[index].movieTitle,
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 5.0, vertical: 7.0),
                          //   child: Row(
                          //     children: [
                          //       friendsCircle(),
                          //       wBox(5.0),
                          //       by(),
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //   width: 150.0,
                          //   child: Text(
                          //     "Lissa and 2 others",
                          //     style: TextStyle(
                          //       color: AppColors.PRIMARY_COLOR,
                          //       fontSize: 14.0,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => wBox(10.0),
                itemCount: _con.topRatedMovie.length,
              ),
            ),
          );
  }

  BoxDecoration boxdecor() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(
            0.4,
          ),
          blurRadius: 1.20,
          offset: Offset(0.5, 0.6),
        )
      ],
    );
  }

  Widget friendsCircle() {
    return Container(
      width: 70.0,
      child: new Stack(
        children: <Widget>[
          new CircleAvatar(
            backgroundImage: NetworkImage(
              _con.net,
            ),
            radius: 13.0,
          ),
          new Positioned(
            left: 20.0,
            child: new CircleAvatar(
              backgroundColor: Colors.white,
              radius: 13.0,
              child: new CircleAvatar(
                backgroundImage: NetworkImage(
                  _con.net,
                ),
                radius: 12.0,
              ),
            ),
          ),
          new Positioned(
            left: 40.0,
            child: new CircleAvatar(
              backgroundColor: Colors.white,
              radius: 13.0,
              child: new CircleAvatar(
                backgroundImage: NetworkImage(
                  _con.net,
                ),
                radius: 12.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget movieThreeButtton(String type, String id, ViewMovie viewItem) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        width: 160.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            movieSendButton(type: "Movie", viewItems: viewItem),
            bookMarkButton(type, id),
            shareButton(),
          ],
        ),
      ),
    );
  }

  Widget tvThreeButtton(String type, String id, ViewTvShow viewItem) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        width: 160.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            tvSendButton(type: "Tv Show", viewItems: viewItem),
            bookMarkButton(type, id),
            shareButton(),
          ],
        ),
      ),
    );
  }

  Widget by() {
    return Container(
      width: 80.0,
      child: Text(
        "REC'd by",
        style: TextStyle(
          color: AppColors.PRIMARY_COLOR,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget movieSendButton({String type, ViewMovie viewItems}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        RouteKeys.CONTACT,
        arguments: RouteArgument(
          param: [
            type,
            viewItems,
          ],
        ),
      ),
      child: new Container(
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16.0,
          child: Center(
            child: SvgPicture.asset(
              ImagePath.RECO,
              color: Colors.black,
              height: 18.0,
              width: 18.0,
            ),
          ),
        ),
        decoration: boxdecor(),
      ),
    );
  }

  Widget tvSendButton({String type, ViewTvShow viewItems}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        RouteKeys.CONTACT,
        arguments: RouteArgument(
          param: [
            type,
            viewItems,
          ],
        ),
      ),
      child: new Container(
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16.0,
          child: Center(
            child: SvgPicture.asset(
              ImagePath.RECO,
              color: Colors.black,
              height: 18.0,
              width: 18.0,
            ),
          ),
        ),
        decoration: boxdecor(),
      ),
    );
  }

  Widget bookMarkButton(String type, String id) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        RouteKeys.BOOKMARK_LIST,
        arguments: RouteArgument(
          param: [type, id],
        ),
      ),
      child: new Container(
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16.0,
          child: Center(
            child: SvgPicture.asset(
              ImagePath.BOOKMARK1,
              color: Colors.black,
              height: 18.0,
              width: 18.0,
            ),
          ),
        ),
        decoration: boxdecor(),
      ),
    );
  }

  Widget shareButton() {
    return new Container(
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 16.0,
        child: Center(
          child: IconButton(
            icon: Icon(
              Icons.share,
              size: 18.0,
              color: Colors.black,
            ),
            onPressed: () => shareInfo(),
          ),
        ),
      ),
      decoration: boxdecor(),
    );
  }

  Widget upComeingMovieList() {
    return Padding(
        padding: _con.padding,
        child: Container(
            height: 225.0,
            child: ListView.builder(
                cacheExtent: 99,
                scrollDirection: Axis.horizontal,
                itemCount: _con.upComingMovie.length,
                itemBuilder: (context, index) => Row(children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Column(children: [
                            Container(
                              height: 175,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushNamed(
                                      RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                                      arguments: RouteArgument(param: [
                                        "Movie",
                                        _con.upComingMovie[index].movieId
                                            .toString()
                                      ]),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: ImageWidget(
                                        imageUrl: '${Global.tmdbImgBaseUrl}'
                                            '${_con.upComingMovie[index].movieImage}',
                                        height: 160.0,
                                        width: 160.0,
                                      ),
                                    ),
                                  ),
                                  movieThreeButtton(
                                      'Movie',
                                      _con.upComingMovie[index].movieId
                                          .toString(),
                                      ViewMovie(
                                          movieId:
                                              _con.upComingMovie[index].movieId,
                                          category: _con.upComingMovie[index]
                                              .movieCategory,
                                          movieImage: _con
                                              .upComingMovie[index].movieImage,
                                          movieName: _con
                                              .upComingMovie[index].movieTitle,
                                          overview:
                                              _con.upComingMovie[index].desc)),
                                ],
                              ),
                            ),
                            hBox(7.0),
                            Container(
                                width: 150,
                                child: Text(
                                    _con.upComingMovie[index].movieTitle,
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500))),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: 5.0, vertical: 7.0),
                            //   child: Row(
                            //     children: [
                            //       friendsCircle(),
                            //       wBox(5.0),
                            //       by(),
                            //     ],
                            //   ),
                            // ),
                            // Container(
                            //   width: 150.0,
                            //   child: Text(
                            //     "Lissa and 2 others",
                            //     style: TextStyle(
                            //       color: AppColors.PRIMARY_COLOR,
                            //       fontSize: 14.0,
                            //     ),
                            //   ),
                            // ),
                          ]))
                    ]))));
  }

  Widget tvShowTab() {
    return _con.isInternet == false
        ? commonMsgFunc("No Internet !!!")
        : _con.isTvShowDataLoaded == false
            ? processing
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    hBox(7.0),
                    findNowMovie(),
                    tvShowCategory(),
                    hBox(10.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(blurRadius: 5, color: Colors.black12)
                          ]),
                      width: double.infinity,
                      child: Column(
                        children: [
                          commonTitle(
                            title: 'Top Rated TV Shows',
                            list: ['Top Rated TV Shows', 'tv', 'airing_today'],
                          ),
                          topTvShowList(),
                          commonTitle(
                            title: 'Popular TV Shows',
                            list: ['Popular TV Shows', 'tv', 'popular'],
                          ),
                          popularTvShowList()
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }

  Widget topTvShowList() {
    return (_con.topRatedTvShow == null)
        ? commonMsgFunc("No Data Found !!!")
        : Padding(
            padding: _con.padding,
            child: Container(
              height: 225.0,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                cacheExtent: 99,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.of(context).pushNamed(
                        RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                        arguments: RouteArgument(param: [
                          "Tv Show",
                          _con.topRatedTvShow[index].id.toString()
                        ])),
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 175,
                            child: Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: ImageWidget(
                                      imageUrl: '${Global.tmdbImgBaseUrl}'
                                          '${_con.topRatedTvShow[index].image}',
                                      height: 160.0,
                                      width: 160.0,
                                    )),
                                tvThreeButtton(
                                  'Tv Show',
                                  _con.topRatedTvShow[index].id.toString(),
                                  ViewTvShow(
                                    tvShowId: _con.popularTvShow[index].id,
                                    tvShowCategory:
                                        _con.popularTvShow[index].category,
                                    tvShowImage:
                                        _con.popularTvShow[index].image,
                                    tvShowName: _con.popularTvShow[index].name,
                                    tvShowOverview:
                                        _con.popularTvShow[index].desc,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hBox(5.0),
                          Container(
                              width: 150,
                              child: Text(_con.topRatedTvShow[index].name,
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => wBox(10.0),
                itemCount: _con.topRatedTvShow.length,
              ),
            ),
          );
  }

  Widget popularTvShowList() {
    return Padding(
      padding: _con.padding,
      child: Container(
        height: 225.0,
        child: ListView.builder(
          cacheExtent: 99,
          scrollDirection: Axis.horizontal,
          itemCount: _con.popularTvShow.length,
          itemBuilder: (context, index) => Row(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  children: [
                    Container(
                      height: 175,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                                arguments: RouteArgument(param: [
                                  "Tv Show",
                                  _con.popularTvShow[index].id.toString()
                                ])),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: ImageWidget(
                                imageUrl: '${Global.tmdbImgBaseUrl}'
                                    '${_con.popularTvShow[index].image}',
                                height: 160.0,
                                width: 160.0,
                              ),
                            ),
                          ),
                          tvThreeButtton(
                            'Tv Show',
                            _con.popularTvShow[index].id.toString(),
                            ViewTvShow(
                              tvShowId: _con.popularTvShow[index].id,
                              tvShowCategory:
                                  _con.popularTvShow[index].category,
                              tvShowImage: _con.popularTvShow[index].image,
                              tvShowName: _con.popularTvShow[index].name,
                              tvShowOverview: _con.popularTvShow[index].desc,
                            ),
                          )
                        ],
                      ),
                    ),
                    hBox(7.0),
                    Container(
                      width: 150,
                      child: Text(
                        _con.popularTvShow[index].name,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //

  Widget podCasts() {
    Size size = MediaQuery.of(context).size;
    return _con.isPodCastLoaded == false
        ? shimmer(size)
        : (_con.podcastList == null)
            ? commonMsgFunc("No data Fetch")
            : ListView.builder(
                cacheExtent: 99,
                controller: _con.podCastSC,
                itemCount: _con.isPodCastPageLoading
                    ? _con.podcastList.length + 1
                    : _con.podcastList.length,
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
                    return InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                              RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
                              arguments: RouteArgument(param: [
                                "Podcast",
                                _con.podcastList[index].podCastId
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
                                              tag: _con
                                                  .podcastList[index].podCastId,
                                              child: ImageWidget(
                                                imageUrl:
                                                    '${_con.podcastList[index].podCastImage}',
                                                height: 100.0,
                                                width: 100.0,
                                              )))),
                                  boxInfo(_con.podcastList[index].podCastName,
                                      title, _con.podcastList[index].publisher),
                                ])));
                  }
                });
  }

  //* Google Books View
  // Widget bookTab() {
  //   Size size = MediaQuery.of(context).size;
  //   return _con.isBookLoaded == false
  //       ? shimmer(size)
  //       : (_con.bookList == null)
  //           ? commonMsgFunc("No Book Fetch")
  //           : ListView.builder(
  //               cacheExtent: 99,
  //               controller: _con.bookSC,
  //               itemCount: _con.bookList.length + 1,
  //               itemBuilder: (context, index) {
  //                 if (index == _con.bookList.length) {
  //                   return buildProgressIndicator();
  //                 } else {
  //                   String title = "";
  //                   if (_con.bookList[index].authors != null) {
  //                     for (var i = 0;
  //                         i < _con.bookList[index].authors.length;
  //                         i++) {
  //                       if (i == _con.bookList[index].authors.length - 1) {
  //                         title = title + _con.bookList[index].authors[i];
  //                       } else {
  //                         title =
  //                             title + _con.bookList[index].authors[i] + ", ";
  //                       }
  //                     }
  //                   }
  //                   return InkWell(
  //                     onTap: () => Navigator.of(context).pushNamed(
  //                         RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
  //                         arguments: RouteArgument(
  //                             param: ["Book", _con.bookList[index].id])),
  //                     child: Card(
  //                       margin: EdgeInsets.symmetric(
  //                           horizontal: 10.0, vertical: 5.0),
  //                       elevation: 5.0,
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(7.0)),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.max,
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           wBox(10.0),
  //                           indexListing(index),
  //                           Container(
  //                             margin: EdgeInsets.all(10.0),
  //                             width: 100.0,
  //                             child: ClipRRect(
  //                               borderRadius: BorderRadius.circular(7.0),
  //                               child: ImageWidget(
  //                                 errorWidget: (context, url, error) {
  //                                   return Container(
  //                                       height: 100.0,
  //                                       width: 100,
  //                                       decoration: BoxDecoration(
  //                                           color: Colors.red,
  //                                           borderRadius:
  //                                               BorderRadius.circular(7.0)),
  //                                       child: Text(" "));
  //                                 },
  //                                 fadeInDuration: Duration(microseconds: 10),
  //                                 fadeInCurve: Curves.easeIn,
  //                                 imageUrl: '${_con.bookList[index].image}',
  //                                 height: 100.0,
  //                                 fit: BoxFit.cover,
  //                                 width: 100.0,
  //                                 placeholder: (context, url) => imageShimmer(),
  //                               ),
  //                             ),
  //                           ),
  //                           _con.bookList[index]?.releaseDate == null
  //                               ? Container()
  //                               : boxInfo(
  //                                   _con.bookList[index].title,
  //                                   "${isDate(_con.bookList[index]?.releaseDate) ? DateFormat("MM-dd-yyyy").format(DateTime.parse(_con.bookList[index]?.releaseDate ?? '0000-00-00')) : ""}",
  //                                   title),
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 }
  //               });
  // }

  Widget boxInfo(String firstTitle, String secTitle, String thirdTitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          hBox(7.0),
          Text(firstTitle,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
          hBox(5.0),
          Wrap(
            children: [
              Text(
                secTitle,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
          hBox(5.0),
          Text(
            thirdTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.0,
            ),
          )
        ],
      ),
    );
  }

  //* view like trending
  Widget booksTab() {
    Size size = MediaQuery.of(context).size;
    return _con.isbookLoading
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
