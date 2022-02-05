import 'package:chat_app/data/model/room.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class RoomDatabaseHelper{
  static final RoomDatabaseHelper instance = RoomDatabaseHelper._init();
  RoomDatabaseHelper._init();

  Future<List<RoomDB>> getAllRecords() async{
    final db = await DatabaseHelper.instance.database;

    //final records = await db!.query(
    //   labelTable,
    //   orderBy: '${LabelField.id} DESC',
    // );
    //
    // return records.map((e) => Label.fromJson(e)).toList();
    return [];
  }

  /// Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getRoomMapList() async {
    final db = await DatabaseHelper.instance.database;

    var result = await db!.query(roomTable, orderBy: '${RoomField.updatedTime} ASC');
    return result;
  }

  /// Insert Room to DB
  Future<int> insertRoom(RoomDB room) async {
    final db = await DatabaseHelper.instance.database;

    var result = await db!.insert(roomTable, room.toJson());
    return result;
  }

  /// Update Room DB
  Future<int> updateRecord(RoomDB room) async {
    final db = await DatabaseHelper.instance.database;

    var result = await db!.update(roomTable, room.toJson(),
        where: '${RoomField.id} = ?', whereArgs: [room.id]);
    return result;
  }

  /// Delete Room by ID
  Future<int> delete(String id) async {
    final db = await DatabaseHelper.instance.database;

    int result =
    await db!.rawDelete('DELETE FROM $roomTable WHERE ${RoomField.id} = $id');
    return result;
  }

  /// Delete All Table
  Future<int> deleteAll() async{
    final db = await DatabaseHelper.instance.database;
    
    return await db!.delete(roomTable);
  }

  Future<int?> getCount() async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> x =
    await db!.rawQuery('SELECT COUNT(*) FROM $roomTable');
    int? res = Sqflite.firstIntValue(x);
    return res;
  }

  /// Fetch All Room
  Future<List<RoomDB>> getRooms() async {
    var roomList = await getRoomMapList();
    int count = roomList.length;

    List<RoomDB> rooms = [];

    for (int i = 0; i < count; i++) {
      rooms.add(RoomDB.fromJson(roomList[i]));
    }
    return rooms;
  }

}