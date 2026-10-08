import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumana_task/core/app_exception.dart';
import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/features/search/domain/product_repository.dart';
import 'package:rxdart/rxdart.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductRepository _repo;

  SearchBloc(ProductRepository repo)
    : _repo = repo,
      super(SearchState(queryHistory: repo.searchHistory)) {
    on<SearchQueryChanged>(
      _handleSearch,
      transformer: (events, mapper) {
        return events
            .debounceTime(Duration(milliseconds: AppConstants.debounceMs))
            .switchMap(mapper);
      },
    );
    on<LoadMoreProducts>(_loadNextPage);
    on<RemoveFromHistory>(_removeFromHistory);
    on<ConnectivityChanged>(_onConnectivityChanged);
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<SearchState> emit,
  ) async {
    final cameBackOnline = event.isOnline && !state.isOnline;
    emit(state.copyWith(isOnline: event.isOnline));

    final needsRefresh = state.isFromCache || state.error != null;
    if (cameBackOnline && needsRefresh && state.query.isNotEmpty) {
      add(SearchQueryChanged(state.query));
    }
  }

  Future<void> _removeFromHistory(
    RemoveFromHistory event,
    Emitter<SearchState> emit,
  ) async {
    final updated = state.queryHistory.where((q) => q != event.query).toList();
    emit(state.copyWith(queryHistory: updated));
    await _repo.saveSearchHistory(updated);
  }

  Future<void> _handleSearch(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(
        SearchState(queryHistory: state.queryHistory, isOnline: state.isOnline),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, query: query, clearError: true));

    try {
      final result = await _repo.search(query, 0, AppConstants.pageSize);
      final history = result.products.isNotEmpty
          ? _addToHistory(query)
          : state.queryHistory;
      final historyChanged = !identical(history, state.queryHistory);

      emit(
        state.copyWith(
          products: result.products,
          isLoading: false,
          isFromCache: result.isFromCache,
          hasReachedMax: result.products.length >= result.total,
          queryHistory: history,
        ),
      );

      if (historyChanged) await _repo.saveSearchHistory(history);
    } catch (e) {
      emit(
        state.copyWith(
          products: const [],
          isLoading: false,
          isFromCache: false,
          hasReachedMax: true,
          error: AppException.from(e).message,
        ),
      );
    }
  }

  Future<void> _loadNextPage(
    LoadMoreProducts event,
    Emitter<SearchState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.query.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final result = await _repo.search(
        state.query,
        state.products.length,
        AppConstants.pageSize,
      );
      final allProducts = [...state.products, ...result.products];

      emit(
        state.copyWith(
          products: allProducts,
          isLoadingMore: false,
          isFromCache: state.isFromCache || result.isFromCache,
          hasReachedMax:
              result.products.isEmpty || allProducts.length >= result.total,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          hasReachedMax: true,
          error: state.isOnline
              ? AppException.from(e).message
              : AppStrings.cantLoadMoreOffline,
        ),
      );
    }
  }

  List<String> _addToHistory(String query) {
    if (state.queryHistory.contains(query)) return state.queryHistory;
    return [
      query,
      ...state.queryHistory,
    ].take(AppConstants.maxHistorySize).toList();
  }
}
