import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'app_exception.dart';

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String mapExceptionToString(AppException exception) {
    return switch (exception.type) {
      AppExceptionType.timeout => l10n.errTimeout,
      AppExceptionType.noConnection => l10n.errNoConnection,
      AppExceptionType.server => l10n.errServer,
      AppExceptionType.offlineNoCache => l10n.errOfflineNoCache,
      AppExceptionType.unknown => exception.message ?? l10n.errUnknown,
    };
  }
}