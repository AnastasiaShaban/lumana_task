import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'constants.dart';

abstract final class DatabaseService {
  static Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DBConstants.dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${DBConstants.cacheTableName} (
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