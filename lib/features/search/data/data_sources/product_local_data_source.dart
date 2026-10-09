import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/app_exception.dart';
import '../../../../core/constants.dart';
import '../dtos/product_response_dto.dart';

class ProductLocalDatasource {
  static const String _tableName = 'cached_pages';
  static const String _historyKey = 'search_history';

  final Database _db;
  final SharedPreferences _prefs;

  const ProductLocalDatasource(this._db, this._prefs);

  Future<ProductResponseDto?> getPage(String query, int skip, int limit) async {
    try {
      final cleanQuery = query.trim().toLowerCase();

      final maps = await _db.query(
        _tableName,
        where: 'query = ? AND skip = ? AND `limit` = ?',
        whereArgs: [cleanQuery, skip, limit],
        limit: 1,
      );

      if (maps.isEmpty) return null;

      final rawJson = maps.first['json_data'] as String;
      final json = jsonDecode(rawJson) as Map<String, dynamic>;

      return ProductResponseDto.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePage(
    String query,
    int skip,
    int limit,
    ProductResponseDto response,
  ) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      final jsonString = jsonEncode(response.toJson());

      await _db.insert(_tableName, {
        'query': cleanQuery,
        'skip': skip,
        'limit': limit,
        'json_data': jsonString,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await _trimCache();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> _trimCache() async {
    await _db.execute('''
      DELETE FROM $_tableName 
      WHERE id NOT IN (
        SELECT id FROM $_tableName 
        ORDER BY updated_at DESC 
        LIMIT ${AppConstants.maxCachedPages}
      )
    ''');
  }

  List<String> getHistory() => _prefs.getStringList(_historyKey) ?? const [];

  Future<void> saveHistory(List<String> history) async {
    try {
      await _prefs.setStringList(_historyKey, history);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
