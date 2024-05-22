import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:recd/controller/homepage/bookmarks/create_bookmark_controller.dart';
import 'package:recd/helpers/app_colors.dart';
import 'package:recd/helpers/variable_keys.dart';
import 'package:recd/model/route_argument.dart';
import 'package:recd/pages/common/common_widgets.dart';

class CreateBookmarkScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  CreateBookmarkScreen({Key key, this.routeArgument}) : super(key: key);
  @override
  _CreateBookmarkScreenState createState() => _CreateBookmarkScreenState();
}

class _CreateBookmarkScreenState extends StateMVC<CreateBookmarkScreen> {
  CreateBookmarkController _con;
  _CreateBookmarkScreenState() : super(CreateBookmarkController()) {
    _con = controller;
  }

  // id->image->name->desc

  @override
  void initState() {
    super.initState();
    _con.iniFunc(context);

    if (widget.routeArgument != null) {
      if (widget.routeArgument.param == "create") {
        setState(() => _con.create = widget.routeArgument.param);
      } else {
        setState(() {
          _con.flag1 = true;
          _con.bookmarkId = widget.routeArgument.param[0];
          _con.listname.text = widget.routeArgument.param[2];

          _con.buttonVal = "Update";
          _con.titleVal = "Update";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(), body: _body());
  }

// * App bar
  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "${_con.titleVal} Bookmark List",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ),
      automaticallyImplyLeading: false,
      centerTitle: false,
      actions: [
        widget?.routeArgument?.param == "create" ||
                widget?.routeArgument?.param == null
            ? Container()
            : GestureDetector(
                onTap: _con.isButtonLoading
                    ? null
                    : () async {
                        var res = await deleteConfirmation(context);
                        if (res != null && res) {
                          setState(() {
                            _con.isButtonLoading = true;
                          });
                          _con
                              .removeBookMarkList(
                            context: context,
                            bookmarkId: _con.bookmarkId,
                          )
                              .then((value) {
                            setState(() {
                              _con.isButtonLoading = false;
                            });
                          });
                        }
                      },
                child: Icon(
                  Icons.delete,
                  color: AppColors.PRIMARY_COLOR,
                  size: 24.0,
                ),
              ),
        wBox(10)
      ],
    );
  }

  // * Start Body
  Widget _body() {
    return SafeArea(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              hBox(15.0),
              (_con.flag == true)
                  ? selectedProfile()
                  : (_con.flag1)
                      ? editImage()
                      : Center(
                          child: GestureDetector(
                            onTap: () => _con.selectPhoto(),
                            child: CircleAvatar(
                              backgroundColor: AppColors.PRIMARY_COLOR,
                              radius: 45,
                              child: Icon(
                                Icons.add_a_photo,
                                size: 50.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
              hBox(10.0),
              addImage(),
              hBox(20.0),
              _title("Name your list"),
              hBox(7.0),
              _listName(),
              errorText(_con.listnameDisplay),
              hBox(15.0),
              _createOrUpdateButton(),
              hBox(10.0),
              _cancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget addImage() => Center(
        child: Text(
          "Add Image",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
// * List Name TextBox
  Widget _listName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: TextField(
        focusNode: _con.nameFN,
        controller: _con.listname,
        textInputAction: TextInputAction.next,
        onChanged: (value) => _con.listNameValidate(),
        decoration: InputDecoration(
          hintText: " Enter list name",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
          ),
          isDense: true,
          focusedBorder: decor(
            colors: AppColors.PRIMARY_COLOR,
            width: 1.0,
          ),
          enabledBorder: decor(
            colors: Colors.grey[400],
            width: 1.0,
          ),
        ),
      ),
    );
  }

// * Common title for before textbox
  Widget _title(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

// * Create or Update Button
  Widget _createOrUpdateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: MaterialButton(
        disabledColor: AppColors.PRIMARY_COLOR.withOpacity(0.5),
        onPressed: _con.isButtonLoading == true
            ? null
            : () => _con.createBookmark(context),
        child: _con.isButtonLoading
            ? processing
            : Text(
                _con.buttonVal,
                style: TextStyle(
                  color: AppColors.WHITE_COLOR,
                  fontSize: 15.0,
                ),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        height: General.BUTTON_HEIGHT,
        minWidth: double.infinity,
        color: AppColors.PRIMARY_COLOR,
      ),
    );
  }

  Widget editImage() {
    return Stack(children: [
      Container(
        height: 110.0,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.PRIMARY_COLOR),
          shape: BoxShape.circle,
        ),
        child: Container(
          margin: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: AppColors.PRIMARY_COLOR),
          child: Hero(
            tag: widget.routeArgument.param[0].toString(),
            child: CircleAvatar(
              radius: 45.0,
              backgroundImage: _con.file == null
                  ? CachedNetworkImageProvider(
                      widget.routeArgument.param[1].toString())
                  : FileImage(_con.file),
            ),
          ),
        ),
      ),
      Positioned(
        right: 4.0,
        bottom: 0.0,
        height: 50.0,
        child: SizedBox(
          width: 25.0,
          child: GestureDetector(
            onTap: () => _con.selectPhoto(),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.PRIMARY_COLOR),
                  shape: BoxShape.circle,
                  color: Colors.white),
              child: Icon(
                Icons.edit,
                color: AppColors.PRIMARY_COLOR,
                size: 15.0,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

// * Cancel Button
  Widget _cancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MaterialButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          "Cancel",
          style: TextStyle(
            color: AppColors.PRIMARY_COLOR,
            fontSize: 15.0,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
        ),
        height: 45.0,
        color: Colors.transparent,
      ),
    );
  }

  Widget selectedProfile() {
    return GestureDetector(
      onTap: () => _con.selectPhoto(),
      child: Stack(
        children: [
          Container(
            height: 110.0,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.PRIMARY_COLOR),
                shape: BoxShape.circle),
            child: Container(
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.PRIMARY_COLOR),
              child: CircleAvatar(
                radius: 45.0,
                backgroundImage: _con.file == null
                    ? AssetImage(ImagePath.ICONPATH)
                    : FileImage(_con.file),
              ),
            ),
          ),
          Positioned(
            right: 4.0,
            bottom: 0.0,
            height: 50.0,
            child: SizedBox(
              width: 25.0,
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.PRIMARY_COLOR),
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppColors.PRIMARY_COLOR,
                    size: 15.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
