class ConversationModel {
  final String id;
  final String userId;
  final String title;
  final bool isGroup;
  final String conImage;
  final String lastMsgImage;
  final String lastMsgTitle;
  final String lastMsgSubTitle;
  final String userName;
  final String humanDate;
  final List recdBy;
  final bool isGroupCreatedByYou;
  final int totalUsers;
  final String itemId;
  final String itemType;

  ConversationModel({
    this.id,
    this.userId,
    this.title,
    this.isGroup,
    this.conImage,
    this.lastMsgImage,
    this.lastMsgTitle,
    this.lastMsgSubTitle,
    this.humanDate,
    this.userName,
    this.recdBy,
    this.isGroupCreatedByYou,
    this.totalUsers,
    this.itemId,
    this.itemType,
  });
}

class RecsDetailsModel {
  final String id;
  final String title;
  final String image;
  final String subtitle;
  final String humanDate;
  final String itemId;
  final String itemType;
  final List recipientList;
  final int totalReco;

  RecsDetailsModel({
    this.id,
    this.title,
    this.humanDate,
    this.image,
    this.recipientList,
    this.subtitle,
    this.itemId,
    this.itemType,
    this.totalReco,
  });
}

class RelatedRecsModel {
  final String id;
  final String title;
  final String image;
  final String humanDate;
  final int totalReco;
  RelatedRecsModel({
    this.id,
    this.title,
    this.humanDate,
    this.image,
    this.totalReco,
  });
}
