import 'package:chat_app/data/db/room_database_helper.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:flutter/material.dart';

class RoomProvider with ChangeNotifier {
  List<RoomDB> _items = [];

  List<RoomDB> get items => [..._items];

  Future fetchAllRoom() async {
    _items = (await RoomDatabaseHelper.instance.getAllRecords()).cast<RoomDB>();

    notifyListeners();
  }

  Future fetchRoom(String id) async {}

  Future update(RoomDB room) async {
    final index = _items.indexWhere((e) => e.id == room.id);
    if (index != -1) {
      _items[index] = room;
      notifyListeners();

      await RoomDatabaseHelper.instance.updateRecord(room);
    }
  }

  Future delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await RoomDatabaseHelper.instance.delete(id);
  }

  Future deleteAll() async {
    _items.clear();
    notifyListeners();
    await RoomDatabaseHelper.instance.deleteAll();
  }
}
