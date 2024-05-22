class Category {
  int categoryId;
  String categoryName;
  String categoryImage;
  String categoryGenreID;
  Category({
    this.categoryId,
    this.categoryName,
    this.categoryImage,
    this.categoryGenreID,
  });
}

class CategoryList {
  String id;
  String name;
  String image;
  String genresId;
  CategoryList({
    this.id,
    this.name,
    this.image,
    this.genresId,
  });
}

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String mobile;
  final String profile;
  final String dob;
  final String recs;
  final String friends;
  final String groups;
  final String bio;
  bool flag;
  bool isRequestPending;
  bool isRespondPending;
  bool isRequestSendedByMe;
  bool isMyFriend;

  UserModel({
    this.id,
    this.name,
    this.username,
    this.email,
    this.mobile,
    this.profile,
    this.dob,
    this.recs,
    this.friends,
    this.groups,
    this.flag,
    this.bio,
    this.isRequestPending,
    this.isRequestSendedByMe,
    this.isMyFriend,
    this.isRespondPending,
  });
}
