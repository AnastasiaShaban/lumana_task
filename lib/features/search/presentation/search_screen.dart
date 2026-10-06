import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/core/injection_container.dart';
import 'bloc/search_bloc.dart';
import 'bloc/search_event.dart';
import 'bloc/search_state.dart';
import 'widgets/product_list_item.dart';
import 'widgets/search_suggestions.dart';

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
  var _canLoadMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScroll);
  }

  void _checkScroll() {
    if (!_scrollController.hasClients || !_canLoadMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.9) {
      _canLoadMore = false;
      context.read<SearchBloc>().add(LoadMoreProducts());
      Future.delayed(Duration(milliseconds: 500), () => _canLoadMore = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appTitle)),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: BlocBuilder<SearchBloc, SearchState>(
        buildWhen: (prev, curr) => prev.query != curr.query,
        builder: (ctx, state) {
          return TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: Icon(AppIcons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(AppIcons.clear),
                      onPressed: () {
                        _controller.clear();
                        ctx.read<SearchBloc>().add(SearchQueryChanged(''));
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (val) {
              ctx.read<SearchBloc>().add(SearchQueryChanged(val));
            },
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (ctx, state) {
        if (state.query.isEmpty && state.queryHistory.isNotEmpty) {
          return SearchSuggestions(
            suggestions: state.queryHistory,
            onTap: (q) {
              _controller.text = q;
              ctx.read<SearchBloc>().add(SearchQueryChanged(q));
            },
            onRemove: (q) {
              ctx.read<SearchBloc>().add(RemoveFromHistory(q));
            },
          );
        }

        if (state.error != null && state.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error!),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => ctx.read<SearchBloc>().add(
                    SearchQueryChanged(state.query),
                  ),
                  child: const Text(AppStrings.tryAgain),
                ),
              ],
            ),
          );
        }

        if (state.isLoading && state.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.products.isEmpty && state.query.isNotEmpty) {
          return const Center(child: Text(AppStrings.nothingFound));
        }

        if (state.products.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: state.hasReachedMax
              ? state.products.length
              : state.products.length + 1,
          itemBuilder: (_, i) {
            if (i >= state.products.length) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ProductListItem(product: state.products[i]);
          },
        );
      },
    );
  }
}
