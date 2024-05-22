class TvShows {
  int id;
  String name;
  String releaseDate;
  String image;
  List category;
  String desc;

  TvShows(
      {this.id,
      this.name,
      this.image,
      this.releaseDate,
      this.category,
      this.desc});
}

class ViewTvShow {
  int tvShowId;
  String tvShowName;
  String tvShowImage;
  String tvShowOverview;
  List tvShowCategory;

  ViewTvShow({
    this.tvShowId,
    this.tvShowName,
    this.tvShowImage,
    this.tvShowOverview,
    this.tvShowCategory,
  });
}
