// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/reminder.dart';

class DatabaseHelper {
  late Database _database;

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'reminders.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT
        )
      ''');
    });
  }

  Future<int> insertReminder(Reminder reminder) async {
    Database db = await database;
    return await db.insert('reminders', {
      'title': reminder.title,
      'description': reminder.description,
    });
  }

  Future<List<Reminder>> getReminders() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('reminders');
    return List.generate(maps.length, (i) {
      return Reminder(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
      );
    });
  }

  Future<int> updateReminder(Reminder reminder) async {
    Database db = await database;
    return await db.update(
      'reminders',
      {
        'title': reminder.title,
        'description': reminder.description,
      },
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    Database db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
