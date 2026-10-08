import 'product.dart';

class SearchResult {
  final List<Product> products;
  final int total;
  final bool isFromCache;

  const SearchResult({
    required this.products,
    required this.total,
    required this.isFromCache,
  });
}
