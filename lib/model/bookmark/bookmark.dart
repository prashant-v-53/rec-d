class Bookmark {
  String bookmarkId;
  String bookmarkName;
  String bookmarkImg;

  List numberOfReco;

  Bookmark({
    this.bookmarkId,
    this.bookmarkName,
    this.numberOfReco,
    this.bookmarkImg,
  });
}

class BookmarkList {
  String bookmarkId;
  String bookmarkTitle;
  String bookmarkDesc;
  bool isBookmarked;
  BookmarkList(
      {this.bookmarkId,
      this.bookmarkTitle,
      this.bookmarkDesc,
      this.isBookmarked});
}
