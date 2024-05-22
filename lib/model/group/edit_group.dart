import 'package:recd/model/category_model.dart';

class EditGroup {
  final String gid;
  final String gName;
  final String gImage;
  final List<UserModel> listOfUser;
  final String createdBy;
  final bool isGroupCreatedByYou;

  EditGroup(
      {this.gid,
      this.gName,
      this.gImage,
      this.listOfUser,
      this.createdBy,
      this.isGroupCreatedByYou});
}
