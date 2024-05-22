import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/profile/recs_details_controller.dart';
import 'package:recd/elements/helper.dart';

import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';

class RecsScreen extends StatefulWidget {
  RecsScreen({Key key}) : super(key: key);

  @override
  _RecsScreenState createState() => _RecsScreenState();
}

class _RecsScreenState extends StateMVC<RecsScreen> {
  RecsDetailsController _con;
  _RecsScreenState() : super(RecsDetailsController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.pageScroll.addListener(() {
      if (_con.pageScroll.position.pixels ==
          _con.pageScroll.position.maxScrollExtent) {
        _con.page++;

        setState(() => _con.isPaginationLoading = true);

        _con.fetchAllRecs(_con.page).then((value) {
          setState(() => _con.isPaginationLoading = false);

          if (value != null) setState(() => _con.recsList.addAll(value));
        });
      }
    });
    setState(() => _con.isRecsLoading = true);
    _con.fetchAllRecs(_con.page).then((val) {
      setState(() {
        _con.recsList = val;
        _con.isRecsLoading = false;
        _con.isPaginationLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(key: _con.scaffoldKey, appBar: _appBar(), body: _body());

  AppBar _appBar() {
    return AppBar(
      leading: leadingIcon(context: context),
      backgroundColor: Colors.white,
      title: Text(
        "RECs",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }

  Widget _body() {
    return _con.isRecsLoading
        ? processing
        : _con.recsList == null || _con.recsList.isEmpty
            ? commonMsgFunc("No Recs Found")
            : ListView.builder(
                itemCount: _con.isPaginationLoading
                    ? _con.recsList.length + 1
                    : _con.recsList.length,
                controller: _con.pageScroll,
                itemBuilder: (context, index) {
                  if (index == _con.recsList.length) {
                    return buildProgressIndicator();
                  } else {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 2.0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => navigateToItemScreen(
                                    _con.recsList[index].itemType,
                                    _con.recsList[index].itemId),
                                child: _secSection(
                                  title: _con.recsList[index].title,
                                  desc: _con.recsList[index].subtitle,
                                  img: _con.recsList[index].image,
                                  humanDate: _con.recsList[index].humanDate,
                                ),
                              ),
                              _thirdSection(_con.recsList[index].recipientList,
                                  _con.recsList[index].totalReco),
                              d(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
  }

  navigateToItemScreen(String type, String id) {
    Navigator.of(context).pushNamed(RouteKeys.VIEW_ITEM_WITH_OUT_RATE,
        arguments: RouteArgument(param: [type, id]));
  }

  Widget _secSection(
      {String img, String title, String desc, String humanDate}) {
    String d =
        TimeAgo().timeAgo(DateTime.parse(DateTime.parse(humanDate).toString()));
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            width: 100.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                7.0,
              ),
              child: ImageWidget(
                imageUrl: img,
                height: 100.0,
                width: 100.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  title,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                ),
              ),
              hBox(7.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Align(
                  child: Container(
                    height: 40.0,
                    child: Html(
                      data: desc,
                      style: {
                        'body': Style(
                          display: Display.INLINE,
                          color: Colors.grey,
                        )
                      },
                      shrinkWrap: true,
                    ),
                  ),
                ),
              ),
              hBox(7.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

//* include photo overlay and name
  Widget _thirdSection(List list, int totalUsers) {
    String title = "REC'd to ";
    list[0]['is_group']
        ? title += list[0]['group_name']
        : title += list[0]['members']['name'];

    totalUsers > 1 ? title += " and $totalUsers others" : title = title;

    double w = getUserImageListWidth(list);

    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          Container(
              width: w,
              child: new Stack(children: <Widget>[
                list[0]['is_group']
                    ? imgCircle(list[0]['group_cover_path'])
                    : imgCircle(list[0]['members']['profile_path']),
                list.length > 1
                    ? Positioned(
                        left: 20.0,
                        child: list[1]['is_group']
                            ? imgCircle(list[1]['group_cover_path'])
                            : imgCircle(list[1]['members']['profile_path']))
                    : hBox(0.0),
                list.length > 2
                    ? new Positioned(
                        left: 40.0,
                        child: list[2]['is_group']
                            ? imgCircle(list[2]['group_cover_path'])
                            : imgCircle(list[2]['members']['profile_path']))
                    : hBox(0.0)
              ])),
          Flexible(
              child: Text("$title",
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 1,
                  style: TextStyle(
                      color: AppColors.PRIMARY_COLOR, fontSize: 12.0)))
        ]));
  }

  CircleAvatar imgCircle(String image) => CircleAvatar(
      backgroundColor: Colors.white,
      radius: 16.0,
      child: new CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(image), radius: 15.0));
}
