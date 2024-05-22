import 'package:flutter/material.dart';

class NListner extends ChangeNotifier {
  int nBadge = 0;

  int get getNBadge => nBadge;

  set setNBadge(int nBadge) => this.nBadge = nBadge;
  void updateStatus(int numberBadge) {
    nBadge = numberBadge;
    notifyListeners();
  }
}
