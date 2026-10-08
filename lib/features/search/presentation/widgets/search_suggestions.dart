import 'package:flutter/material.dart';
import 'package:lumana_task/core/constants.dart';

class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;
  final void Function(String) onRemove;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onTap,
    required this.onRemove,
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
