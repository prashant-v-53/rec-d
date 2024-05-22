class ViewMovie {
  int movieId;
  String movieName;
  String movieImage;
  String overview;
  List category;

  ViewMovie({
    this.movieId,
    this.movieName,
    this.movieImage,
    this.overview,
    this.category,
  });
}

class SeeAllData {
  final String id;
  final String title;
  final String image;
  final String desc;
  final String itemtype;
  final String releaseDate;
  final String bookPublishedDate;
  final List category;
  bool isRecdLoading;
  String recdByInfo;

  SeeAllData(
      {this.id,
      this.title,
      this.image,
      this.category,
      this.releaseDate,
      this.desc,
      this.itemtype,
      this.bookPublishedDate,
      this.isRecdLoading,
      this.recdByInfo});
}
