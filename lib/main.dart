import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recd/listner/notification_listner.dart';
import 'package:recd/main_app.dart';
import 'package:recd/network/network_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NListner>(create: (context) => NListner()),
        ChangeNotifierProvider(create: (context) => NetworkModel())
      ],
      child: MainApp(),
    ),
  );
}
