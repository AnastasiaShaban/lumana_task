import 'package:equatable/equatable.dart';
import 'package:lumana_task/features/search/domain/entities/product.dart';

import '../../../../core/app_exception.dart';
import '../../../../core/search_suggestions_filter.dart';

class SearchState extends Equatable {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String query;
  final AppException? error;
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

  bool get needsRefresh => isFromCache || error != null;

  bool get canLoadMore => !hasReachedMax && !isLoadingMore && query.isNotEmpty;

  List<String> suggestionsFor(String input) =>
      queryHistory.filterSuggestions(input);

  SearchState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? query,
    AppException? error,
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
