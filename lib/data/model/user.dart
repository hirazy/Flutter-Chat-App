import 'package:chat_app/model/room.dart';

class Person {
  String? id;
  String? email;
  String? name;
  String? picture;
  String? createdAt;

  Person(
      {required this.id,
      required this.email,
      required this.name,
      required this.picture,
      required this.createdAt});

  Person.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    picture = json['picture'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['name'] = name;
    data['picture'] = picture;
    data['createdAt'] = createdAt;
    return data;
  }
}

class UserAccount {
  String? id;
  String? email;
  String? name;
  String? picture;
  String? createdAt;

  UserAccount(
      {required this.id,
      required this.email,
      required this.name,
      required this.picture,
      required this.createdAt
      });

  UserAccount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    picture = json['picture'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['name'] = name;
    data['picture'] = picture;
    data['createdAt'] = createdAt;
    return data;
  }
}

class UserDatabase {
  late final String userID;
  late final List<Room> rooms;

  UserDatabase({required this.userID, required this.rooms});

  UserDatabase.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    rooms = json['rooms'];
  }
}

class UserResponse{
  String? token;
  UserAccount? user;

  UserResponse({ required this.token,required this.user});

  UserResponse.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = UserAccount.fromJson(json['user']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['user']  = user;
    return data;
  }
}
