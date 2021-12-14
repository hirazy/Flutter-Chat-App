class MessageChat {
  late String content;
  late bool isMy;
  late bool isImage;
  late String createdAt;

  MessageChat({required this.content, required this.isMy,
  required this.createdAt, this.isImage = false});

  MessageChat.fromJson(Map<String, dynamic> json) {
    content = json['message']  ?? "";
    isMy = json['isMy'];
    createdAt = json['createdAt'];
    isImage = json['isImage'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['isMy'] = isMy;
    return data;
  }
}

class MessageListModel{

  late String chatId;


  late List<MessageChat> messages;

  MessageListModel({required this.chatId, required this.messages});

   MessageListModel.fromJson(Map<String, dynamic> json){
    chatId = json['chatId'] ?? "";
    messages = json["messages"];
  }
}

class MessageDatabase{

  late String senderID;
  late String receiverID;
  late String content;
  late bool isImage;
  late String createAt;

  MessageDatabase({required senderID, required receiverID,
    required content, required isImage, required createAt});


}
