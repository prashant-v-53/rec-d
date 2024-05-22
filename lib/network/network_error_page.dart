import 'package:flutter/material.dart';
import 'package:recd/helpers/app_colors.dart';

class NetworkErrorPage extends StatefulWidget {
  NetworkErrorPage({Key key}) : super(key: key);

  @override
  _NetworkErrorPageState createState() => _NetworkErrorPageState();
}

class _NetworkErrorPageState extends State<NetworkErrorPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: AppColors.PRIMARY_COLOR,
              size: 70,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'No Internet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            )
          ],
        ),
        // child: Image.asset(ImagePath.NO_INTERNET),
      ),
    );
  }
}
