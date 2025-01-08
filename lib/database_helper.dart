import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'user_repository.dart';

class DBHelper {
  static const _databaseName = "PaginationTestsSqflite.db";
  static const _databaseVersion = 1;

  DBHelper._();
  static final DBHelper instance = DBHelper._();
  static Database? _database;

  factory DBHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await UserRepository().createTable(db);
  }

  Future<void> _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<void> deleteDatabase() async {
    var databasePath = await getApplicationDocumentsDirectory();
    var path = join(databasePath.path, _databaseName);
    final exists = await databaseFactory.databaseExists(path);
    if (exists) {
      await databaseFactory.deleteDatabase(path);
      debugPrint("\nBanco Removido.\n");
    } else {
      debugPrint("\n\nBanco não encontrado.");
    }
  }
}
