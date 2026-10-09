import 'package:flutter/material.dart';

import 'package:lumana_task/core/constants.dart';

class ProductListItem extends StatelessWidget {
  final String title;
  final double price;
  final String thumbnail;
  final double rating;

  const ProductListItem({
    super.key,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          thumbnail,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(AppIcons.imageError, size: 24),
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('\$${price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.star, color: AppColors.starRating, size: 14),
          const SizedBox(width: 2),
          Text(rating.toStringAsFixed(1)),
        ],
      ),
    );
  }
}
