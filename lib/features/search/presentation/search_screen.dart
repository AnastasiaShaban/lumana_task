import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lumana_task/core/connectivity_service.dart';
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
  StreamSubscription? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initConnectivity();
  }

  void _initConnectivity() {
    final bloc = context.read<SearchBloc>();
    final connectivity = sl<ConnectivityService>();
    connectivity.hasConnection().then((isOnline) {
      bloc.add(ConnectivityChanged(isOnline));
    });
    _connectivitySub = connectivity.onConnectivityChanged.listen((isOnline) {
      bloc.add(ConnectivityChanged(isOnline));
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = context.read<SearchBloc>().state;
    if (state.isLoadingMore || state.hasReachedMax) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.9) {
      context.read<SearchBloc>().add(LoadMoreProducts());
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
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
          const _OfflineBanner(),
          _SearchInputField(controller: _controller),
          Expanded(
            child: _SearchContent(
              controller: _controller,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (prev, curr) => prev.isOnline != curr.isOnline,
      builder: (context, state) {
        if (state.isOnline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            AppStrings.noInternet,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}

class _SearchInputField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (val) {
          context.read<SearchBloc>().add(SearchQueryChanged(val));
        },
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  final TextEditingController controller;
  final ScrollController scrollController;

  const _SearchContent({
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state.query.isEmpty && state.queryHistory.isNotEmpty) {
          return SearchSuggestions(
            suggestions: state.queryHistory,
            onTap: (q) {
              controller.text = q;
              context.read<SearchBloc>().add(SearchQueryChanged(q));
            },
            onRemove: (q) {
              context.read<SearchBloc>().add(RemoveFromHistory(q));
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
                  onPressed: () => context.read<SearchBloc>().add(
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
          controller: scrollController,
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
