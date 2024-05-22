class RateField {
  final String rateId;
  final String rateName;
  final String rateStar;
  final bool isSelected;

  RateField({
    this.rateId,
    this.rateName,
    this.rateStar,
    this.isSelected,
  });
}

class RateDetails {
  final String id;
  final String name;
  final String totalRating;
  final String updatedDate;
  final String profileImage;
  final String userId;

  RateDetails(
      {this.id,
      this.name,
      this.totalRating,
      this.updatedDate,
      this.profileImage,
      this.userId});
}
