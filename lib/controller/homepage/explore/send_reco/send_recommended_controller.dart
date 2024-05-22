import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:recd/controller/auth/base_controller.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/repository/conversation_repo.dart';

class SendRecommendedController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  var entityType;
  var entityObject;
  var chatMap;

  Future sendRec(BuildContext context) async {
    setState(() => isLoading = true);
    Map map;
    String id;
    id = setEntityId();

    map = {
      "conversations": chatMap,
      "recd_type": "$entityType",
      "id": "$id",
    };

    Response response = await ConversationRepo.sendRec(map);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 1) {
        Navigator.of(context).pushNamedAndRemoveUntil(

          RouteKeys.BOTTOMBAR,
          (route)=>false,
          arguments: RouteArgument(
            param: 0,
          ),
        );
        toast('Sent!');
      }
      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      toast('Something went wrong');
      return null;
    }
  }

  String setEntityId() {
    if (entityType == 'Movie') {
      return '${entityObject?.movieId}';
    } else if (entityType == 'Tv Show') {
      return '${entityObject?.tvShowId}';
    } else if (entityType == 'Book') {
      return '${entityObject?.id}';
    } else if (entityType == 'Podcast') {
      return '${entityObject?.podCastId}';
    } else
      return '';
  }
}
