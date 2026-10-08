import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_state.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (prev, curr) => prev.isOnline != curr.isOnline,
      builder: (context, state) {
        if (state.isOnline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            AppStrings.noInternet,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onPrimary),
          ),
        );
      },
    );
  }
}
