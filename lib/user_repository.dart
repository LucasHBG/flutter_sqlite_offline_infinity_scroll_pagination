import 'package:sqflite/sqflite.dart';
import 'package:sqflite_test_pagination/database_helper.dart';

import 'user.dart';

class UserRepository {
  final tableName = "user";

  Future<void> createTable(Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS $tableName (
        "id" INTEGER NOT NULL,
	      "active"	TEXT NOT NULL,
	      "sex"	TEXT NOT NULL,
        "name"	TEXT NOT NULL,
	      PRIMARY KEY("id")
      );
      """);
  }

  Future<List<User>> getUsers() async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.query('user');

    return List.generate(
      maps.length,
      (i) {
        return User.fromMap(maps[i]);
      },
    );
  }

  Future<List<User>> getUsersPaginated(int offset) async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM $tableName LIMIT 10 OFFSET $offset;');

    return List.generate(
      maps.length,
      (i) {
        return User.fromMap(maps[i]);
      },
    );
  }
}
