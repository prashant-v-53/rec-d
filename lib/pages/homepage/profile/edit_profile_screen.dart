import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/profile/edit_profile_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/helpers/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  EditProfileScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends StateMVC<EditProfileScreen> {
  EditProfileController _con;
  _EditProfileScreenState() : super(EditProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.fullname.text = widget.routeArgument.param[1];
    _con.emailaddress.text = widget.routeArgument.param[2];
    _con.mobilenumber.text = widget.routeArgument.param[3];
    _con.dateofbirth.text = widget.routeArgument.param[4];
    String text = widget.routeArgument.param[5].toString();
    if (text.trim().isNotEmpty) _con.bio.text = widget.routeArgument.param[5];
    _con.initFunc(context);
  }

  @override
  void dispose() {
    _con.disposeFunc();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: leadingIcon(context: context),
            backgroundColor: Colors.transparent,
            title: Text("Edit Profile",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
            automaticallyImplyLeading: false,
            centerTitle: false,
            elevation: 0.0),
        body: _body());
  }

  Widget _body() {
    return SingleChildScrollView(
        child: Column(children: [
      hBox(15.0),
      Align(
          alignment: Alignment.center,
          child: (_con.flag == true)
              ? selectedProfile()
              : Stack(children: [
                  Container(
                      height: 110.0,
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
                              color: AppColors.PRIMARY_COLOR),
                          child: Hero(
                              tag: widget.routeArgument.param[0].toString(),
                              child: CircleAvatar(
                                  radius: 40.0,
                                  backgroundImage: _con.file == null
                                      ? CachedNetworkImageProvider(widget
                                          .routeArgument.param[0]
                                          .toString())
                                      : FileImage(_con.file))))),
                  Positioned(
                      right: 4.0,
                      bottom: 0.0,
                      height: 50.0,
                      child: SizedBox(
                          width: 25.0,
                          child: GestureDetector(
                              onTap: () => _con.selectPhoto(),
                              child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.PRIMARY_COLOR),
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Icon(Icons.edit,
                                      color: AppColors.PRIMARY_COLOR,
                                      size: 15.0)))))
                ])),
      _commonText("Full Name"),
      _fullName(),
      _commonText("Email Address"),
      _emailAddress(),
      _commonText("Mobile Number"),
      _mobileNumber(),
      _commonText("Date of Birth"),
      _dob(),
      _commonText("Bio"),
      bio(),
      hBox(35.0),
      _updateProfileButton(),
      hBox(15.0)
    ]));
  }

  Widget selectedProfile() {
    return GestureDetector(
        onTap: () => _con.selectPhoto(),
        child: Stack(children: [
          Container(
            height: 110.0,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.PRIMARY_COLOR),
                shape: BoxShape.circle),
            child: Container(
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.PRIMARY_COLOR),
              child: CircleAvatar(
                radius: 40.0,
                backgroundImage: _con.file == null
                    ? AssetImage(ImagePath.ICONPATH)
                    : FileImage(
                        _con.file,
                      ),
              ),
            ),
          ),
          Positioned(
              right: 4.0,
              bottom: 0.0,
              height: 50.0,
              child: SizedBox(
                  width: 25.0,
                  child: GestureDetector(
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.PRIMARY_COLOR),
                              shape: BoxShape.circle,
                              color: Colors.white),
                          child: Icon(Icons.edit,
                              color: AppColors.PRIMARY_COLOR, size: 15.0)))))
        ]));
  }

  Widget _commonText(String title) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: EdgeInsets.all(18.0),
            child: Text(title,
                style:
                    TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500))));
  }

  // * Full Name TextBox
  Widget _fullName() {
    return Padding(
        padding: _con.textBoxPadding,
        child: TextField(
            controller: _con.fullname,
            textInputAction: TextInputAction.next,
            focusNode: _con.fullnameFN,
            onChanged: (value) => _con.fullnamevalidate(),
            cursorColor: AppColors.PRIMARY_COLOR,
            decoration:
                inputDecoration(text: "Full name", path: ImagePath.USERP)));
  }

  Widget _emailAddress() {
    return Padding(
        padding: _con.textBoxPadding,
        child: TextField(
            controller: _con.emailaddress,
            textInputAction: TextInputAction.next,
            focusNode: _con.emailAddressFN,
            onChanged: (value) => _con.emailaddressvalidate(),
            cursorColor: AppColors.PRIMARY_COLOR,
            decoration:
                inputDecoration(text: "Email Address", path: ImagePath.MAIL)));
  }

  Widget bio() {
    return Padding(
        padding: _con.textBoxPadding,
        child: TextField(
            controller: _con.bio,
            onChanged: (_) => _con.biovalidate(),
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
                hintText: "Introduce yourself",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
                focusedBorder: decor(colors: AppColors.PRIMARY_COLOR),
                errorBorder: decor(colors: AppColors.PRIMARY_COLOR),
                focusedErrorBorder: decor(colors: AppColors.PRIMARY_COLOR),
                fillColor: Colors.grey[140],
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: AppColors.BORDER_COLOR, width: 1.5)))));
  }

  Widget _mobileNumber() {
    return Padding(
        padding: _con.textBoxPadding,
        child: TextField(
            controller: _con.mobilenumber,
            textInputAction: TextInputAction.next,
            focusNode: _con.mobileNumberFN,
            onChanged: (value) => _con.mobileNumbervalidate(),
            cursorColor: AppColors.PRIMARY_COLOR,
            decoration:
                inputDecoration(text: "Mobile Number", path: ImagePath.CALL)));
  }

// * Date of Birth Select TextBox
  Widget _dob() {
    return Padding(
        padding: _con.textBoxPadding,
        child: GestureDetector(
            child: Container(
                child: TextField(
                    onTap: () => _con.selectDate(context),
                    controller: _con.dateofbirth,
                    readOnly: true,
                    decoration: InputDecoration(
                        hintText: "DOB",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 14.0),
                        isDense: true,
                        prefixIcon: SvgPicture.asset(ImagePath.CALANDER),
                        prefixIconConstraints:
                            BoxConstraints(maxHeight: 18.0, maxWidth: 50.0),
                        filled: true,
                        focusedBorder:
                            decor(colors: AppColors.PRIMARY_COLOR, width: 0.7),
                        focusedErrorBorder:
                            decor(colors: AppColors.PRIMARY_COLOR),
                        fillColor: Colors.grey[140],
                        enabledBorder: decor(
                            colors: AppColors.BORDER_COLOR, width: 1.0))))));
  }

// * Update Profile Button
  Widget _updateProfileButton() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: MaterialButton(
            disabledColor: Colors.grey,
            onPressed:
                (_con.isLoding) ? null : () => _con.updateProfile(context),
            child: _con.isLoding
                ? CircularProgressIndicator()
                : Text("Update Profile",
                    style: TextStyle(
                        color: AppColors.WHITE_COLOR, fontSize: 15.0)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            height: General.BUTTON_HEIGHT,
            minWidth: double.infinity,
            color: AppColors.PRIMARY_COLOR));
  }
}
