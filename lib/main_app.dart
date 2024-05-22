import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/app_config.dart';
import 'package:recd/helpers/variable_keys.dart';

import 'package:recd/route_generator.dart';

class MainApp extends StatefulWidget {
  MainApp({Key key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BaseController.initializeMainApp(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: App.appName,
      initialRoute: RouteKeys.SPLASH,
      onGenerateRoute: RouteGenrator.generateRoute,
      theme: ThemeData(
        fontFamily: 'Poppins',
        accentColor: AppColors.PRIMARY_COLOR,
        primaryColor: AppColors.PRIMARY_COLOR,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          brightness: Brightness.light,
        ),
      ),
    );
  }
}
