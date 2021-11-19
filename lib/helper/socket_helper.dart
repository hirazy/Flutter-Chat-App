import 'package:chat_app/helper/shared_preferences.dart';
import 'package:chat_app/helper/stream_controller_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketHelper {
  static final shared = SocketHelper();

  late IO.Socket socket;
  var id;

  void connectSocket() async {
    id = SharedPreferencesHelper.shared.getMyID();

    socket = IO.io('http://10.0.2.2:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (data) {
      socket.emit('chatID', {'id': id});

      socket.on('receive_message', (data) {
        var content = data['content'].toString();
        var isImage = data['isImage'] as bool;

        // StreamControllerHelper.shared.setLastIndex();

      });
      
      socket.on('onlineUsers', (data) {
        var list = List<String>.from(data['users']);

      });

      socket.on('writingListener', (data){

      });

    });
  }

  void sendMessage({required String receiver,required String message, required bool isImage}) {
    socket.emit('send_message', {
      'senderChatID': id,
      'receiverChatID': receiver,
      'content': message,
      'isImage': isImage
    });
  }

  void addUserWriting({String? receiver}) {
    socket.emit('addWriting', {
      "id": id,
      "to": receiver
    });
  }

  void removeUserWriting({String? receiver}) {
    socket.emit('removeWriting', {
      "id": id,
      "to": receiver
    });
  }
}
