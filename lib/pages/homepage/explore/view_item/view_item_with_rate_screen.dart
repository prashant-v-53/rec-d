import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/explore/view_item/view_item_with_rate_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/model/trending/movie.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';

class ViewItemWithRateScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  ViewItemWithRateScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _ViewItemWithRateScreenState createState() => _ViewItemWithRateScreenState();
}

class _ViewItemWithRateScreenState extends StateMVC<ViewItemWithRateScreen> {
  ViewItemWithRateController _con;
  _ViewItemWithRateScreenState() : super(ViewItemWithRateController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.iniFunc(value: widget.routeArgument.param, context: context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: _con.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : (_con.movieDetails == null)
                    ? Center(
                        child: Text(_con.notFoundmsg),
                      )
                    : SingleChildScrollView(
                        child: Column(children: [
                        Stack(children: [
                          Hero(
                            tag: _con.movieDetails.movieId,
                            child: ImageWidget(
                              imageUrl: _con.movieDetails.movieImage == null
                                  ? Global.staticRecdImageUrl
                                  : '${Global.tmdbImgBaseUrl}'
                                      '${_con.movieDetails.movieImage}',
                              height: size.height / 2,
                              width: size.width,
                            ),
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
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            color: AppColors.PRIMARY_COLOR,
                                          ),
                                          width: size.width / 1.25,
                                          child: Center(
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                Material(
                                                  color: Colors.transparent,
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                      RouteKeys.BOOKMARK_LIST,
                                                      arguments: RouteArgument(
                                                        param: [
                                                          'Movie',
                                                          _con.movieDetails
                                                              .movieId
                                                        ],
                                                      ),
                                                    ),
                                                    child: SvgPicture.asset(
                                                      ImagePath.BOOK,
                                                      color: Colors.white,
                                                      height: 30.0,
                                                      width: 30.0,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () => _con.isRated
                                                      ? Navigator.of(context)
                                                          .pushNamed(
                                                              RouteKeys
                                                                  .VIEW_ITEM_WITH_OUT_RATE,
                                                              arguments:
                                                                  RouteArgument(
                                                                      param: [
                                                                    "Movie",
                                                                    _con.movieDetails
                                                                        .movieId
                                                                        .toString()
                                                                  ]))
                                                      : Navigator.of(context)
                                                          .pushNamed(
                                                              RouteKeys
                                                                  .RATEITEM,
                                                              arguments:
                                                                  RouteArgument(
                                                                      param: [
                                                                    'Movie',
                                                                    _con.movieDetails
                                                                        .movieId,
                                                                    '${Global.tmdbImgBaseUrl}${_con.movieDetails.movieImage}'
                                                                  ])),
                                                  child: SvgPicture.asset(
                                                      ImagePath.VERIFIED,
                                                      color: Colors.white,
                                                      height: 30.0,
                                                      width: 30.0),
                                                ),
                                                InkWell(
                                                    splashColor: Colors.white,
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                          RouteKeys.CONTACT,
                                                          arguments:
                                                              RouteArgument(
                                                            param: [
                                                              'Movie',
                                                              _con.movieDetails,
                                                            ],
                                                          ),
                                                        ),
                                                    child: SvgPicture.asset(
                                                      ImagePath.RECO,
                                                      color: Colors.white,
                                                      height: 28.0,
                                                      width: 28.0,
                                                    )),
                                              ]))))))
                        ]),
                        hBox(25),
                        _theMovieName(),
                        hBox(2.0),
                        _con.relatedRec.isEmpty || _con.relatedRec == null
                            ? Container()
                            : _by(),
                        hBox(25.0),
                        _box()
                      ]))));
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
    String title = "";
    for (var i = 0; i < _con.movieDetails.category.length; i++) {
      if (i == _con.movieDetails.category.length - 1) {
        title = title + _con.movieDetails.category[i]['name'];
      } else {
        title = title + _con.movieDetails.category[i]['name'] + ', ';
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Text(
                _con.movieDetails.movieName,
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
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15.0,
              ),
              softWrap: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _box() {
    return Container(
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
          _wheretoWatchText(),
          _whereToWatch(),
          _aboutTheMovieText(),
          _aboutMovie(),
          reletedItemsText("Related Deep Dives"),
          _releteditems(),
        ],
      ),
    );
  }

  Widget _wheretoWatchText() {
    return Padding(
      padding: _con.padding,
      child: Text(
        "Where To Watch",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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
        "About the movie",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _aboutMovie() {
    return Padding(
      padding: _con.padding,
      child: Text(
        _con.movieDetails.overview,
        overflow: TextOverflow.ellipsis,
        maxLines: 6,
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _releteditems() {
    return (_con.relatedMovie.isEmpty)
        ? Center(child: Text("No Related Deep Dives"))
        : SizedBox(
            height: 145.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _con.relatedMovie.length,
              padding: _con.padding,
              itemBuilder: (_, index) {
                Movie obj = _con.relatedMovie[index];
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(
                          RouteKeys.VIEW_ITEM_WITH_RATE,
                          arguments: RouteArgument(
                              param: _con.relatedMovie[index].movieId),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: ImageWidget(
                          imageUrl:
                              '${Global.tmdbImgBaseUrl}' '${obj.movieImage}',
                          // placeholder: (context, url) => Container(
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(
                          //       10.0,
                          //     ),
                          //     color: Colors.grey[400],
                          //   ),

                          // ),
                          height: 140.0,
                          width: 240.0,
                        ),
                      ),
                    ),
                    wBox(6.0),
                  ],
                );
              },
            ),
          );
  }
}
