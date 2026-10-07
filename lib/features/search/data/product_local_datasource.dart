import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import 'product.dart';
import 'product_response.dart';

class ProductLocalDatasource {
  static const String _pagePrefix = 'page:';
  static const String _indexKey = 'page_index';
  static const String _historyKey = 'search_history';

  final SharedPreferences _prefs;

  ProductLocalDatasource(this._prefs);

  String _pageKey(String query, int skip, int limit) =>
      '$_pagePrefix${query.trim().toLowerCase()}:$skip:$limit';

  ProductResponse? getPage(String query, int skip, int limit) {
    final raw = _prefs.getString(_pageKey(query, skip, limit));
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;

      return ProductResponse(
        products: (json['products'] as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
        skip: skip,
        limit: limit,
      );
    } catch (_) {
      _prefs.remove(_pageKey(query, skip, limit));
      return null;
    }
  }

  Future<void> savePage(
    String query,
    int skip,
    int limit,
    ProductResponse response,
  ) async {
    final key = _pageKey(query, skip, limit);
    await _prefs.setString(
      key,
      jsonEncode({
        'total': response.total,
        'products': response.products.map((p) => p.toJson()).toList(),
      }),
    );
    await _touchIndex(key);
  }

  Future<void> _touchIndex(String key) async {
    final index = _prefs.getStringList(_indexKey) ?? <String>[];
    index
      ..remove(key)
      ..add(key);

    while (index.length > AppConstants.maxCachedPages) {
      await _prefs.remove(index.removeAt(0));
    }
    await _prefs.setStringList(_indexKey, index);
  }

  List<String> getHistory() => _prefs.getStringList(_historyKey) ?? const [];

  Future<void> saveHistory(List<String> history) =>
      _prefs.setStringList(_historyKey, history);
}
