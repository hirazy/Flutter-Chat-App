import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

import '../constants/constant.dart';

/// @params {senderID, receiverID, roomID, isImage, content}
/// @routes {send_message, receive_message}

class SocketHelper {
  static final shared = SocketHelper();

  static const String LOGIN = 'login';
  static const String LOGOUT = 'logout';

  static const String SEND_MESSAGE = 'send_message';
  static const String SEND_ADD_WRITING = 'add_writing';
  static const String SEND_REMOVE_WRITING = 'remove_writing';

  static const String RECEIVE_MESSAGE = 'receive_message';
  static const String RECEIVE_LOCATION = 'receive_location';
  static const String RECEIVE_SHUFFLE = 'receive_shuffle';
  static const String RECEIVE_WRITING = 'receive_writing';
  static const String RECEIVE_ADD_WRITING = 'receive_add_writing';
  static const String RECEIVE_REMOVE_WRITING = 'receive_remove_writing';

  static late IO.Socket socket;
  var id;

  void connectSocket(String? id) async {

    print("connectSocket");

    var idLogin = {"id": id};

    socket = IO.io(URL_BASE ,
        OptionBuilder().setTransports(['websocket']).build());

    if(socket.connected){
      showToast("Socket is connectiing", Colors.yellow);
    }
    else{
      socket.connect();
    }

    socket.onConnect((data) {
      /// Socket Emit ID Login Successfully
      socket.emit(LOGIN, idLogin);

      showToast("Connected OK", Colors.green);

      socket.on(RECEIVE_MESSAGE, handleReceiveMessage);
      socket.on(RECEIVE_LOCATION, handleLocationListen);
      socket.on(RECEIVE_SHUFFLE, handleShuffle);
      socket.on(RECEIVE_WRITING, handleShuffle);
      socket.on(RECEIVE_ADD_WRITING, handleAddWriting);
      socket.on(RECEIVE_REMOVE_WRITING, handleRemoveWriting);
    });
  }

  void showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: color,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }


  /// @param data{
  /// room: {
  ///  id: String,
  ///  name: String,
  ///  picture: String
  /// }
  /// message: {
  ///  senderID: String,
  ///  content: String,
  ///  isImage: bool
  /// }
  /// }
  Future<dynamic> handleReceiveMessage(dynamic data) async {

    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    //     'channelid', 'flutterfcm', 'your channel description',
    //     importance: Importance.max, priority: Priority.high);
    // var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    // var platformChannelSpecifics = new NotificationDetails(
    //     androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    //
    // await flutterLocalNotificationsPlugin.show(
    //   0,
    //   message['notification']['title'],
    //   message['notification']['body'],
    //   platformChannelSpecifics,
    //   payload: 'hello',);

    firebaseMessaging.setForegroundNotificationPresentationOptions();
  }

  /// Listen to Location updates of connected usersfrom server
  handleLocationListen(dynamic data) async {
    print(data);
  }

  /// Handle Shuffle
  handleShuffle(dynamic data) async {}

  /// Handle Add Writing
  handleAddWriting(dynamic data) async {}

  /// Handle Remove Writing
  handleRemoveWriting(dynamic data) async {

  }

  /// Logout
  void logout(){
    var data = {};

    socket.emit(LOGOUT, data);

    // socket.disconnect();
  }

  /// Send Message
  void sendMessage(
      {required String roomID,
      required String receiverID,
      required String message,
      required bool isImage}) {
    var data = {
      'roomID': roomID,
      'senderID': id,
      'receiverID': receiverID,
      'content': message,
      'isImage': isImage
    };

    socket.emit(SEND_MESSAGE, data);
  }

  /// Emit User Writing
  void addUserWriting({String? receiverID}) {
    var data = {"receiverID": receiverID};

    socket.emit(SEND_ADD_WRITING, data);
  }

  /// Emit User Remove Writing
  void removeUserWriting({String? receiverID}) {
    var data = {"receiverID": receiverID};

    socket.emit(SEND_REMOVE_WRITING, data);
  }

  void sendMessageToOfflineUser(chat) async{
    var messagePayLoad = {

    };
  }

  /// Disconnect
  void disConnect() {
    socket.disconnect();
  }
}
