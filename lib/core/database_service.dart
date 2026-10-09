import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

abstract final class DatabaseService {
  static Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'app_cache.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_pages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query TEXT,
            skip INTEGER,
            `limit` INTEGER,
            json_data TEXT,
            updated_at INTEGER
          )
        ''');
      },
    );
  }
}