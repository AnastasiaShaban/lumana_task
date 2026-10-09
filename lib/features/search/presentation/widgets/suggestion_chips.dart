import 'package:flutter/material.dart';
import 'package:lumana_task/core/constants.dart';

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const SuggestionChips({
    required this.suggestions,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final suggestion = suggestions[i];

          return ActionChip(
            avatar: const Icon(AppIcons.history, size: 16),
            label: Text(suggestion),
            onPressed: () => onSelected(suggestion),
          );
        },
      ),
    );
  }
}
