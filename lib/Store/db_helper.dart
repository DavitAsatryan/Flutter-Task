import 'dart:io';

import 'package:flutter_task/Model/task_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  List<TaskModel>? taskModelList;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'taskModel.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
    CREATE TABLE taskModel(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, description TEXT, completed TEXT, active TEXT)
    ''');
  }

  Future<List<TaskModel>> getTaskModel() async {
    Database db = await instance.database;
    var taskModel = await db.query(
      'taskModel',
      orderBy: 'title',
    );
    taskModelList = taskModel.isNotEmpty
        ? taskModel.map((c) => TaskModel.fromMap(c)).toList()
        : [];
    return taskModelList!;
  }

  Future<int> add(TaskModel taskModel) async {
    Database db = await instance.database;
    return await db.insert('taskModel', taskModel.toMap());
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('taskModel', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(TaskModel taskModel) async {
    Database db = await instance.database;
    return await db.update('taskModel', taskModel.toMap(),
        where: 'id = ?', whereArgs: [taskModel.id]);
  }
}
