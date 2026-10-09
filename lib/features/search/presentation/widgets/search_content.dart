import 'package:flutter/material.dart';
import 'package:lumana_task/core/app_exception.dart';
import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/core/context_extensions.dart';
import 'package:lumana_task/features/search/domain/entities/product.dart';
import 'package:lumana_task/features/search/presentation/widgets/product_list_item.dart';
import 'package:lumana_task/features/search/presentation/widgets/search_suggestions.dart';

class SearchContent extends StatelessWidget {
  final String query;
  final List<Product> products;
  final List<String> queryHistory;
  final bool isLoading;
  final bool hasReachedMax;
  final AppException? error;
  final ScrollController scrollController;
  final ValueChanged<String> onSuggestionTap;
  final ValueChanged<String> onSuggestionRemove;
  final VoidCallback onRetry;

  const SearchContent({
    required this.query,
    required this.products,
    required this.queryHistory,
    required this.isLoading,
    required this.hasReachedMax,
    required this.scrollController,
    required this.onSuggestionTap,
    required this.onSuggestionRemove,
    required this.onRetry,
    this.error,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty && queryHistory.isNotEmpty) {
      return SearchSuggestions(
        suggestions: queryHistory,
        onTap: onSuggestionTap,
        onRemove: onSuggestionRemove,
      );
    }

    if (isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentError = error;
    if (currentError != null && products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.offline,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                context.mapExceptionToString(currentError),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text(context.l10n.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty && query.isNotEmpty) {
      return Center(child: Text(context.l10n.nothingFound));
    }

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: hasReachedMax ? products.length : products.length + 1,
      itemBuilder: (_, i) {
        if (i >= products.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final product = products[i];

        return ProductListItem(
          title: product.title,
          price: product.price,
          thumbnail: product.thumbnail,
          rating: product.rating,
        );
      },
    );
  }
}
