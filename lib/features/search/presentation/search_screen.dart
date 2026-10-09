import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumana_task/core/context_extensions.dart';
import 'package:lumana_task/core/injection_container.dart';
import 'package:lumana_task/features/search/presentation/widgets/cache_notice.dart';
import 'package:lumana_task/features/search/presentation/widgets/offline_banner.dart';
import 'package:lumana_task/features/search/presentation/widgets/search_content.dart';
import 'package:lumana_task/features/search/presentation/widgets/search_input_field.dart';
import 'package:lumana_task/features/search/presentation/widgets/suggestion_chips.dart';

import 'bloc/search_bloc.dart';
import 'bloc/search_event.dart';
import 'bloc/search_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.9) {
      context.read<SearchBloc>().add(const LoadMoreProducts());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectQuery(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      body: BlocListener<SearchBloc, SearchState>(
        listenWhen: (prev, curr) =>
            curr.error != null &&
            curr.error != prev.error &&
            curr.products.isNotEmpty,
        listener: (context, state) {
          final error = state.error;

          if (error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(context.mapExceptionToString(error))),
              );
          }
        },
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return Column(
              children: [
                if (!state.isOnline) const OfflineBanner(),
                SearchInputField(controller: _controller),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SuggestionChips(
                      suggestions: state.suggestionsFor(value.text),
                      onSelected: _onSelectQuery,
                    );
                  },
                ),
                if (state.isFromCache && state.products.isNotEmpty)
                  const CacheNotice(),
                Expanded(
                  child: SearchContent(
                    query: state.query,
                    products: state.products,
                    queryHistory: state.queryHistory,
                    isLoading: state.isLoading,
                    hasReachedMax: state.hasReachedMax,
                    error: state.error,
                    scrollController: _scrollController,
                    onSuggestionTap: _onSelectQuery,
                    onSuggestionRemove: (q) {
                      context.read<SearchBloc>().add(RemoveFromHistory(q));
                    },
                    onRetry: () {
                      context.read<SearchBloc>().add(
                        SearchQueryChanged(state.query),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
