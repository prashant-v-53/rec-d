import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/auth/reset_password_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  ResetPasswordScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends StateMVC<ResetPasswordScreen> {
  ResetPasswordController _con;
  _ResetPasswordScreenState() : super(ResetPasswordController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.initFunc(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _con.scaffoldKey,
      body: SafeArea(
        child: Container(
            child: SingleChildScrollView(
          child: Stack(
            children: [
              topBackButton(context),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    hBox(size.height * 0.13),
                    _topIcon(),
                    hBox(20.0),
                    _forgetPassword(),
                    hBox(10.0),
                    _forgetPasswordDetail(),
                    hBox(35.0),
                    _lockImage(),
                    hBox(35.0),
                    _newPassword(),
                    errorText(_con.newPasswordDisplay),
                    _reEnterPasswordButton(),
                    errorText(_con.reenterPasswordDisplay),
                    hBox(25.0),
                    _updatePasswordButton(),
                    hBox(40.0),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _topIcon() {
    return Image.asset(
      ImagePath.ICONPATH,
      color: AppColors.PRIMARY_COLOR,
      scale: 2.2,
    );
  }

  Widget _forgetPassword() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Text(
        "Reset your password",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.black, fontSize: 25.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _forgetPasswordDetail() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        "Please enter a new password",
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          // fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      ),
    );
  }

  Widget _lockImage() {
    return CircleAvatar(
      radius: 55.0,
      backgroundColor: AppColors.PRIMARY_COLOR,
      child: SvgPicture.asset(
        ImagePath.SMARTKEYICON,
        height: 70.0,
        width: 70.0,
      ),
    );
  }

  Widget _newPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        controller: _con.newpassword,
        onChanged: (value) => _con.newPasswordValidate(),
        focusNode: _con.newpasswordFN,
        obscureText: _con.obscureText1,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          suffixIcon: InkWell(
            onTap: () => _con.viewpassword1(),
            child: (_con.obscureText1)
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
          ),
          hintText: "New Password",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          isDense: true,
          prefixIcon: SvgPicture.asset(ImagePath.LOCK),
          prefixIconConstraints: cons(),
          focusedBorder: decor(
            colors: AppColors.PRIMARY_COLOR,
            width: 0.7,
          ),
          filled: true,
          fillColor: Colors.grey[140],
          enabledBorder: decor(
            colors: AppColors.BORDER_COLOR,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _reEnterPasswordButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: TextField(
        controller: _con.reenterPassword,
        focusNode: _con.reenterPasswordFN,
        textInputAction: TextInputAction.next,
        onChanged: (value) => _con.reEnterPasswordValidate(),
        obscureText: _con.obscureText,
        decoration: InputDecoration(
          suffixIcon: InkWell(
            onTap: () => _con.viewpassword(),
            child: (_con.obscureText)
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
          ),
          hintText: "Re-enter password",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          isDense: true,
          prefixIcon: SvgPicture.asset(ImagePath.LOCK),
          prefixIconConstraints: cons(),
          focusedBorder: decor(
            colors: AppColors.PRIMARY_COLOR,
            width: 0.7,
          ),
          filled: true,
          fillColor: Colors.grey[140],
          enabledBorder: decor(
            colors: AppColors.BORDER_COLOR,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _updatePasswordButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed: _con.isButtonLoading
            ? null
            : () => _con.updatePassword(context, widget.routeArgument.param),
        child: _con.isButtonLoading
            ? CircularProgressIndicator()
            : Text(
                "Update Password",
                style: TextStyle(
                  color: AppColors.WHITE_COLOR,
                  fontSize: 15.0,
                ),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            25.0,
          ),
        ),
        height: General.BUTTON_HEIGHT,
        minWidth: double.infinity,
        color: AppColors.PRIMARY_COLOR,
      ),
    );
  }
}
