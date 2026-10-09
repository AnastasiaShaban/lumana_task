import '../../../core/app_exception.dart';
import '../../../core/connectivity_service.dart';
import '../domain/product_repository.dart';
import '../domain/search_result.dart';
import 'data_sources/product_data_source.dart';
import 'data_sources/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDatasource _remote;
  final ProductLocalDatasource _local;
  final ConnectivityService _connectivity;

  const ProductRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  Future<SearchResult> search(String query, int skip, int limit) async {
    if (!await _connectivity.hasConnection()) {
      return _fromCacheOrThrow(
        query,
        skip,
        limit,
        const AppException(AppExceptionType.offlineNoCache),
      );
    }

    try {
      final response = await _remote.search(query, skip, limit);
      await _local.savePage(query, skip, limit, response);

      return SearchResult(
        products: response.products.map((dto) => dto.toDomain()).toList(),
        total: response.total,
        isFromCache: false,
      );
    } catch (e) {
      return _fromCacheOrThrow(query, skip, limit, AppException.from(e));
    }
  }

  Future<SearchResult> _fromCacheOrThrow(
    String query,
    int skip,
    int limit,
    AppException error,
  ) async {
    final cached = await _local.getPage(query, skip, limit);
    if (cached == null) throw error;

    return SearchResult(
      products: cached.products.map((dto) => dto.toDomain()).toList(),
      total: cached.total,
      isFromCache: true,
    );
  }

  @override
  List<String> get searchHistory => _local.getHistory();

  @override
  Future<void> saveSearchHistory(List<String> history) =>
      _local.saveHistory(history);
}
