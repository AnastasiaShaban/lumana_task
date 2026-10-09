import 'package:flutter/material.dart';
import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/core/context_extensions.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        context.l10n.noInternet,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.onPrimary),
      ),
    );
  }
}
