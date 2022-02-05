import 'package:chat_app/data/model/message.dart';

class ChatViewModel{
  final MessageChat _message;

  ChatViewModel({required MessageChat message}) : this._message = message;

  String get content => _message.content;
  bool get isMy => _message.isMy;
  String get createdAt => _message.createdAt;
  bool get isImage => _message.isImage;
}