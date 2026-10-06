abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;

  SearchQueryChanged(this.query);
}

class LoadMoreProducts extends SearchEvent {}

class RemoveFromHistory extends SearchEvent {
  final String query;

  RemoveFromHistory(this.query);
}
