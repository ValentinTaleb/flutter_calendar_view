// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../typedefs.dart';
import 'common_components.dart';

class WeekPageHeader extends CalendarPageHeader {
  /// A header widget to display on week view.
  const WeekPageHeader({
    super.key,
    super.onNextDay,
    super.onTitleTapped,
    super.onPreviousDay,
    required DateTime startDate,
    required DateTime endDate,
    super.iconColor,
    super.backgroundColor,
    StringProvider? headerStringBuilder,
    super.headerStyle,
  }) : super(
          date: startDate,
          secondaryDate: endDate,
          dateStringBuilder:
              headerStringBuilder ?? WeekPageHeader._weekStringBuilder,
        );

  static String _weekStringBuilder(DateTime date, {DateTime? secondaryDate}) =>
      "${date.day} / ${date.month} / ${date.year} to "
      "${secondaryDate != null ? "${secondaryDate.day} / "
          "${secondaryDate.month} / ${secondaryDate.year}" : ""}";
}

class FullDayHeaderTextConfig {
  /// Set full day events header text config
  const FullDayHeaderTextConfig({
    this.textAlign = TextAlign.center,
    this.maxLines = 2,
    this.textOverflow = TextOverflow.ellipsis,
  });

  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow textOverflow;
}
