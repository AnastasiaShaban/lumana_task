import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';

class SearchInputField extends StatelessWidget {
  final TextEditingController controller;

  const SearchInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          prefixIcon: Icon(AppIcons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(AppIcons.clear),
                onPressed: () {
                  controller.clear();
                  context.read<SearchBloc>().add(SearchQueryChanged(''));
                },
              );
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (val) {
          context.read<SearchBloc>().add(SearchQueryChanged(val));
        },
      ),
    );
  }
}
