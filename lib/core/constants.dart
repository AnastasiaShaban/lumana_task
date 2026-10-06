import 'package:flutter/material.dart';

class AppConstants {
  static const int pageSize = 20;
  static const int maxHistorySize = 20;
  static const int debounceMs = 500;
}

class AppStrings {
  static const String appTitle = 'Product Search';
  static const String searchHint = 'Search products...';
  static const String nothingFound = 'Nothing found';
  static const String tryAgain = 'Try again';
}

class AppColors {
  static const Color primary = Colors.deepPurple;
  static const Color starRating = Colors.amber;
}

class AppIcons {
  static const IconData search = Icons.search;
  static const IconData clear = Icons.clear;
  static const IconData history = Icons.history;
  static const IconData star = Icons.star;
  static const IconData imageError = Icons.image_not_supported;
}
