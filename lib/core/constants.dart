import 'package:flutter/material.dart';

class AppConstants {
  static const int pageSize = 20;
  static const int maxHistorySize = 20;
  static const int debounceMs = 500;
  static const int maxCachedPages = 60;
  static const int maxSuggestions = 5;
}

class AppStrings {
  static const String appTitle = 'Product Search';
  static const String searchHint = 'Search products...';
  static const String nothingFound = 'Nothing found';
  static const String tryAgain = 'Try again';
  static const String noInternet = 'No internet connection';
  static const String cachedResults = 'Showing saved results';
  static const String cantLoadMoreOffline = 'Can\'t load more while offline';
  static const String errTimeout =
      'The server is taking too long to answer. Check your connection and try again.';
  static const String errNoConnection =
      'No internet connection. Connect to the network and try again.';
  static const String errServer =
      'Something went wrong on the server. Please try again later.';
  static const String errUnknown = 'Something went wrong. Please try again.';
  static const String errOfflineNoCache =
      'You are offline and this search has not been saved yet.';
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
