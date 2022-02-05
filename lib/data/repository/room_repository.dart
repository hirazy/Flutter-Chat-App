import 'dart:convert';

import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:http/http.dart' as http;

class RoomRepository {
  static String ROUTE_GET_ROOM = "/rooms/";
  static const roomID = "61d5204483cef30016d260f6";

  static Future<dynamic> getRoomData(roomID) async {
    var header = {'Authorization': 'Bearer ' + MASTER_KEY};
    final response = await http
        .get(Uri.parse(URL_BASE + ROUTE_GET_ROOM + roomID),
        headers: header);

    if (response.statusCode == 200) {
      var room = Room.fromJson(jsonDecode(response.body));


    } else {
      print("EEEE");
      throw Exception();
    }
  }
}
