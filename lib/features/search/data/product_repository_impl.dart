import 'package:lumana_task/features/search/data/product_response.dart';
import '../domain/product_repository.dart';
import 'product_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDatasource _datasource;

  ProductRepositoryImpl(this._datasource);

  @override
  Future<ProductResponse> search(String query, int skip, int limit) {
    return _datasource.search(query, skip, limit);
  }
}
