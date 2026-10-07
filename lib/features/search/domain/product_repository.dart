import 'search_result.dart';

abstract class ProductRepository {
  Future<SearchResult> search(String query, int skip, int limit);

  List<String> get searchHistory;

  Future<void> saveSearchHistory(List<String> history);
}
