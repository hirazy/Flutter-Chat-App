class Message {
  late String message;
  late bool isMy;
  late bool isImage;
  late String createdAt;

  Message({required this.message, required this.isMy,
  required this.createdAt, this.isImage = false});

  Message.fromJson(Map<String, dynamic> json) {
    message = json['message']  ?? "";
    isMy = json['isMy'];
    createdAt = json['createdAt'];
    isImage = json['isImage'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['isMy'] = isMy;
    return data;
  }
}

class MessageListModel{
  late String chatId;

  late List<Message> messages;

  MessageListModel({required this.chatId, required this.messages});

   MessageListModel.fromJson(Map<String, dynamic> json){
    chatId = json['chatId'] ?? "";
    messages = json["messages"];
  }
}
