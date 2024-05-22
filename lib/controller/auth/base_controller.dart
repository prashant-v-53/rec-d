import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/network/data_connection_checker.dart';
import 'package:recd/network/network_model.dart';

class BaseController extends ControllerMVC {
  static initializeMainApp(BuildContext context) {
    DataConnectivityService()
        .connectivityStreamController
        .stream
        .listen((event) {
      if (event == DataConnectionStatus.disconnected) {
        Provider.of<NetworkModel>(context, listen: false).updateStatus(false);
      } else {
        Provider.of<NetworkModel>(context, listen: false).updateStatus(true);
      }
    });
  }
}
