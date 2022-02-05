import 'dart:core';
import 'dart:io';

import 'package:chat_app/data/model/room.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static const dbName = 'chat_app.db';

  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _db;

  String colId = 'id';
  String colName = 'name';
  String colUsers = 'users';
  String colMessages = 'messages';
  String colPicture = 'picture';
  String colCreatedTime = 'timeCreated';
  String colUpdatedTime = 'timeUpdated';

  DatabaseHelper._internal();

  Future<Database?> get database async {
    _db ??= await initializeDatabase();
    return _db;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + dbName;

    // Open/create the database at a given path
    var roomTable = await openDatabase(path, version: 1, onCreate: _createDb);
    return roomTable;
  }

  /// Create Table
  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $roomTable('
        '$colId TEXT,'
        '$colName TEXT,'
        '$colUsers TEXT,'
        '$colMessages TEXT,'
        '$colPicture TEXT,'
        '$colCreatedTime TEXT,'
        '$colUpdatedTime TEXT)');
  }
}
