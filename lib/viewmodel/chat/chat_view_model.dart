import 'package:chat_app/model/message.dart';

class ChatViewModel{
  final Message _message;

  ChatViewModel({required Message message}) : this._message = message;

  String get content => _message.message;
  bool get isMy => _message.isMy;
  String get createdAt => _message.createdAt;
  bool get isImage => _message.isImage;
}