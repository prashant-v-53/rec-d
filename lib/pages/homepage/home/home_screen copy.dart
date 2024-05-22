import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/home/home_controller%20copy.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/listner/notification_listner.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class NewHomeScreen extends StatefulWidget {
  @override
  _NewHomeScreenState createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends StateMVC<NewHomeScreen> {
  NewHomeController _con;
  _NewHomeScreenState() : super(NewHomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.pageController.addListener(() {
      if (_con.pageController.position.pixels ==
          _con.pageController.position.maxScrollExtent) {
        _con.page++;
        _con.fetchConversation(_con.page).then((list) {
          if (list != null)
            setState(() {
              _con.conList.addAll(list);
            });
        });
      }
    });
    setState(() => _con.isLoading = true);
    _con.fetchConversation(_con.page).then((value) {
      if (mounted) {
        setState(() {
          _con.conList = value;
          _con.isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _con.scaffoldKey, appBar: _appBar(), body: _body());
  }

//* Appbar
  AppBar _appBar() {
    return AppBar(
        title: Image.asset(ImagePath.ICONPATH, scale: 3.0),
        centerTitle: true,
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                icon: Icon(Icons.people_sharp,
                    color: AppColors.PRIMARY_COLOR, size: 30.0),
                onPressed: () =>
                    Navigator.of(context).pushNamed(RouteKeys.HOME_CONTACT))),
        actions: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(children: <Widget>[
                IconButton(
                    icon: Icon(Icons.notifications_none_outlined,
                        color: AppColors.PRIMARY_COLOR, size: 25.0),
                    onPressed: () => Navigator.of(context)
                        .pushNamed(RouteKeys.NOTIFICATION)),
                Consumer<NListner>(builder: (context, nListner, child) {
                  if (nListner.getNBadge == 0) {
                    return hBox(0);
                  } else {
                    _con.fetchConversation(_con.page).then((value) {
                      if (mounted) {
                        setState(() {
                          _con.conList = value;
                          _con.isLoading = false;
                        });
                      }
                    });
                    return new Positioned(
                        right: 8,
                        child: new Container(
                            padding: EdgeInsets.all(2),
                            decoration: new BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            constraints:
                                BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Text(nListner.getNBadge.toString(),
                                style: new TextStyle(
                                    color: Colors.white, fontSize: 10),
                                textAlign: TextAlign.center)));
                  }
                })
              ]))
        ]);
  }

//* Body
  Widget _body() {
    Size size = MediaQuery.of(context).size;
    return _con.isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : _con.conList == null || _con.conList.isEmpty
            ? Center(
                child: Text("No RECs Found"),
              )
            : ListView.builder(
                itemCount: _con.conList.length,
                controller: _con.pageController,
                itemBuilder: (context, index) {
                  if (_con.conList[index].isGroup == true) {
                    return InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                            RouteKeys.GROUP_RECOMMENDED,
                            arguments: RouteArgument(param: [
                              _con.conList[index].id,
                              _con.conList[index].title,
                              _con.conList[index].isGroup
                            ])),
                        child: Column(children: [
                          Column(children: [
                            newUi(
                                title: _con.conList[index].title,
                                humanDate: _con.conList[index].humanDate,
                                image: _con.conList[index].conImage,
                                size: size,
                                subTitle:
                                    "${_con.conList[index].userName} : ${_con.conList[index].lastMsgTitle}"),
                            d()
                          ])
                        ]));
                  } else {
                    return Column(children: [
                      InkWell(
                          onTap: () => Navigator.of(context).pushNamed(
                              RouteKeys.GROUP_RECOMMENDED,
                              arguments: RouteArgument(param: [
                                _con.conList[index].id,
                                _con.conList[index].title,
                                _con.conList[index].isGroup
                              ])),
                          child: Column(children: [
                            newUi(
                                title: _con.conList[index].title,
                                humanDate: _con.conList[index].humanDate,
                                image: _con.conList[index].conImage,
                                size: size,
                                subTitle: _con.conList[index].lastMsgTitle),
                            d()
                          ]))
                    ]);
                  }
                });
  }

  Widget newUi(
      {Size size,
      String image,
      String humanDate,
      String title,
      String subTitle}) {
    String d = getLocalDate(humanDate);
    return ListTile(
        leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(image), radius: 30.0),
        title: Text(title,
            softWrap: true,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        subtitle: Text(subTitle,
            softWrap: true,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        trailing: Text(d, style: TextStyle(fontSize: 12.0)));
  }
}
