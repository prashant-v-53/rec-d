import 'package:flutter/material.dart';

class NetworkModel extends ChangeNotifier {
  bool connection = true;
  bool get isConnected => connection;

  void updateStatus(bool status) {
    connection = status;
    notifyListeners();
  }
}
