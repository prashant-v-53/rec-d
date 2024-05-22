import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/explore/send_reco/send_recommended_controller.dart';
import 'package:recd/elements/helper.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';

class SendRecommendationScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  SendRecommendationScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _SendRecommendationScreenState createState() =>
      _SendRecommendationScreenState();
}

class _SendRecommendationScreenState
    extends StateMVC<SendRecommendationScreen> {
  SendRecommendedController _con;
  _SendRecommendationScreenState() : super(SendRecommendedController()) {
    _con = controller;
  }
  @override
  void initState() {
    _con.entityType = widget.routeArgument.param[0];
    _con.entityObject = widget.routeArgument.param[1];
    _con.chatMap = widget.routeArgument.param[2];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          displayTitle(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
          ),
        ),
        backgroundColor: AppColors.PRIMARY_COLOR,
        centerTitle: false,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.PRIMARY_COLOR,
      body: Consumer<NetworkModel>(
        builder: (context, value, child) {
          if (value.connection) {
            return _body();
          } else {
            return NetworkErrorPage();
          }
        },
      ),
    );
  }

  Widget _body() {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            hBox(22.0),
            _mainImage(size),
            hBox(22.0),
            _sendREC(),
            _cancel(size),
          ],
        ),
      ),
    );
  }

  Widget _mainImage(Size size) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
        child: ImageWidget(
          imageUrl: displayImg(),
          width: size.width / 1.30,
          height: size.height / 1.70,
        ),
      ),
    );
  }

  Widget _sendREC() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed: _con.isLoading ? null : () => _con.sendRec(context),
        child: _con.isLoading
            ? CircularProgressIndicator()
            : Text(
                "Send REC",
                style: TextStyle(
                  color: AppColors.PRIMARY_COLOR,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            25.0,
          ),
        ),
        height: General.BUTTON_HEIGHT,
        minWidth: double.infinity,
        color: AppColors.WHITE_COLOR,
      ),
    );
  }

  Widget _cancel(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: MaterialButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          "Cancel",
          style: TextStyle(
            color: AppColors.WHITE_COLOR,
            fontSize: 15.0,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
        ),
        height: General.BUTTON_HEIGHT,
        minWidth: size.width / 3,
      ),
    );
  }

  String displayTitle() {
    if (_con.entityType == 'Movie') {
      return '${_con?.entityObject?.movieName}';
    } else if (_con.entityType == 'Tv Show') {
      return '${_con?.entityObject?.tvShowName}';
    } else if (_con.entityType == 'Book') {
      return '${_con?.entityObject?.title}';
    } else if (_con.entityType == 'Podcast') {
      return '${_con?.entityObject?.podCastName}';
    } else
      return '';
  }

  String displayImg() {
    if (_con.entityType == 'Movie') {
      if (_con?.entityObject?.movieImage.toString().contains('https'))
        return '${_con?.entityObject?.movieImage}';
      else
        return '${Global.tmdbImgBaseUrl}${_con?.entityObject?.movieImage}';
    } else if (_con.entityType == 'Tv Show') {
      if (_con?.entityObject?.tvShowImage.toString().contains('https'))
        return '${_con?.entityObject?.tvShowImage}';
      else
        return '${Global.tmdbImgBaseUrl}${_con?.entityObject?.tvShowImage}';
    } else if (_con.entityType == 'Book') {
      return '${_con?.entityObject?.image}';
    } else if (_con.entityType == 'Podcast') {
      return '${_con?.entityObject?.podCastImage}';
    } else
      return '';
  }
}
