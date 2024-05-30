import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Log {
  final int? id;
  final String action;
  final String movieName;
  final DateTime timestamp;

  Log(
      {this.id,
      required this.action,
      required this.movieName,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'movieName': movieName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static Future<Database> _openDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'logs.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE logs(id INTEGER PRIMARY KEY, action TEXT, movieName TEXT, timestamp TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertLog(Log log) async {
    final db = await _openDatabase();
    await db.insert('logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Log>> getLogs() async {
    final db = await _openDatabase();
    final List<Map<String, dynamic>> maps = await db.query('logs');

    return List.generate(maps.length, (i) {
      return Log(
        id: maps[i]['id'],
        action: maps[i]['action'],
        movieName: maps[i]['movieName'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
      );
    });
  }

  static Future<void> deleteLogs() async {
    final db = await _openDatabase();
    await db.delete('logs');
  }
}
