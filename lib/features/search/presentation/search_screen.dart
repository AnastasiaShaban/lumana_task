import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lumana_task/core/connectivity_service.dart';
import 'package:lumana_task/core/constants.dart';
import 'package:lumana_task/core/injection_container.dart';
import 'package:lumana_task/features/search/presentation/widgets/offline_banner.dart';
import 'package:lumana_task/features/search/presentation/widgets/search_input_field.dart';

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
  StreamSubscription<bool>? _connectivitySub;

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
      body: BlocListener<SearchBloc, SearchState>(
        listenWhen: (prev, curr) =>
            curr.error != null &&
            curr.error != prev.error &&
            curr.products.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        },
        child: Column(
          children: [
            const OfflineBanner(),
            SearchInputField(controller: _controller),
            _SuggestionChips(controller: _controller),
            const _CacheNotice(),
            Expanded(
              child: _SearchContent(
                controller: _controller,
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final TextEditingController controller;

  const _SuggestionChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.trim().isEmpty) return const SizedBox.shrink();

        return BlocBuilder<SearchBloc, SearchState>(
          buildWhen: (prev, curr) => prev.queryHistory != curr.queryHistory,
          builder: (context, state) {
            final matches = state.suggestionsFor(value.text);
            if (matches.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: matches.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final suggestion = matches[i];

                  return ActionChip(
                    avatar: Icon(AppIcons.history, size: 16),
                    label: Text(suggestion),
                    onPressed: () {
                      controller.text = suggestion;
                      controller.selection = TextSelection.collapsed(
                        offset: suggestion.length,
                      );
                      context.read<SearchBloc>().add(
                        SearchQueryChanged(suggestion),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _CacheNotice extends StatelessWidget {
  const _CacheNotice();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (prev, curr) =>
          prev.isFromCache != curr.isFromCache ||
          prev.products.isEmpty != curr.products.isEmpty,
      builder: (context, state) {
        if (!state.isFromCache || state.products.isEmpty) {
          return const SizedBox.shrink();
        }
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
                AppStrings.cachedResults,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
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

        if (state.isLoading && state.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.offline,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.read<SearchBloc>().add(
                      SearchQueryChanged(state.query),
                    ),
                    child: const Text(AppStrings.tryAgain),
                  ),
                ],
              ),
            ),
          );
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
