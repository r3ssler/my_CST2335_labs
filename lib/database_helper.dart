import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'shopping_item.dart';
import 'database_helper.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // For Web: override databaseFactory
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shopping_list.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            quantity TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertItem(ShoppingItem item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<ShoppingItem>> getItems() async {
    final db = await database;
    final maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return ShoppingItem.fromMap(maps[i]);
    });
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
