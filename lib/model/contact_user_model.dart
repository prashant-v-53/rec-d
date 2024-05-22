class ContactItemModel {
  final String userid;
  final String username;
  final String name;
  final String email;
  final String profileimage;
  final List<String> groupImageList;
  final bool isGroup;
  bool flag;

  ContactItemModel({
    this.userid,
    this.username = '',
    this.name,
    this.email = '',
    this.profileimage,
    this.groupImageList,
    this.isGroup = false,
    this.flag = false,
  });
}

class GroupItemModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String image;
  final List<String> groupImageList;

  GroupItemModel({
    this.id,
    this.username = '',
    this.name,
    this.email = '',
    this.image,
    this.groupImageList,
  });
}
