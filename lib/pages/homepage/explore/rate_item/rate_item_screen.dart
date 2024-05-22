import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:recd/controller/homepage/explore/rate_item/rate_item_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/network/network_error_page.dart';
import 'package:recd/network/network_model.dart';
import 'package:recd/pages/common/common_widgets.dart';
import 'package:recd/pages/common/image_wiget.dart';

class RateItemScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  RateItemScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _RateItemScreenState createState() => _RateItemScreenState();
}

class _RateItemScreenState extends StateMVC<RateItemScreen> {
  RateItemController _con;

  _RateItemScreenState() : super(RateItemController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con
        .fetchCategory(
      widget.routeArgument.param[0],
      widget.routeArgument.param[1].toString(),
    )
        .then((value) {
      setState(() {
        _con.rateField = value;
        _con.isDataLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop("no");
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.of(context).pop("no"),
                icon: Icon(Icons.arrow_back_ios, color: Colors.white)),
            title: Text("Rate This ${widget.routeArgument.param[0]}",
                style: TextStyle(color: Colors.white, fontSize: 22.0)),
            actions: [
              InkWell(
                  onTap: () => Navigator.of(context).pop("no"),
                  child: Padding(
                      padding: const EdgeInsets.all(15.0), child: Text("Skip")))
            ],
            backgroundColor: AppColors.PRIMARY_COLOR,
            centerTitle: true,
            elevation: 0.0,
            automaticallyImplyLeading: false),
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
      ),
    );
  }

  Widget _body() {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            hBox(25.0),
            _mainImage(size),
            hBox(15.0),
            RatingBar.builder(
              itemSize: 30.0,
              initialRating: _con.count.toDouble(),
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.white,
              ),
              unratedColor: Colors.grey.withOpacity(0.5),
              onRatingUpdate: (rating) => setState(() => _con.count = rating),
            ),
            hBox(13.0),
            _con.isDataLoading
                ? CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : _con.rateField == null
                    ? commonMsgFunc("No rating found")
                    : Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: _con.rateField
                            .asMap()
                            .map(
                              (key, value) {
                                return MapEntry(
                                  key,
                                  GestureDetector(
                                    onTap: () => _con.setData(
                                        _con.rateField[key].rateStar, context),
                                    child: rateBox(
                                      title: _con.rateField[key].rateName,
                                      newvalue: int.parse(_con
                                              .rateField[key].rateStar
                                              .toString())
                                          .toDouble(),
                                    ),
                                  ),
                                );
                              },
                            )
                            .values
                            .toList()),
            hBox(15.0),
            _submitButton()
          ],
        ),
      ),
    );
  }

  Widget rateBox({String title, double newvalue}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Chip(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                5.0,
              ),
              side: (_con.count == newvalue)
                  ? BorderSide(color: AppColors.PRIMARY_COLOR)
                  : BorderSide(color: Colors.white),
            ),
            backgroundColor: (_con.count == newvalue)
                ? Colors.white
                : AppColors.PRIMARY_COLOR,
            label: Text(title,
                style: TextStyle(
                    color: (_con.count == newvalue)
                        ? AppColors.PRIMARY_COLOR
                        : Colors.white))));
  }

  Widget _mainImage(Size size) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
          boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black)],
          color: Colors.white),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Hero(
          tag: widget.routeArgument.param[2],
          child: ImageWidget(
            imageUrl: widget.routeArgument.param[2],
            width: size.width / 1.30,
            height: size.height / 2,
          ),
        ),
      ),
    );
  }

// * Create Account Button
  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed: _con.isButtonLoading
            ? null
            : () => (_con.count > 0.0)
                ? _con.addRating(
                    type: widget.routeArgument.param[0],
                    id: widget.routeArgument.param[1].toString(),
                    context: context)
                : toast("Select your choice"),
        child: _con.isButtonLoading
            ? CircularProgressIndicator(backgroundColor: AppColors.WHITE_COLOR)
            : Text("Submit",
                style:
                    TextStyle(color: AppColors.PRIMARY_COLOR, fontSize: 15.0)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        height: General.BUTTON_HEIGHT,
        minWidth: double.infinity,
        color: AppColors.WHITE_COLOR,
      ),
    );
  }
}
