import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/auth/forget_password_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';

class ForgetPasswordScreen extends StatefulWidget {
  ForgetPasswordScreen({Key key}) : super(key: key);

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends StateMVC<ForgetPasswordScreen> {
  ForgetPasswordController _con;
  _ForgetPasswordScreenState() : super(ForgetPasswordController()) {
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
            alignment: Alignment.center,
            children: [
              topBackButton(context),
              SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    hBox(size.height * 0.10),
                    _topIcon(),
                    hBox(15.0),
                    _forgetPassword(),
                    hBox(7.0),
                    _forgetPasswordDetail(),
                    hBox(35.0),
                    _lockImage(),
                    hBox(40.0),
                    _emailAddress(),
                    errorText(_con.emailaddressDisplay),
                    // _orSection(),
                    // hBox(22.0),
                    // _phoneNumberButton(),
                    // errorText(_con.phonenumberDisplay),
                    hBox(20.0),
                    _sendButton(),
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
      scale: 2.5,
    );
  }

  Widget _forgetPassword() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Text(
        "Forgot Password?",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 25.0,
        ),
      ),
    );
  }

  Widget _forgetPasswordDetail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Text(
        "Enter your phone number or email address and we’ll send you a code to reset your password",
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
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
        ImagePath.PASSWORDICON,
        height: 70.0,
        width: 70.0,
      ),
    );
  }

  Widget _emailAddress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        controller: _con.emailaddress,
        onChanged: (value) => _con.emailAddrerssValidate(),
        decoration: InputDecoration(
          hintText: "Enter email address",
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

  // ignore: unused_element
  Widget _phoneNumberButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        controller: _con.phonenumber,
        onChanged: (value) => _con.phoneNumberValidate(),
        keyboardType: TextInputType.phone,
        decoration: inputDecoration(
          path: ImagePath.CALL,
          text: "Enter phone number",
        ),
      ),
    );
  }

  Widget _sendButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed: _con.isButtonLoading ? null : () => _con.sendMail(context),
        child: _con.isButtonLoading
            ? CircularProgressIndicator()
            : Text(
                "Send",
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

//* Or text with Divider
  // ignore: unused_element
  Widget _orSection() {
    return Container(
      height: 15.0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              height: 0.5,
              color: AppColors.PRIMARY_COLOR,
            ),
          ),
          Text(
            "OR",
            style: TextStyle(color: AppColors.PRIMARY_COLOR, fontSize: 12.0),
          ),
          Expanded(
            child: new Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              height: 0.5,
              color: AppColors.PRIMARY_COLOR,
            ),
          ),
        ],
      ),
    );
  }
}
