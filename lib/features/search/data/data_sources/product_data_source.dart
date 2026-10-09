import '../../../../core/api_client.dart';
import '../../../../core/app_exception.dart';
import '../dtos/product_response_dto.dart';

class ProductDatasource {
  final ApiClient _apiClient;

  const ProductDatasource(this._apiClient);

  Future<ProductResponseDto> search(String query, int skip, int limit) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.search,
        queryParameters: <String, dynamic>{
          'q': query,
          'skip': skip,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data == null) {
        return ProductResponseDto(
          products: const [],
          total: 0,
          skip: skip,
          limit: limit,
        );
      }

      return ProductResponseDto.fromJson(data);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
