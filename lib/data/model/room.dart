import 'package:chat_app/model/user.dart';

import 'message.dart';

class Room{
  late String id;
  late List<MessageDatabase> messages;
  late List<Person> persons;

  Room(this.id, this.messages, this.persons,);

  Room.fromJson(Map<String, dynamic> json){
    id = json['id'];
    messages = json['messages'];
    persons = json['persons'];
  }

  // Map<String, dynamic> toJson(){
  //   Map<String, dynamic> data = <String, dynamic>();
  // }
}