sealed class SearchEvent {
  const SearchEvent();
}

final class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);
}

final class LoadMoreProducts extends SearchEvent {
  const LoadMoreProducts();
}

final class RemoveFromHistory extends SearchEvent {
  final String query;

  const RemoveFromHistory(this.query);
}

final class ConnectivityChanged extends SearchEvent {
  final bool isOnline;

  const ConnectivityChanged(this.isOnline);
}
