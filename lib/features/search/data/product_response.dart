import 'package:lumana_task/features/search/domain/product.dart';

class ProductResponse {
  final List<Product> products;
  final int limit;
  final int total;
  final int skip;

  const ProductResponse({
    required this.products,
    required this.limit,
    required this.total,
    required this.skip,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      products: (json['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }
}
