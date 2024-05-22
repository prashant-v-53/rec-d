class BookMarkDetails {
  String id;
  String bookmarkName;
  String bookmarkImage;
  String type;
  String typeId;
  int numberOfReco;
  List recdBy;
  int totalUsers;
  String recdId;
  String recdTitle;

  BookMarkDetails({
    this.id,
    this.recdId,
    this.bookmarkName,
    this.bookmarkImage,
    this.typeId,
    this.recdBy,
    this.totalUsers,
    this.type,
    this.recdTitle,
  });
}
