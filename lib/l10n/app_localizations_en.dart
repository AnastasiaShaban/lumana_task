// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Product Search';

  @override
  String get searchHint => 'Search products...';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get cachedResults => 'Showing saved results';

  @override
  String get cantLoadMoreOffline => 'Can\'t load more while offline';

  @override
  String get errTimeout =>
      'The server is taking too long to answer. Check your connection and try again.';

  @override
  String get errNoConnection =>
      'No internet connection. Connect to the network and try again.';

  @override
  String get errServer =>
      'Something went wrong on the server. Please try again later.';

  @override
  String get errUnknown => 'Something went wrong. Please try again.';

  @override
  String get errOfflineNoCache =>
      'You are offline and this search has not been saved yet.';
}
