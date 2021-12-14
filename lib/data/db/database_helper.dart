import 'dart:io';

import 'package:chat_app/model/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// class DatabaseHelper{
//
//   static final DatabaseHelper _instance = new DatabaseHelper.internal();
//
//   factory DatabaseHelper() => _instance;
//
//   static Database _db;
//
//   DatabaseHelper.internal();
//
//   Future<Database> get db async {
//     if (_db != null) return _db;
//     _db = await initDb();
//     return _db;
//   }
//
//   initDb() async {
//     // Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     // String path = join(documentsDirectory.path, "main.db");
//     // var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
//     // return theDb;
//   }
//
//   void _onCreate(Database db, int version) async {
//     // When creating the db, create the table
//     await db.execute(
//         "CREATE TABLE User(id INTEGER PRIMARY KEY, firstname TEXT, lastname TEXT, dob TEXT)");
//   }
//
//   // Future<List<UserDatabase>> getUser() async{
//   //   var dbClient = await db;
//   //   List<Map> list;
//   //
//   // }
//
// }