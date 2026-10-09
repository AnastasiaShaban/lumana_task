import 'package:flutter/material.dart';

class AppConstants {
  static const int pageSize = 20;
  static const int maxHistorySize = 20;
  static const int debounceMs = 500;
  static const int maxCachedPages = 60;
  static const int maxSuggestions = 5;
}

class AppColors {
  static const Color primary = Colors.deepPurple;
  static const Color onPrimary = Colors.white;
  static const Color starRating = Colors.amber;
  static const Color error = Colors.red;
}

class AppIcons {
  static const IconData search = Icons.search;
  static const IconData clear = Icons.clear;
  static const IconData history = Icons.history;
  static const IconData star = Icons.star;
  static const IconData imageError = Icons.image_not_supported;
  static const IconData offline = Icons.cloud_off;
}

class DBConstants {
  static const String dbName = 'app_cache.db';
  static const String cacheTableName = 'cached_pages';
}