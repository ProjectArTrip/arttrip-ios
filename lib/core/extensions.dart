import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
