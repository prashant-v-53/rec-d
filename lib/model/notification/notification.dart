class NotificationModel {
  final String id;
  final String profileImage;
  final String title;
  final String titleImage;
  final String itemType;
  final String itemId;
  final String humanDate;
  final String userId;
  final String userName;
  final String conversationId;
  final String conversationTitle;
  final String notificationType;
  final bool isGroup;
  final bool isGroupCreatedByYou;
  bool isRequestPending;
  bool flag;

  NotificationModel(
      {this.id,
      this.title,
      this.titleImage,
      this.profileImage,
      this.itemType,
      this.itemId,
      this.humanDate,
      this.userId,
      this.userName,
      this.conversationId,
      this.conversationTitle,
      this.notificationType,
      this.isGroup,
      this.isGroupCreatedByYou,
      this.isRequestPending,
      this.flag});
}
