import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/bookmarks/save_to_bookmark_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class SaveToBookmarkScreen extends StatefulWidget {
  final RouteArgument routeArgument;

  SaveToBookmarkScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _SaveToBookmarkScreenState createState() => _SaveToBookmarkScreenState();
}

class _SaveToBookmarkScreenState extends StateMVC<SaveToBookmarkScreen> {
  SaveToBookmarkController _con;
  _SaveToBookmarkScreenState() : super(SaveToBookmarkController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    if (widget?.routeArgument?.param?.isNotEmpty != null) {
      _con.bookmarkType = widget.routeArgument.param[0].toString();
      _con.entityId = widget.routeArgument.param[1].toString();
    }
    isInternet().then((value) {
      if (value) {
        _con.getBookmarks1().then((bookmarkinfo) {
          setState(() {
            _con.isLoading = false;
            _con.bookMarkData = bookmarkinfo;
          });
          if (_con.bookMarkData != null && _con.bookMarkData.isNotEmpty) {
            _con.bookMarkData.forEach((element) {
              if (element.isBookmarked) {
                _con.selectedIdList.add(element.bookmarkId);
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _con.isOnSkipLoading
        ? Scaffold(body: processing)
        : Scaffold(
            key: _con.scaffoldKey,
            floatingActionButton: _createButton(),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                decoration:
                    BoxDecoration(boxShadow: [BoxShadow(blurRadius: 1)]),
                child: MaterialButton(
                  disabledColor: Colors.grey,
                  color: AppColors.PRIMARY_COLOR,
                  height: 50.0,
                  child: _con.isSaveLoading
                      ? CircularProgressIndicator(backgroundColor: Colors.white)
                      : Text(
                          "Done",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                  onPressed: _con.selectedIdList.length == 0
                      ? null
                      : _con.isSaveLoading
                          ? () {}
                          : () async {
                              await _con.onSubmit(data: {
                                "bookmark_id": _con.selectedIdList,
                                "bookmark_type": _con.bookmarkType,
                                "id": _con.entityId
                              }).then((val) {
                                if (val != null && val) {
                                  Navigator.pop(context, "yes");
                                } else if (val == false) {
                                  Navigator.pop(context, "no");
                                }
                              });
                            },
                ),
              ),
            ),
            appBar: _appBar(),
            body: _body(),
          );
  }

// * App bar
  AppBar _appBar() {
    return AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leadingWidth: 30.0,
        title: const Text(
          "Save to Bookmark List",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop("no"),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: [
          InkWell(
            onTap: () => _con.onSkip(
              data: {
                "bookmark_type": _con.bookmarkType.toString(),
                "id": _con.entityId.toString(),
              },
            ).then(
              (val) {
                if (val) {
                  Navigator.of(context).pop("yes");
                } else {
                  setState(() => _con.isOnSkipLoading = false);
                }
              },
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 18.0,
              ),
              child: Text(
                "Skip",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.PRIMARY_COLOR,
                ),
              ),
            ),
          ),
        ],
        centerTitle: false);
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        child: _con.isLoading
            ? Overlay(
                initialEntries: <OverlayEntry>[
                  OverlayEntry(
                    opaque: true,
                    maintainState: true,
                    builder: (context) => Container(
                        child: Center(child: CircularProgressIndicator())),
                  )
                ],
              )
            : _con.bookMarkData == null
                ? commonMsgFunc("Please create bookmark list")
                : _con.bookMarkData.isEmpty
                    ? commonMsgFunc("Please create bookmark list")
                    : ListView.separated(
                        itemCount: _con.bookMarkData.length,
                        itemBuilder: (context, index) => ListTile(
                          title: GestureDetector(
                            onTap: () {
                              _con.checkClick(
                                  _con?.bookMarkData[index]?.bookmarkId);
                            },
                            child: Container(
                              child: Text(
                                '${_con?.bookMarkData[index]?.bookmarkTitle ?? ''}',
                                style: TextStyle(fontSize: 16.0),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          leading: Checkbox(
                            value: _con.selectedIdList.contains(
                                _con?.bookMarkData[index]?.bookmarkId),
                            activeColor: AppColors.PRIMARY_COLOR,
                            onChanged: (value) {
                              _con.checkClick(
                                  _con?.bookMarkData[index]?.bookmarkId);
                            },
                          ),
                        ),
                        separatorBuilder: (context, index) => d(),
                      ),
      ),
    );
  }

// * Create Button
  Widget _createButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: MaterialButton(
        onPressed: () async {
          Object result = await Navigator.of(context).pushNamed(
              RouteKeys.CREATE_BOOKMARK,
              arguments: RouteArgument(param: "create"));
          if (result == "success") {
            setState(() => _con.isLoading = true);
            _con.getBookmarks1().then((bookmarkinfo) {
              setState(() {
                _con.isLoading = false;
                _con.bookMarkData = bookmarkinfo;
              });
              if (_con.bookMarkData != null && _con.bookMarkData.isNotEmpty) {
                _con.bookMarkData.forEach((element) {
                  if (element.isBookmarked) {
                    _con.selectedIdList.add(element.bookmarkId);
                  }
                });
              }
            });
          }
        },
        child: Text("Create New List",
            style: TextStyle(color: AppColors.WHITE_COLOR, fontSize: 15.0)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        height: General.BUTTON_HEIGHT,
        color: AppColors.PRIMARY_COLOR,
      ),
    );
  }
}
