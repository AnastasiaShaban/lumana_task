import 'package:lumana_task/features/search/data/product_response.dart';

abstract class ProductRepository {
  Future<ProductResponse> search(String query, int skip, int limit);
}
