import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/home/group/create_group_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/model/usermodel.dart';

import 'package:recd/pages/common/common_widgets.dart';

class CreateGroupScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  const CreateGroupScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends StateMVC<CreateGroupScreen> {
  CreateGroupController _con;

  _CreateGroupScreenState() : super(CreateGroupController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();
    _con.initialize(widget.routeArgument.param);
    _con.fToast = FToast();
    _con.fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: _body(),
    );
  }

  Widget _appbar() {
    return AppBar(
      title: Text(
        "New Group",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(_con.removePerson),
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        _con.isLoading
            ? Container()
            : InkWell(
                onTap: () => _con.createGroup(context),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: AppColors.PRIMARY_COLOR,
                    ),
                  ),
                ),
              )
      ],
    );
  }

  Widget _body() {
    return _con.isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                hBox(10.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (_con.flag == true)
                          ? selectedProfile()
                          : GestureDetector(
                              onTap: () => _con.selectPhoto(),
                              child: CircleAvatar(
                                backgroundColor: AppColors.PRIMARY_COLOR,
                                radius: 32,
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 30.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      wBox(10.0),
                      Expanded(
                        child: TextField(
                          controller: _con.groupname,
                          decoration: InputDecoration(
                            hintText: " Enter Group Name",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.black12,
                        )
                      ],
                      color: Colors.white,
                    ),
                    height: MediaQuery.of(context).size.height * 0.772,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              children: [
                                for (var i = 0; i < _con.parms.length; i++)
                                  circleWidget(_con.parms[i]),
                              ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget circleWidget(UserInfo parms) {
    return Padding(
      padding: const EdgeInsets.all(7.5),
      child: Stack(
        children: [
          Container(
            height: 120.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.PRIMARY_COLOR,
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.PRIMARY_COLOR,
              ),
              child: CircleAvatar(
                radius: 32.0,
                backgroundImage: NetworkImage(
                  parms.profileimage,
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0.0,
              left: 20.0,
              child: Text(parms.name, style: TextStyle(fontSize: 12.0))),
          Positioned(
            right: 0.0,
            top: 7.0,
            height: 50.0,
            child: SizedBox(
              width: 25.0,
              child: GestureDetector(
                onTap: () => _con.personRemove(parms.userid),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.PRIMARY_COLOR),
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.PRIMARY_COLOR,
                    size: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedProfile() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Center(
        child: Stack(
          children: [
            Container(
              height: 70.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.PRIMARY_COLOR,
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.PRIMARY_COLOR,
                ),
                child: CircleAvatar(
                  radius: 25.0,
                  backgroundImage: _con.file == null
                      ? AssetImage(ImagePath.ICONPATH)
                      : FileImage(_con.file),
                ),
              ),
            ),
            Positioned(
              right: 0.0,
              top: -5.0,
              height: 40.0,
              child: SizedBox(
                width: 25.0,
                child: InkWell(
                  onTap: () => _con.setFlag(),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.PRIMARY_COLOR,
                      ),
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.PRIMARY_COLOR,
                      size: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
