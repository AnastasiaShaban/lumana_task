import 'package:flutter/material.dart';
import 'package:lumana_task/core/constants.dart';

class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;

  const SearchSuggestions({
    required this.suggestions,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        final item = suggestions[i];

        return ListTile(
          leading: Icon(AppIcons.history),
          title: Text(item),
          trailing: IconButton(
            icon: Icon(AppIcons.clear, size: 18),
            onPressed: () => onRemove(item),
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }
}
