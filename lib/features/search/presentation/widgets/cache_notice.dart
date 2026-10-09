import 'package:flutter/material.dart';
import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/core/context_extensions.dart';

class CacheNotice extends StatelessWidget {
  const CacheNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Row(
        children: [
          Icon(
            AppIcons.offline,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.cachedResults,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
