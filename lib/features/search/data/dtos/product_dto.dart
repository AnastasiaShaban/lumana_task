import 'package:lumana_task/features/search/domain/product.dart';

class ProductDto {
  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;
  final double rating;

  const ProductDto({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.rating,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'thumbnail': thumbnail,
    'rating': rating,
  };

  Product toDomain() {
    return Product(
      id: id,
      title: title,
      description: description,
      price: price,
      thumbnail: thumbnail,
      rating: rating,
    );
  }
}
