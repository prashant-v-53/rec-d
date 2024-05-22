import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/auth/sign_up_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends StateMVC<SignUpScreen> {
  SignUpController _con;
  _SignUpScreenState() : super(SignUpController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.initFunc(context);
    super.initState();
  }

  @override
  void dispose() {
    _con.disposeFunc();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      key: _con.scaffoldKey,
      bottomNavigationBar: BottomAppBar(
        child: _logIn(),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              topBackButton(context),
              SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    hBox(size.height * 0.09),
                    _topIcon(),
                    hBox(20.0),
                    _fullName(),
                    errorText(_con.fullnameDisplay),
                    _userName(),
                    errorText(_con.usernameDisplay),
                    _emailAddress(),
                    errorText(_con.emailaddressDisplay),
                    _mobileNumber(),
                    errorText(_con.mobileNumberDisplay),
                    _password(),
                    errorText(_con.passwordDisplay),
                    _dob(),
                    errorText(_con.dateofbirthDisplay),
                    _createAccountButton(),
                    hBox(15.0),
                    // orSection(),
                    // hBox(15.0),
                    // _connectGoogle(),
                    hBox(20.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // * Top Logo
  Widget _topIcon() {
    return Image.asset(
      ImagePath.ICONPATH,
      color: AppColors.PRIMARY_COLOR,
      scale: General.SCALE_FACTOR,
    );
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
        decoration: inputDecoration(
          text: "Full name",
          path: ImagePath.USERP,
        ),
      ),
    );
  }

// * Username TextBox
  Widget _userName() {
    return Padding(
      padding: _con.textBoxPadding,
      child: TextField(
        controller: _con.userName,
        textInputAction: TextInputAction.next,
        focusNode: _con.usernameFN,
        onChanged: (value) => _con.usernamevalidate(),
        cursorColor: AppColors.PRIMARY_COLOR,
        decoration: inputDecoration(
          text: "Username",
          path: ImagePath.CONTACT,
        ),
      ),
    );
  }

// * Email Address TextBox
  Widget _emailAddress() {
    return Padding(
      padding: _con.textBoxPadding,
      child: TextField(
        controller: _con.emailaddress,
        textInputAction: TextInputAction.next,
        focusNode: _con.emailAddressFN,
        onChanged: (value) => _con.emailaddressvalidate(),
        cursorColor: AppColors.PRIMARY_COLOR,
        decoration: InputDecoration(
          hintText: "Email address",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          isDense: true,
          prefixIcon: SvgPicture.asset(ImagePath.MAIL),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 15.0,
            maxWidth: 50.0,
          ),
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

// * Email Address TextBox
  Widget _mobileNumber() {
    return Padding(
      padding: _con.textBoxPadding,
      child: TextField(
        controller: _con.mobilenumber,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        focusNode: _con.mobileNumberFN,
        onChanged: (value) => _con.mobileNumbervalidate(),
        cursorColor: AppColors.PRIMARY_COLOR,
        decoration: InputDecoration(
          hintText: "Mobile number",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          isDense: true,
          prefixIcon: SvgPicture.asset(ImagePath.CALL),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 15.0,
            maxWidth: 50.0,
          ),
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

// * Password TextBox
  Widget _password() {
    return Padding(
      padding: _con.textBoxPadding,
      child: TextField(
        controller: _con.password,
        textInputAction: TextInputAction.next,
        focusNode: _con.passwordFN,
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(_con.dateofbirthFN),
        onChanged: (value) => _con.passwordvalidate(),
        obscureText: _con.obscureText,
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
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
          isDense: true,
          prefixIcon: SvgPicture.asset(ImagePath.LOCK),
          prefixIconConstraints: cons(),
          filled: true,
          focusedBorder: decor(colors: AppColors.PRIMARY_COLOR, width: 0.7),
          fillColor: Colors.grey[140],
          enabledBorder: decor(
            colors: AppColors.BORDER_COLOR,
            width: 1.0,
          ),
        ),
      ),
    );
  }

// * Date of Birth Select TextBox
  Widget _dob() {
    return Padding(
      padding: _con.textBoxPadding,
      child: GestureDetector(
        // onTap: () => _con.selectDate(context),
        child: Container(
          child: TextField(
            onTap: () => _con.selectDate(context),
            controller: _con.dateofbirth,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "DOB",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              isDense: true,
              prefixIcon: SvgPicture.asset(ImagePath.CALANDER),
              prefixIconConstraints: BoxConstraints(
                maxHeight: 18.0,
                maxWidth: 50.0,
              ),
              filled: true,
              focusedBorder: decor(colors: AppColors.PRIMARY_COLOR, width: 0.7),
              focusedErrorBorder: decor(
                colors: AppColors.PRIMARY_COLOR,
              ),
              fillColor: Colors.grey[140],
              enabledBorder: decor(
                colors: AppColors.BORDER_COLOR,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

// * Create Account Button
  Widget _createAccountButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed: (_con.isLoding) ? null : () => _con.singup(context),
        child: (_con.isLoding)
            ? CircularProgressIndicator()
            : Text(
                "Create Account",
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

  // * Log In Button
  Widget _logIn() {
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
            "Already have an account?",
          ),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(RouteKeys.SIGN_IN),
            child: Text(
              "Log In",
              style: TextStyle(color: AppColors.PRIMARY_COLOR),
            ),
          ),
        ],
      ),
    );
  }
}
