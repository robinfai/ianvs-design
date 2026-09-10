import 'package:flutter/material.dart';

/// Gregorian dates with intact Chinese date and weekday units in narrow headers.
/// Parsing, calendar arithmetic and non-Chinese formatting stay with Material.
class IanvsGregorianCalendarDelegate extends GregorianCalendarDelegate {
  const IanvsGregorianCalendarDelegate();

  static String _keepUnits(String value) => value.replaceAllMapped(
    RegExp(r'\d+年|\d+月\d+日|(?:星期|周)[一二三四五六日天]'),
    (match) => match[0]!.split('').join('\u2060'),
  );

  @override
  String formatMediumDate(DateTime date, MaterialLocalizations localizations) =>
      _keepUnits(super.formatMediumDate(date, localizations));

  @override
  String formatShortMonthDay(
    DateTime date,
    MaterialLocalizations localizations,
  ) => _keepUnits(super.formatShortMonthDay(date, localizations));

  @override
  String formatShortDate(DateTime date, MaterialLocalizations localizations) =>
      _keepUnits(super.formatShortDate(date, localizations));
}
