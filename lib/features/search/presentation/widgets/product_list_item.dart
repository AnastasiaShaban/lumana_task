import 'package:flutter/material.dart';

import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/features/search/domain/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          product.thumbnail,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(AppIcons.imageError, size: 24),
        ),
      ),
      title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.star, color: AppColors.starRating, size: 14),
          const SizedBox(width: 2),
          Text(product.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }
}
