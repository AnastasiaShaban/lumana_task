import 'package:lumana_task/features/search/data/product.dart';

class SearchState {
  final List<Product> products;
  final bool isLoading;
  final bool hasReachedMax;
  final String query;
  final String? error;
  final List<String> queryHistory;

  SearchState({
    this.products = const [],
    this.isLoading = false,
    this.hasReachedMax = false,
    this.query = '',
    this.error,
    this.queryHistory = const [],
  });

  SearchState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasReachedMax,
    String? query,
    String? error,
    List<String>? queryHistory,
  }) {
    return SearchState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
      error: error,
      queryHistory: queryHistory ?? this.queryHistory,
    );
  }
}
