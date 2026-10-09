import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumana_task/core/app_exception.dart';
import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/features/search/domain/product_repository.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/connectivity_service.dart';
import 'search_event.dart';
import 'search_state.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductRepository _productRepo;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _connectivitySub;

  SearchBloc({
    required ProductRepository productRepo,
    required ConnectivityService connectivity,
  }) : _productRepo = productRepo,
       _connectivity = connectivity,
       super(SearchState(queryHistory: productRepo.searchHistory)) {
    on<SearchQueryChanged>(
      _handleSearch,
      transformer: debounce(
        const Duration(milliseconds: AppConstants.debounceMs),
      ),
    );
    on<LoadMoreProducts>(_loadNextPage);
    on<RemoveFromHistory>(_removeFromHistory);
    on<ConnectivityChanged>(_onConnectivityChanged);

    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final isOnline = await _connectivity.hasConnection();
    add(ConnectivityChanged(isOnline));

    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      add(ConnectivityChanged(isOnline));
    });
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<SearchState> emit,
  ) async {
    final cameBackOnline = event.isOnline && !state.isOnline;
    emit(state.copyWith(isOnline: event.isOnline));

    if (cameBackOnline && state.needsRefresh && state.query.isNotEmpty) {
      add(SearchQueryChanged(state.query));
    }
  }

  Future<void> _removeFromHistory(
    RemoveFromHistory event,
    Emitter<SearchState> emit,
  ) async {
    final previousHistory = state.queryHistory;
    final updated = previousHistory.where((q) => q != event.query).toList();

    emit(state.copyWith(queryHistory: updated, clearError: true));

    try {
      await _productRepo.saveSearchHistory(updated);
    } catch (e) {
      emit(
        state.copyWith(
          queryHistory: previousHistory,
          error: AppException.from(e),
        ),
      );
    }
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
      final result = await _productRepo.search(query, 0, AppConstants.pageSize);
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

      if (historyChanged) await _productRepo.saveSearchHistory(history);
    } catch (e) {
      emit(
        state.copyWith(
          products: const [],
          isLoading: false,
          isFromCache: false,
          hasReachedMax: true,
          error: AppException.from(e),
        ),
      );
    }
  }

  Future<void> _loadNextPage(
    LoadMoreProducts event,
    Emitter<SearchState> emit,
  ) async {
    if (!state.canLoadMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final result = await _productRepo.search(
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
              ? AppException.from(e)
              : const AppException(AppExceptionType.offlineNoCache),
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
