class RelatedRecs {
  final String recId;
  final List<dynamic> recdUser;
  final int totalRecs;
  bool isLoading;

  RelatedRecs({
    this.recId,
    this.recdUser,
    this.totalRecs,
    this.isLoading,
  });
}
