class ViewItem {
  final String id;
  final String name;
  final String image;
  final List bookAutherName;
  final String overview;
  final List category;
  final String str1;
  final String str2;
  final String str3;

  ViewItem({
    this.id,
    this.name,
    this.image,
    this.overview,
    this.category,
    this.bookAutherName,
    this.str1,
    this.str2,
    this.str3,
  });

  static String toModel(ViewItem viewItem) {
    return 'viewItem.({lo${viewItem.id}, lo${viewItem.name}, lo${viewItem.image}, lo${viewItem.overview}, lo${viewItem.category}, lo${viewItem.bookAutherName}, lo${viewItem.str1}, lo${viewItem.str2}, lo${viewItem.str3}, )';
  }
}
