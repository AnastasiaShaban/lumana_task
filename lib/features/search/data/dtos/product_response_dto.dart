import 'package:lumana_task/features/search/data/dtos/product_dto.dart';

class ProductResponseDto {
  final List<ProductDto> products;
  final int total;
  final int skip;
  final int limit;

  const ProductResponseDto({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponseDto.fromJson(Map<String, dynamic> json) {
    return ProductResponseDto(
      products:
          (json['products'] as List<dynamic>?)
              ?.map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'products': products.map((p) => p.toJson()).toList(),
    'total': total,
    'skip': skip,
    'limit': limit,
  };
}
