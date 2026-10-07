# Product Search

Typeahead search over the DummyJSON products API. Flutter + BLoC.

Endpoint: `GET https://dummyjson.com/products/search?q=&skip=&limit=`

## What it does

- Search as you type. 500 ms debounce, `switchMap` so a slow response can't
  overwrite a newer one.
- Pagination: the next 20 items load when you scroll past 90% of the list.
- Past queries are kept in the state and suggested while typing. Only queries
  that actually returned something are saved, 20 max.
- Suggestions match per word, so `pho` also finds `red phone case`.
- Works offline: loaded pages are cached and served when there is no network.
- Errors become readable text, nothing from Dio reaches the screen.

## Structure

```
lib/
  core/            dio client, connectivity, DI, error mapping, constants
  features/search/
    data/          models, api datasource, cache, repository impl
    domain/        repository interface, search result
    presentation/  bloc, screen, widgets
```

One feature, three layers. The repository is the only thing that knows where
the data comes from. The bloc knows nothing about Dio or the cache, the widgets
know nothing except the state.

## State

`SearchBloc` with four events: `SearchQueryChanged`, `LoadMoreProducts`,
`RemoveFromHistory`, `ConnectivityChanged`, and one immutable `SearchState`
on Equatable. Derived data is a method on the state (`suggestionsFor`), so the
widgets stay free of logic. Most of them use `buildWhen`, so typing doesn't
rebuild the list.

## Offline

`ProductRepositoryImpl` decides where to read from:

- no connection — go to the cache right away, don't make the user sit through a
  timeout that can't succeed
- online — call the API, save the page, return it
- the call failed anyway (hotel wifi, timeout, 500) — try the cache, throw only
  if there is nothing stored

Pages are cached in SharedPreferences under query + skip + limit, 60 pages max,
oldest dropped first. History is stored the same way, so suggestions survive a
restart.

The screen shows a banner when the device is offline, a note when the list came
from the cache, and a snackbar if pagination fails while items are already on
screen. When the connection is back and you are looking at cached or failed
data, the search repeats itself.

`connectivity_plus` only reports that an interface exists, not that it works,
which is why the request is also wrapped in a try/catch that falls back to the
same cache.

## About the results

Search is server-side and covers title, description, category and tags, so
`blen` also returns a strawberry — its description says "blending into
smoothies". Filtering that on the client would break `total` and the
pagination, so results are shown as the API returns them.

## Run

```bash
flutter pub get
flutter run
```
