import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/user/select_profile_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/pages/common/common_widgets.dart';

class SelectProfileScreen extends StatefulWidget {
  @override
  _SelectProfileScreenState createState() => _SelectProfileScreenState();
}

class _SelectProfileScreenState extends StateMVC<SelectProfileScreen> {
  SelectProfileController _con;
  _SelectProfileScreenState() : super(SelectProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.initFunc(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _con.scaffoldKey,
      appBar: _appBar(),
      body: Form(
        key: _con.formKey,
        child: Container(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hBox(20.0),
              Padding(
                padding: _con.padding,
                child: Text(
                  "Add a profile photo",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              hBox(30.0),
              (_con.flag == true)
                  ? selectedProfile()
                  : Center(
                      child: GestureDetector(
                        onTap: () => _con.selectPhoto(),
                        child: CircleAvatar(
                          backgroundColor: AppColors.PRIMARY_COLOR,
                          radius: 55,
                          child: Icon(
                            Icons.add_a_photo,
                            size: 50.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              hBox(15.0),
              _errorText(_con.profileError),
              Center(
                child: Padding(
                  padding: _con.padding,
                  child: Text(
                    "Upload Profile Photo",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
                  ),
                ),
              ),
              hBox(25.0),
              _nextButton(),
            ],
          ),
        )),
      ),
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
              Navigator.of(context).pushNamed(RouteKeys.ADD_BIO);
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

// * Create Account Button
  Widget _nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        onPressed:
            _con.isButtonLoading ? null : () => _con.uploadProfile(context),
        child: _con.isButtonLoading
            ? CircularProgressIndicator()
            : Text(
                "Next",
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

  Widget selectedProfile() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Center(
        child: Stack(
          children: [
            Container(
              height: 120.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.PRIMARY_COLOR,
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.PRIMARY_COLOR,
                ),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: _con.file == null
                      ? AssetImage(ImagePath.ICONPATH)
                      : FileImage(_con.file),
                ),
              ),
            ),
            Positioned(
              right: 4.0,
              top: -5.0,
              height: 50.0,
              child: SizedBox(
                width: 25.0,
                child: GestureDetector(
                  onTap: () => _con.setFlag(),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.PRIMARY_COLOR,
                      ),
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.PRIMARY_COLOR,
                      size: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// * Error text after textbox
  Widget _errorText(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            color: Colors.red,
            fontSize: 13.0,
          ),
        ),
      ),
    );
  }
}
