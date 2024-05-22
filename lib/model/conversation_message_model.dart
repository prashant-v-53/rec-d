class ConversationMessageModel {
  final String id;
  final String image;
  final String msgTitle;
  final String msgSubTitle;
  final String msgStarCount;
  final String msgTime;
  final String msgImage;
  final bool isMyMsg;
  final String username;
  final String userId;
  final dynamic avgRating;

  final String itemType;
  final String itemId;
  ConversationMessageModel({
    this.id,
    this.image,
    this.msgTitle,
    this.msgSubTitle,
    this.msgStarCount,
    this.msgTime,
    this.isMyMsg,
    this.msgImage,
    this.username,
    this.avgRating,
    this.userId,
    this.itemType,
    this.itemId,
  });
}
