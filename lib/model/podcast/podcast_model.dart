class PodcastModel {
  String podCastId;
  String podCastName;
  String podCastImage;
  List category;
  String publisher;

  PodcastModel(
      {this.podCastId,
      this.podCastName,
      this.podCastImage,
      this.category,
      this.publisher});
}

class ViewPodCast {
  String podCastId;
  String podCastName;
  String podCastImage;
  String podCastOverview;
  List podCastCategory;

  ViewPodCast({
    this.podCastId,
    this.podCastName,
    this.podCastImage,
    this.podCastOverview,
    this.podCastCategory,
  });
}
