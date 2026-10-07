import 'package:equatable/equatable.dart';

import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/features/search/data/product.dart';

class SearchState extends Equatable {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String query;
  final String? error;
  final List<String> queryHistory;
  final bool isOnline;

  final bool isFromCache;

  const SearchState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.query = '',
    this.error,
    this.queryHistory = const [],
    this.isOnline = true,
    this.isFromCache = false,
  });

  List<String> suggestionsFor(String input) {
    final needle = input.trim().toLowerCase();
    if (needle.isEmpty) return queryHistory;

    return queryHistory
        .where((item) => item.toLowerCase() != needle && _matches(item, needle))
        .take(AppConstants.maxSuggestions)
        .toList();
  }

  static bool _matches(String item, String needle) {
    final lower = item.toLowerCase();
    if (lower.startsWith(needle)) return true;

    return lower.split(RegExp(r'\s+')).any((word) => word.startsWith(needle));
  }

  SearchState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? query,
    String? error,
    bool clearError = false,
    List<String>? queryHistory,
    bool? isOnline,
    bool? isFromCache,
  }) {
    return SearchState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
      error: clearError ? null : (error ?? this.error),
      queryHistory: queryHistory ?? this.queryHistory,
      isOnline: isOnline ?? this.isOnline,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    products,
    isLoading,
    isLoadingMore,
    hasReachedMax,
    query,
    error,
    queryHistory,
    isOnline,
    isFromCache,
  ];
}
