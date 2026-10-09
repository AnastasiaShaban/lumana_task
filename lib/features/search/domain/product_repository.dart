import 'search_result.dart';

abstract interface class ProductRepository {
  List<String> get searchHistory;

  Future<SearchResult> search(String query, int skip, int limit);

  Future<void> saveSearchHistory(List<String> history);
}
