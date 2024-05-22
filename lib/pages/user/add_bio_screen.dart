import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/user/add_bio_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class AddBioScreen extends StatefulWidget {
  AddBioScreen({Key key}) : super(key: key);

  @override
  _AddBioScreenState createState() => _AddBioScreenState();
}

class _AddBioScreenState extends StateMVC<AddBioScreen> {
  AddBioController _con;
  _AddBioScreenState() : super(AddBioController()) {
    _con = controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _con.scaffoldKey,
      appBar: _appBar(),
      body: Container(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hBox(20.0),
            Padding(
              padding: _con.padding,
              child: Text(
                "Add a bio to your profile",
                softWrap: true,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            hBox(10.0),
            Padding(
              padding: _con.padding,
              child: TextField(
                controller: _con.intro,
                onChanged: (_) => _con.usernamevalidate(),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Introduce yourself",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  // filled: true,
                  focusedBorder: decor(
                    colors: AppColors.PRIMARY_COLOR,
                  ),
                  errorBorder: decor(
                    colors: AppColors.PRIMARY_COLOR,
                  ),
                  focusedErrorBorder: decor(colors: AppColors.PRIMARY_COLOR),
                  fillColor: Colors.grey[140],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                    borderSide: BorderSide(
                      color: AppColors.BORDER_COLOR,
                      // color: AppColors.PRIMARY_COLOR,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            errorText(_con.introDisplay),
            hBox(25.0),
            _doneButton(),
          ],
        ),
      )),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            if (_con.isButtonLoading == false) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteKeys.BOTTOMBAR,
                (route) => false,
                arguments: RouteArgument(param: 0),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(top: 20.0, right: 20),
            child: Text(
              "Skip",
              style: TextStyle(
                color: AppColors.PRIMARY_COLOR,
              ),
            ),
          ),
        ),
      ],
    );
  }

// * Done Button
  Widget _doneButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed: _con.isButtonLoading ? null : () => _con.addBio(context),
        child: _con.isButtonLoading
            ? CircularProgressIndicator()
            : Text(
                "Done",
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
}
