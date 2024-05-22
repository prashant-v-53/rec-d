import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/auth/sign_in_controller.dart';

import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends StateMVC<SignInScreen> {
  SignInController _con;
  _SignInScreenState() : super(SignInController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.initFunc(context);
  }

  @override
  void dispose() {
    _con.disposeFunc();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _con.scaffoldKey,
          bottomNavigationBar: BottomAppBar(
              color: Colors.transparent, child: _createAccount(), elevation: 0),
          body: SafeArea(
              child: SingleChildScrollView(
                  child: Stack(children: [
            topBackButton(context),
            SizedBox(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  hBox(size.height * 0.15),
                  _topIcon(),
                  hBox(45.0),
                  _userName(),
                  errorText(_con.usernameDisplay),
                  _password(),
                  errorText(_con.passwordDisplay),
                  hBox(5.0),
                  _forgetPassword(),
                  hBox(15.0),
                  _loginButton()
                ]))
          ])))),
    );
  }

  Widget _topIcon() {
    return Image.asset(
      ImagePath.ICONPATH,
      color: AppColors.PRIMARY_COLOR,
      scale: General.SCALE_FACTOR,
    );
  }

  Widget _userName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: TextField(
        controller: _con.userName,
        focusNode: _con.usernameFN,
        textInputAction: TextInputAction.next,
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(_con.passwordFN),
        onChanged: (value) => _con.usernamevalidate(),
        decoration: InputDecoration(
          hintText: "Username or Email",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          isDense: true,
          prefixIcon: SvgPicture.asset(
            ImagePath.CONTACT,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20.0,
            maxWidth: 50.0,
          ),
          focusedBorder: decor(colors: AppColors.PRIMARY_COLOR, width: 1.0),
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

  Widget _password() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: TextField(
        obscureText: _con.obscureText,
        controller: _con.password,
        focusNode: _con.passwordFN,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          _con.passwordvalidate();
        },
        onChanged: (value) => _con.passwordvalidate(),
        decoration: InputDecoration(
          isDense: true,
          suffixIcon: InkWell(
            onTap: () => _con.viewpassword(),
            child: (_con.obscureText)
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
          ),
          hintText: "*******",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          prefixIcon: SvgPicture.asset(ImagePath.LOCK),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20.0,
            maxWidth: 50.0,
          ),
          filled: true,
          fillColor: Colors.grey[10],
          enabledBorder: decor(
            colors: AppColors.BORDER_COLOR,
            width: 1.0,
          ),
          focusedBorder: decor(
            colors: AppColors.PRIMARY_COLOR,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _forgetPassword() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RouteKeys.FORGET_PASSWORD),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30.0,
        ),
        child: Text(
          "Forgot Password?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.PRIMARY_COLOR,
            fontWeight: FontWeight.w500,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed: _con.isButtonLoading ? null : () => _con.loginUser(context),
        child: (_con.isButtonLoading)
            ? CircularProgressIndicator()
            : Text(
                "Log In",
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

  Widget _createAccount() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20.0,
        left: 15.0,
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Not registered yet?",
          ),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(RouteKeys.SIGN_UP),
            child: Text(
              "Create Account",
              style: TextStyle(color: AppColors.PRIMARY_COLOR),
            ),
          ),
        ],
      ),
    );
  }
}
