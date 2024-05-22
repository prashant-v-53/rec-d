import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class SignInUpSelection extends StatefulWidget {
  SignInUpSelection({Key key}) : super(key: key);

  @override
  _SignInUpSelectionState createState() => _SignInUpSelectionState();
}

class _SignInUpSelectionState extends State<SignInUpSelection> {
  @override
  void initState() {
    super.initState();
    _askPermissions().then((value) {
      // _getNotification();
    });
  }

  Future<void> _askPermissions() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text('Permissions error'),
          content: Text('Please enable contacts access '
              'permission in system settings'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }

  
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;

    
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return WillPopScope(
          onWillPop: () => SystemNavigator.pop(), child: scaffold());
    } else {
      return scaffold();
    }
  }

  Widget scaffold() {
    return Scaffold(
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.WHITE_COLOR,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _topIcon(),
              _topText(),
              _loginButton(),
              hBox(7.0),
              _signupButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topIcon() {
    return Image.asset(
      ImagePath.ICONPATH,
      color: AppColors.PRIMARY_COLOR,
      scale: General.SCALE_FACTOR,
    );
  }

  Widget _topText() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 15.0,
      ),
      child: Text(
        "Recommendations from the people who know you best",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: MaterialButton(
        onPressed: () => Navigator.of(context).pushNamed(RouteKeys.SIGN_IN),
        child: Text(
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

  Widget _signupButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: MaterialButton(
        onPressed: () => Navigator.of(context).pushNamed(RouteKeys.SIGN_UP),
        child: Text(
          "Sign Up",
          style: TextStyle(
            color: AppColors.PRIMARY_COLOR,
            fontSize: 15.0,
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25.0,
            ),
            side: BorderSide(color: AppColors.PRIMARY_COLOR, width: 1.0)),
        height: General.BUTTON_HEIGHT,
        minWidth: double.infinity,
      ),
    );
  }
}
