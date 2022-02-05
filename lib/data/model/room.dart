
import 'dart:convert';
import 'dart:math';

import 'message.dart';

const roomTable = 'room_table';

class RoomField{
  static const String id = 'id';
  static const String name = 'name';
  static const String picture = 'picture';
  static const String messages = 'messages';
  static const String users = 'users';
  static const String isSeen = 'isSeen';
  static const String createdTime = 'createdTime';
  static const String updatedTime = 'updatedTime';
}

class Room {
  late String id;
  late String name;
  late List<MessageRoom> messages;
  late List<String> users;
  late String picture;

  Room(
      {required this.name,
      required this.messages,
      required this.users,
      required this.picture});

  Room.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    List<dynamic> list = json['messages'];
    messages = list.map((data) => MessageRoom.fromJson(data)).toList();
    users = List<String>.from(json['users']).cast<String>();
    picture = json['picture'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = id;
    data['messages'] = messages;
    data['users'] = users;
    data['name'] = name;
    data['picture'] = picture;
    return data;
  }
}

class RoomShuffle {
  late String name;
  late String id;
  late String recentMessage;
  late String picture;
  late bool isSeen;

  RoomShuffle(
      {required this.name,
      required this.id,
      required this.recentMessage,
      required this.picture,
      required this.isSeen});

  RoomShuffle.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    recentMessage = json['recentMessage'];
    picture = json['picture'];
    isSeen = json['isSeen'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['recentMessage'] = recentMessage;
    data['picture'] = picture;
    data['isSeen'] = isSeen;
    return data;
  }
}

class RoomDB{
  late String id;
  late String name;
  late String picture;
  late List<MessageRoom> messages; /// Save by JSON Text in DB
  late List<String> users;  /// Save by JSON Text in DB
  late bool isSeen;
  late DateTime createdTime;
  late DateTime updatedTimed;


  RoomDB({required this.id,
          required this.name,
          required this.picture,
          required this.messages,
          required this.users,
          required this.isSeen,
          required this.createdTime,
          required this.updatedTimed
  });


  /// Get from DB
  RoomDB.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    picture = json['picture'];
    users = List<String>.from(jsonDecode(json['users'])).cast<String>();
    List<dynamic> listMessages = jsonDecode(json['messages']);
    messages = listMessages.map((data) => MessageRoom.fromJson(data)).toList();
    isSeen = json['isSeen'];
  }

  /// Convert to Map to save to DB
  Map<String, Object?> toJson() => {
    RoomField.id: id,
    RoomField.name: name,
    RoomField.users: jsonEncode(users),
    RoomField.messages: jsonEncode(messages),
    RoomField.picture: picture,
    RoomField.isSeen: isSeen,
    RoomField.createdTime: createdTime,
    RoomField.updatedTime: updatedTimed
  };
}