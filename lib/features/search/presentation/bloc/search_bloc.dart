import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/features/search/domain/product_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductRepository _repo;

  SearchBloc(this._repo) : super(SearchState()) {
    on<SearchQueryChanged>(
      _handleSearch,
      transformer: (events, mapper) {
        return events
            .debounceTime(Duration(milliseconds: AppConstants.debounceMs))
            .flatMap(mapper);
      },
    );
    on<LoadMoreProducts>(_loadNextPage);
    on<RemoveFromHistory>(_removeFromHistory);
  }

  void _removeFromHistory(RemoveFromHistory event, Emitter<SearchState> emit) {
    final updated = state.queryHistory.where((q) => q != event.query).toList();
    emit(state.copyWith(queryHistory: updated));
  }

  Future<void> _handleSearch(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchState(queryHistory: state.queryHistory));
      return;
    }

    emit(state.copyWith(isLoading: true, query: query, error: null));

    try {
      final res = await _repo.search(query, 0, AppConstants.pageSize);

      emit(
        state.copyWith(
          products: res.products,
          isLoading: false,
          hasReachedMax: res.products.length >= res.total,
          queryHistory: _addToHistory(query),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _loadNextPage(
    LoadMoreProducts event,
    Emitter<SearchState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true));
    try {
      final res = await _repo.search(
        state.query,
        state.products.length,
        AppConstants.pageSize,
      );
      final allProducts = [...state.products, ...res.products];

      emit(
        state.copyWith(
          products: allProducts,
          isLoading: false,
          hasReachedMax: allProducts.length >= res.total,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
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
