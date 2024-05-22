import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/auth/otp_verification_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/auth/pinbox_module.dart';
import 'package:recd/pages/common/common_widgets.dart';

class OtpVerificationScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  OtpVerificationScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends StateMVC<OtpVerificationScreen> {
  OtpVerificationController _con;
  _OtpVerificationScreenState() : super(OtpVerificationController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.initFunc(context);
    super.initState();
  }

  final focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              topBackButton(context),
              SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    hBox(size.height * 0.15),
                    _topIcon(),
                    hBox(30.0),
                    _verification(),
                    hBox(10.0),
                    _forgetPasswordDetail(),
                    hBox(40.0),
                    Center(
                      child: PinCodeTextField(
                        controller: _con.otpController,
                        errorBorderColor: Colors.red,
                        pinBoxColor: Colors.white,
                        pinBoxBorderWidth: 1.5,
                        pinTextStyle: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.PRIMARY_COLOR),
                        defaultBorderColor:
                            AppColors.PRIMARY_COLOR.withOpacity(0.2),
                        hasTextBorderColor: AppColors.PRIMARY_COLOR,
                        pinBoxRadius: 7.0,
                        keyboardType: TextInputType.number,
                        wrapAlignment: WrapAlignment.center,
                      ),
                    ),
                    _errorText(_con.otpError),
                    hBox(30.0),
                    _resendSection(),
                    hBox(25.0),
                    _sendButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget otpBox() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextFormField(
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.length == 1) {
              FocusNode().nextFocus();
            }
          },
          onEditingComplete: () => focus.nextFocus(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            focusedBorder: decor(colors: AppColors.PRIMARY_COLOR, width: 1.0),
            errorBorder: decor(
              colors: AppColors.PRIMARY_COLOR,
            ),
            focusedErrorBorder: decor(
              colors: AppColors.PRIMARY_COLOR,
            ),
            fillColor: Colors.grey[140],
            enabledBorder: decor(
              colors: Colors.grey[400],
              width: 1,
            ),
          ),
        ),
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

  Widget _verification() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Text(
        "Verification",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _forgetPasswordDetail() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        "Enter the 4-digit code we sent to\n${widget.routeArgument.param.toString()}",
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
        ),
      ),
    );
  }

  Widget _resendSection() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Didn't get the code?"),
          Text(
            "Resend",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.PRIMARY_COLOR,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed: _con.isButtonLoading
            ? null
            : () => _con.verify(context, widget.routeArgument.param),
        child: _con.isButtonLoading
            ? CircularProgressIndicator()
            : Text(
                "Verify",
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

  // * Coomon Border
  InputBorder decor({Color colors, double width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        10.0,
      ),
      borderSide: BorderSide(
        color: colors,
        // color: AppColors.PRIMARY_COLOR,
        width: (width == null) ? 0 : width,
      ),
    );
  }

  Widget _errorText(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            color: Colors.red,
            fontSize: 13.0,
          ),
        ),
      ),
    );
  }
}
