import 'package:lumana_task/features/search/data/product.dart';

class ProductResponse {
  final List<Product> products;
  final int limit;
  final int total;
  final int skip;

  ProductResponse({
    required this.products,
    required this.limit,
    required this.total,
    required this.skip,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      products: (json['products'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}
