// lib/core/utils/date_formatter.dart
import 'package:flutter/material.dart';

class DateFormatter {
  static DateTime? _parseYmd(String ymd) {
    try { return DateTime.parse(ymd); } catch (_) { return null; }
  }

  static String fullFromYmd(BuildContext context, String ymd) {
    final d = _parseYmd(ymd);
    if (d == null) return ymd;
    return MaterialLocalizations.of(context).formatFullDate(d);
  }

  static String mediumFromYmd(BuildContext context, String ymd) {
    final d = _parseYmd(ymd);
    if (d == null) return ymd;
    return MaterialLocalizations.of(context).formatMediumDate(d);
  }

  static String shortFromYmd(BuildContext context, String ymd) {
    final d = _parseYmd(ymd);
    if (d == null) return ymd;
    return MaterialLocalizations.of(context).formatShortDate(d);
  }
}
