import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/search/serach_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';
import 'package:recd/pages/common/shimmer_effect_widget.dart';

class SearchResultScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  SearchResultScreen({Key key, this.routeArgument}) : super(key: key);
  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends StateMVC<SearchResultScreen> {
  SearchController _con;
  _SearchResultScreenState() : super(SearchController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();
    isInternet().then((value) {
      setState(() => _con.isInternet = true);
      if (value) {
        _con.page = 1;
        _con.bookPage = 0;
        _con
            .fetchData(
                searchData: widget.routeArgument.param[0],
                type: widget.routeArgument.param[1],
                page: widget.routeArgument.param[1] == "Book"
                    ? _con.bookPage
                    : widget.routeArgument.param[1] == "Podcast"
                        ? 0
                        : 1)
            .then((searchData) {
          setState(() {
            _con.searchList = searchData;
            _con.isLoading = false;
          });
        });
      }
    });
    _con.searchController.text = widget.routeArgument.param[0].toString();
    if (widget.routeArgument.param[1] == "movie") {
      _con.setState(() => _con.filter = 0);
      _con.filterType = "movie";
    } else if (widget.routeArgument.param[1] == "tv") {
      _con.setState(() => _con.filter = 1);
      _con.filterType = "tv";
    } else if (widget.routeArgument.param[1] == "Book") {
      _con.setState(() => _con.filter = 2);
      _con.filterType = "Book";
    } else if (widget.routeArgument.param[1] == "Podcast") {
      _con.setState(() => _con.filter = 3);
      _con.filterType = "Podcast";
    }

    _con.pageController.addListener(() {
      if (_con.pageController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_con.searchVisible == true) {
          setState(() {
            _con.searchVisible = false;
          });
        }
      } else {
        if (_con.pageController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_con.searchVisible == false) {
            setState(() {
              _con.searchVisible = true;
            });
          }
        }
      }
      if (_con.pageController.position.pixels ==
          _con.pageController.position.maxScrollExtent) {
        setState(() => _con.isPageLoading = true);
        _con.podcastPage = _con.podcastPage + 10;
        _con.page = _con.page + 1;
        _con.bookPage = _con.bookPage + 40;
        _con
            .fetchData(
                searchData: _con.searchController.text,
                type: widget.routeArgument.param[1],
                page: widget.routeArgument.param[1] == "Book"
                    ? _con.bookPage
                    : widget.routeArgument.param[1] == "Podcast"
                        ? _con.podcastPage
                        : _con.page)
            .then((list) {
          if (list != null) {
            setState(() {
              _con.searchList.addAll(list);
              _con.isLoading = false;
            });
          }
          setState(() => _con.isPageLoading = false);
        });
      }
    });
    setState(() => _con.isLoading = true);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBar(),
      body: Stack(
        children: [
          _searchBox(),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: EdgeInsets.only(top: _con.searchVisible ? 70 : 0),
            child: _con.isInternet == false
                ? msgWidget("")
                : _con.isDataLoaded
                    ? buildProgressIndicator()
                    : _con.isLoading
                        ? Container(child: shimmer(size))
                        : _con.searchList == null || _con.searchList.isEmpty
                            ? msgWidget("No data found")
                            : ListView.builder(
                                cacheExtent: 99,
                                controller: _con.pageController,
                                itemCount: _con.isPageLoading
                                    ? _con.searchList.length + 1
                                    : _con.searchList.length,
                                itemBuilder: (context, index) {
                                  if (index == _con.searchList.length) {
                                    return buildProgressIndicator();
                                  } else {
                                    String title = "";

                                    if (_con.searchList[index].itemtype ==
                                        "Movie") {
                                      for (int i = 0;
                                          i <
                                              _con.searchList[index].category
                                                  .length;
                                          i++) {
                                        if (Global.movieCategory != null) {
                                          for (int j = 0;
                                              j < Global.movieCategory.length;
                                              j++) {
                                            if (Global.movieCategory[j]
                                                    .categoryId ==
                                                _con.searchList[index]
                                                    .category[i]) {
                                              if (_con.searchList[index]
                                                      .category.length ==
                                                  1) {
                                                title = Global.movieCategory[j]
                                                    .categoryName;
                                              } else if (i ==
                                                  _con.searchList[index]
                                                          .category.length -
                                                      1) {
                                                title = title +
                                                    Global.movieCategory[j]
                                                        .categoryName;
                                              } else {
                                                title = title +
                                                    Global.movieCategory[j]
                                                        .categoryName +
                                                    ", ";
                                              }
                                            }
                                          }
                                        }
                                      }
                                    } else if (_con
                                            .searchList[index].itemtype ==
                                        "Tv Show") {
                                      if (Global.tvShowCategory != null) {
                                        for (int i = 0;
                                            i <
                                                _con.searchList[index].category
                                                    .length;
                                            i++) {
                                          for (int j = 0;
                                              j < Global.tvShowCategory.length;
                                              j++) {
                                            if (Global.tvShowCategory[j]
                                                    .categoryId ==
                                                _con.searchList[index]
                                                    .category[i]) {
                                              if (_con.searchList[index]
                                                      .category.length ==
                                                  1) {
                                                title = Global.tvShowCategory[j]
                                                    .categoryName;
                                              } else if (i ==
                                                  _con.searchList[index]
                                                          .category.length -
                                                      1) {
                                                title = title +
                                                    Global.tvShowCategory[j]
                                                        .categoryName;
                                              } else {
                                                title = title +
                                                    Global.tvShowCategory[j]
                                                        .categoryName +
                                                    ", ";
                                              }
                                            }
                                          }
                                        }
                                      }
                                    } else if (_con
                                            .searchList[index].itemtype ==
                                        "Podcast") {
                                      if (Global.podCastCategory != null) {
                                        for (int i = 0;
                                            i <
                                                _con.searchList[index].category
                                                    .length;
                                            i++) {
                                          for (int j = 0;
                                              j < Global.podCastCategory.length;
                                              j++) {
                                            if (Global.podCastCategory[j]
                                                    .categoryId ==
                                                _con.searchList[index]
                                                    .category[i]) {
                                              if (_con.searchList[index]
                                                      .category.length ==
                                                  1) {
                                                title = Global
                                                    .podCastCategory[j]
                                                    .categoryName;
                                              } else if (i ==
                                                  _con.searchList[index]
                                                          .category.length -
                                                      1) {
                                                title = title +
                                                    Global.podCastCategory[j]
                                                        .categoryName;
                                              } else {
                                                title = title +
                                                    Global.podCastCategory[j]
                                                        .categoryName +
                                                    ", ";
                                              }
                                            }
                                          }
                                        }
                                      }
                                    } else if (_con
                                            .searchList[index].itemtype ==
                                        "Book") {
                                      for (var i = 0;
                                          i <
                                              _con.searchList[index].category
                                                  .length;
                                          i++) {
                                        if (_con.searchList[index].category
                                                .length ==
                                            1) {
                                          title = _con
                                              .searchList[index].category[i];
                                        } else {
                                          title = title = _con
                                              .searchList[index].category[i];
                                        }
                                      }
                                    }
                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () => transferToPage(index),
                                          child: mainCard(
                                            index: index,
                                            title: title,
                                          ),
                                        ),
                                        _con.isBookPageLoading
                                            ? buildProgressIndicator()
                                            : Container()
                                      ],
                                    );
                                  }
                                },
                              ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      leading: leadingIcon(context: context),
      title: Text(
        "Search",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: StatefulBuilder(
                  builder: (context, setState) => Container(
                    height: 330,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Search By",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // ListTile(
                        //   leading: Radio(
                        //     onChanged: (val) => setState(() {
                        //       _con.filter = val;
                        //       _con.filterType = "movie";
                        //     }),
                        //     value: 0,
                        //     groupValue: _con.filter,
                        //   ),
                        //   title: Text("Movie"),
                        // ),
                        // ListTile(
                        //   leading: Radio(
                        //     onChanged: (val) => setState(() {
                        //       _con.filter = val;
                        //       _con.filterType = "tv";
                        //     }),
                        //     value: 1,
                        //     groupValue: _con.filter,
                        //   ),
                        //   title: Text("TV Show"),
                        // ),
                        // ListTile(
                        //   leading: Radio(
                        //     onChanged: (val) => setState(() {
                        //       _con.filter = val;
                        //       _con.filterType = "Book";
                        //     }),
                        //     value: 2,
                        //     groupValue: _con.filter,
                        //   ),
                        //   title: Text("Book"),
                        // ),
                        // ListTile(
                        //   leading: Radio(
                        //     onChanged: (val) => setState(() {
                        //       _con.filter = val;
                        //       _con.filterType = "Podcast";
                        //     }),
                        //     value: 3,
                        //     groupValue: _con.filter,
                        //   ),
                        //   title: Text("Podcast"),
                        // ),
                        ListTile(
                          onTap: () {
                            setState(() {
                              _con.filter = 0;
                              _con.filterType = "movie";
                            });
                          },
                          leading: Radio(
                            onChanged: (val) => setState(() {
                              _con.filter = val;
                              _con.filterType = "movie";
                            }),
                            value: 0,
                            groupValue: _con.filter,
                          ),
                          title: Text("Movie"),
                        ),
                        ListTile(
                          onTap: () {
                            setState(() {
                              _con.filter = 1;
                              _con.filterType = "tv";
                            });
                          },
                          leading: Radio(
                            onChanged: (val) => setState(() {
                              print(val);
                              _con.filter = val;
                              _con.filterType = "tv";
                            }),
                            value: 1,
                            groupValue: _con.filter,
                          ),
                          title: Text("TV Show"),
                        ),
                        ListTile(
                          onTap: () {
                            setState(() {
                              _con.filter = 2;
                              _con.filterType = "Book";
                            });
                          },
                          leading: Radio(
                            onChanged: (val) => setState(() {
                              _con.filter = val;
                              _con.filterType = "Book";
                            }),
                            value: 2,
                            groupValue: _con.filter,
                          ),
                          title: Text("Book"),
                        ),
                        ListTile(
                          onTap: () {
                            setState(() {
                              _con.filter = 3;
                              _con.filterType = "Podcast";
                            });
                          },
                          leading: Radio(
                            onChanged: (val) => setState(() {
                              _con.filter = val;
                              _con.filterType = "Podcast";
                            }),
                            value: 3,
                            groupValue: _con.filter,
                          ),
                          title: Text("Podcast"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [cancelButton(), applyButton()],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          icon: Icon(
            Icons.filter_list_alt,
            color: AppColors.PRIMARY_COLOR,
          ),
        )
      ],
    );
  }

  MaterialButton cancelButton() {
    return MaterialButton(
      color: AppColors.PRIMARY_COLOR,
      onPressed: () => Navigator.of(context).pop(),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          25.0,
        ),
      ),
      child: Text(
        "Cancel",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  MaterialButton applyButton() {
    return MaterialButton(
      color: AppColors.PRIMARY_COLOR,
      onPressed: () {
        Navigator.of(context).pop();
        if (_con.searchController.text.isNotEmpty) {
          setState(() {
            _con.isLoading = true;
          });

          _con.page = 1;
          _con.bookPage = 40;
          _con.podcastPage = 10;

          _con
              .fetchData(
                  searchData: _con.searchController.text,
                  type: _con.filterType,
                  page: widget.routeArgument.param[1] == "Book"
                      ? _con.bookPage
                      : widget.routeArgument.param[1] == "Podcast"
                          ? _con.podcastPage
                          : _con.page)
              .then((data) {
            setState(() {
              _con.searchList = data;
              _con.isLoading = false;
            });
          });
        }
      },
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          25.0,
        ),
      ),
      child: Text(
        "Apply",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  transferToPage(int index) {
    Navigator.of(context).pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [
          _con.searchList[index].itemtype,
          _con.searchList[index].id
        ]));
  }

  Card mainCard({
    String title,
    int index,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          7.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wBox(10.0),
          firstText(index),
          secImage(image: _con.searchList[index].image, index: index),
          thirdBox(index, title),
        ],
      ),
    );
  }

  Widget firstText(int index) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Text(
        '${index + 1}',
      ),
    );
  }

  Container secImage({String image, int index}) {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: 100.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          7.0,
        ),
        child: ImageWidget(
          imageUrl: image == null ? Global.staticRecdImageUrl : image,
          height: 100.0,
          width: 100.0,
        ),
      ),
    );
  }

  Expanded thirdBox(int index, String title) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          hBox(10.0),
          firstTitle(index, _con.searchList[index].title),
          hBox(5.0),
          categoryName(
              text:
                  title.isEmpty || title.toString() == "null" ? "N/A" : title),
          hBox(5.0),
          lastTitle(_con.searchList[index].itemtype == "Book"
              ? _con.searchList[index].bookPublishedDate
              : _con.searchList[index].desc.toString()),
        ],
      ),
    );
  }

  Widget firstTitle(int index, String title) {
    return Wrap(
      children: [
        Text(
          title == null || title.isEmpty ? "N/A" : title,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Text categoryName({String text}) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        color: Colors.grey,
      ),
    );
  }

  Widget lastTitle(String message) {
    return Text(
      message.isEmpty || message == null ? "N/A" : message,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        color: Colors.grey,
      ),
    );
  }

  Widget _searchBox() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: !_con.searchVisible
          ? Container()
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                child: TextField(
                  controller: _con.searchController,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _con.isDataLoaded = true;
                      });
                      _con.page = 1;
                      _con.bookPage = 0;
                      _con.podcastPage = 0;

                      _con
                          .fetchData(
                              searchData: value,
                              type: _con.filterType,
                              page: widget.routeArgument.param[1] == "Book"
                                  ? _con.bookPage
                                  : widget.routeArgument.param[1] == "Podcast"
                                      ? _con.podcastPage
                                      : _con.page)
                          .then((data) {
                        setState(() {
                          _con.searchList = data;
                          _con.isLoading = false;
                          _con.isDataLoaded = false;
                        });
                      });
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
            ),
    );
  }

  Widget msgWidget(String infoMsg) {
    return Container(
      child: Center(
        child: Text(infoMsg),
      ),
    );
  }
}
