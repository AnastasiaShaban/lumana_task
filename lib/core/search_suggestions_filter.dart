import 'package:lumana_task/core/constants.dart';

extension SearchSuggestionsFilter on List<String> {
  List<String> filterSuggestions(
    String input, {
    int maxSuggestions = AppConstants.maxSuggestions,
  }) {
    final needle = input.trim().toLowerCase();
    if (needle.isEmpty) return this;

    return where(
      (item) => item.toLowerCase() != needle && _matches(item, needle),
    ).take(maxSuggestions).toList();
  }

  static bool _matches(String item, String needle) {
    final lower = item.toLowerCase();
    if (lower.startsWith(needle)) return true;

    return lower.split(RegExp(r'\s+')).any((word) => word.startsWith(needle));
  }
}
