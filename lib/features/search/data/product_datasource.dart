import '../../../core/api_client.dart';
import 'product_response.dart';

class ProductDatasource {
  final ApiClient _apiClient;

  ProductDatasource(this._apiClient);

  Future<ProductResponse> search(String query, int skip, int limit) async {
    final response = await _apiClient.get(
      ApiEndpoints.search,
      queryParameters: {'q': query, 'skip': skip, 'limit': limit},
    );
    return ProductResponse.fromJson(response.data);
  }
}
