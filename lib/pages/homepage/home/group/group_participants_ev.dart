import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/home/group/group_participants_ev_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/helpers/app_colors.dart';

//* this screen is for Edit and View the group participants

class GroupParticipantsEVScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  GroupParticipantsEVScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _GroupParticipantsEVScreenState createState() =>
      _GroupParticipantsEVScreenState();
}

class _GroupParticipantsEVScreenState
    extends StateMVC<GroupParticipantsEVScreen> {
  GroupParticipantsEVController _con;
  _GroupParticipantsEVScreenState() : super(GroupParticipantsEVController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    //* Group Id
    _con.fetchGroupMember(widget.routeArgument.param).then((value) {
      setState(() {
        _con.groupDetails = value;
        _con.isLoading = false;
        _con.groupLabel = _con.groupDetails.gName;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _con.isUserLeaveing
        ? Scaffold(body: processing)
        : _con.isLoading
            ? Scaffold(body: processing)
            : Scaffold(
                key: _con.scaffoldKey,
                floatingActionButton:
                    _con.groupDetails.isGroupCreatedByYou == false
                        ? null
                        : fab(),
                appBar: _appBar(
                    isGroupCreatedByYou: _con.groupDetails.isGroupCreatedByYou),
                body: _con.isPersonRemoving
                    ? processing
                    : _body(
                        isGroupCreatedByYou:
                            _con.groupDetails.isGroupCreatedByYou));
  }

  FloatingActionButton fab() => FloatingActionButton(
      onPressed: () => _con.popDataAdd(context),
      backgroundColor: Colors.white,
      child: Icon(Icons.add, color: AppColors.PRIMARY_COLOR, size: 45.0));

  AppBar _appBar({bool isGroupCreatedByYou}) {
    Size size = MediaQuery.of(context).size;
    return AppBar(
        centerTitle: true,
        title: Text("Group Details",
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.w600)),
        leading: leadingIcon(context: context),
        actions: [
          isGroupCreatedByYou == false
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded,
                          color: AppColors.PRIMARY_COLOR),
                      onSelected: (String result) {
                        return showDialog(
                            context: context,
                            useSafeArea: true,
                            builder: (context) => AlertDialog(
                                title: Text("Are you sure you want to leave?"),
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                                content: Container(
                                    height: 50,
                                    width: size.width / 1.1,
                                    child: Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            yesLeaveButton(groupId: "id"),
                                            noButton()
                                          ])
                                    ]))));
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                            value: "leave", child: Text('Leave Group'))
                      ],
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ))
              : InkWell(
                  onTap: () => _con.updateGroup(
                      context: context, groupId: _con.groupDetails.gid),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                          child: Text("Done",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: AppColors.PRIMARY_COLOR,
                                  fontWeight: FontWeight.w500)))))
        ]);
  }

  Widget _body({bool isGroupCreatedByYou}) {
    Size size = MediaQuery.of(context).size;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          hBox(15.0),
          topIcon(isGroupCreatedByYou),
          hBox(25.0),
          _con.textBoxFlag
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [groupEditTextBox(size), wBox(5.0), okButton()])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: groupName(size)),
                    wBox(5),
                    isGroupCreatedByYou == false ? Text("") : groupEditIcon()
                  ],
                ),
          _con.textBoxFlag
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: errorText(_con.groupNameDisplay))
              : Container(),
          hBox(10.0),
          Expanded(
              child: Container(
                  decoration: boxDecoration(),
                  width: double.infinity,
                  child: SingleChildScrollView(
                      child:
                          Column(children: [groupBox(isGroupCreatedByYou)]))))
        ]);
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        color: AppColors.PRIMARY_COLOR);
  }

  Widget groupBox(bool isGroupCreatedByYou) {
    return Container(
      child: Column(
        children: [
          containerText(),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _con.groupDetails.listOfUser
                .asMap()
                .map(
                  (info, index) {
                    return MapEntry(
                      info,
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                          RouteKeys.VIEW_PROFILE,
                          arguments: RouteArgument(
                            param: _con.groupDetails.listOfUser[info].id,
                          ),
                        ),
                        child: circle(
                          name: _con.groupDetails.listOfUser[info].name,
                          image: _con.groupDetails.listOfUser[info].profile,
                          id: _con.groupDetails.listOfUser[info].id,
                          isGroupCreatedByYou2: isGroupCreatedByYou,
                        ),
                      ),
                    );
                  },
                )
                .values
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget containerText() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 15.0,
      ),
      child: Row(
        children: [
          participantsText(),
          wBox(15.0),
          totalParticipant(),
        ],
      ),
    );
  }

  Text participantsText() {
    return Text(
      "Participants",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget totalParticipant() {
    return CircleAvatar(
      child: Text(
        "${_con.groupDetails.listOfUser.length}",
        style: TextStyle(
          color: AppColors.PRIMARY_COLOR,
          fontWeight: FontWeight.w500,
          fontSize: 12.0,
        ),
      ),
      radius: 15.0,
      backgroundColor: Colors.white,
    );
  }

  Widget groupName(Size size) {
    return Container(
      width: size.width / 1.3,
      child: Text(
        _con.groupLabel,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        softWrap: true,
      ),
    );
  }

  Widget groupEditIcon() {
    return GestureDetector(
      onTap: () => _con.editGname(_con.groupLabel),
      child: CircleAvatar(
        backgroundColor: AppColors.PRIMARY_COLOR,
        radius: 18.0,
        child: SvgPicture.asset(
          ImagePath.PENCIL,
          height: 15.0,
          width: 15.0,
        ),
      ),
    );
  }

  Widget groupEditTextBox(Size size) {
    return Container(
      width: size.width / 1.5,
      child: TextField(
        controller: _con.groupNameController,
        onChanged: (value) => _con.groupnamevalidate(),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          isDense: true,
          prefixIcon: SvgPicture.asset(
            ImagePath.GROUPICON,
            color: AppColors.PRIMARY_COLOR,
          ),
          prefixIconConstraints: cons(),
          filled: true,
          focusedBorder: decor(
            colors: AppColors.PRIMARY_COLOR,
            width: 0.7,
          ),
          fillColor: Colors.grey[100],
          enabledBorder: decor(
            colors: AppColors.BORDER_COLOR,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget okButton() {
    return Container(
      width: 50,
      height: 50,
      child: MaterialButton(
        color: AppColors.PRIMARY_COLOR,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        onPressed: () {
          _con.groupnamevalidate();
          setState(
            () {
              _con.textBoxFlag = false;
              _con.groupLabel = _con.groupNameController.text.trim();
            },
          );
        },
        child: Text(
          "ok",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget circle(
      {String name, String image, String id, bool isGroupCreatedByYou2}) {
    Size size = MediaQuery.of(context).size;

    return Padding(
        padding: const EdgeInsets.all(7.0),
        child: Stack(children: [
          Container(
              height: 120.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  shape: BoxShape.circle),
              child: Container(
                  margin: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: CircleAvatar(
                      radius: 33.0,
                      backgroundImage: CachedNetworkImageProvider(image)))),
          Positioned(
              bottom: 0.0,
              left: 20.0,
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 12.0, color: Colors.white))),
          Positioned(
              right: 0.0,
              top: 7.0,
              height: 50.0,
              child: isGroupCreatedByYou2 == true &&
                      _con.groupDetails.createdBy == id
                  ? Text("@", style: TextStyle(color: Colors.white))
                  : isGroupCreatedByYou2 == false
                      ? Text("")
                      : SizedBox(
                          width: 25.0,
                          child: InkWell(
                              onTap: () {
                                return showDialog(
                                    context: context,
                                    useSafeArea: true,
                                    builder: (context) => AlertDialog(
                                        title: Text(
                                            "Are you sure you want to remove?"),
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0)),
                                        content: Container(
                                            height: 50,
                                            width: size.width / 1.1,
                                            child: Column(children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    yesButton(memberId: id),
                                                    noButton()
                                                  ])
                                            ]))));
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.PRIMARY_COLOR),
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Icon(Icons.close,
                                      color: AppColors.PRIMARY_COLOR,
                                      size: 15.0)))))
        ]));
  }

  MaterialButton yesLeaveButton({String groupId}) {
    return MaterialButton(
        color: AppColors.PRIMARY_COLOR,
        onPressed: () async => _con.leavePersonFromGroup(
            context: context, gId: _con.groupDetails.gid),
        elevation: 5.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        child: Text("Yes", style: TextStyle(color: Colors.white)));
  }

  MaterialButton yesButton({String memberId}) {
    return MaterialButton(
        color: AppColors.PRIMARY_COLOR,
        onPressed: () async {
          if (_con.groupDetails.listOfUser.length > 2) {
            _con.removePersonFromGroup(
                context: context, gId: _con.groupDetails.gid, mId: memberId);
          }
        },
        elevation: 5.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        child: Text("Yes", style: TextStyle(color: Colors.white)));
  }

  MaterialButton noButton() {
    return MaterialButton(
        color: AppColors.PRIMARY_COLOR,
        onPressed: () => Navigator.of(context).pop(),
        elevation: 5.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        child: Text("No", style: TextStyle(color: Colors.white)));
  }

  Widget topIcon(bool isGroupCreatedByYou) {
    return Stack(children: [
      Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: AppColors.PRIMARY_COLOR),
              shape: BoxShape.circle),
          child: CircleAvatar(
              backgroundImage: _con.flag == true && _con.file != null
                  ? FileImage(_con.file)
                  : CachedNetworkImageProvider(_con.groupDetails.gImage),
              backgroundColor: AppColors.PRIMARY_COLOR,
              radius: 60.0)),
      isGroupCreatedByYou == false
          ? Text("")
          : Positioned(
              bottom: 4.0,
              right: 4.0,
              child: InkWell(
                  onTap: () => _con.selectPhoto(),
                  child: Container(
                      padding: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        backgroundColor: AppColors.PRIMARY_COLOR,
                        radius: 20.0,
                        child: SvgPicture.asset(ImagePath.PENCIL,
                            height: 22.0, width: 22.0),
                      ))))
    ]);
  }
}
