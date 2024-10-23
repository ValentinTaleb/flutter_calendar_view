// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'enumerations.dart';
import 'typedefs.dart';

/// Settings for hour lines
class HourIndicatorSettings {
  final double height;
  final Color color;
  final double offset;
  final LineStyle lineStyle;
  final double dashWidth;
  final double dashSpaceWidth;
  final int startHour;

  /// Settings for hour lines
  const HourIndicatorSettings(
      {this.height = 1.0,
      this.offset = 0.0,
      this.color = Colors.grey,
      this.lineStyle = LineStyle.solid,
      this.dashWidth = 4,
      this.dashSpaceWidth = 4,
      this.startHour = 0})
      : assert(height >= 0, "Height must be greater than or equal to 0.");

  factory HourIndicatorSettings.none() => HourIndicatorSettings(
        color: Colors.transparent,
        height: 0.0,
      );
}

/// Settings for live time line
class LiveTimeIndicatorSettings {
  /// Color of time indicator.
  final Color color;

  /// Height of time indicator.
  final double height;

  /// offset of time indicator.
  final double offset;

  /// StringProvider for time string
  final StringProvider? timeStringBuilder;

  /// Flag to show bullet at left side or not.
  final bool showBullet;

  /// Flag to show time on live time line.
  final bool showTime;

  /// Flag to show time backgroud view.
  final bool showTimeBackgroundView;

  /// Radius of bullet.
  final double bulletRadius;

  /// Width of time backgroud view.
  final double timeBackgroundViewWidth;

  /// Settings for live time line
  const LiveTimeIndicatorSettings({
    this.height = 1.0,
    this.offset = 5.0,
    this.color = Colors.grey,
    this.timeStringBuilder,
    this.showBullet = true,
    this.showTime = false,
    this.showTimeBackgroundView = false,
    this.bulletRadius = 5.0,
    this.timeBackgroundViewWidth = 60.0,
  }) : assert(height >= 0, "Height must be greater than or equal to 0.");

  factory LiveTimeIndicatorSettings.none() => LiveTimeIndicatorSettings(
        color: Colors.transparent,
        height: 0.0,
        offset: 0.0,
        showBullet: false,
      );
}

/// Set `frequency = RepeatFrequency.daily` to repeat every day after current date & event day.
/// Set `frequency = RepeatFrequency.weekly` & provide list of weekdays to repeat on.
/// [startDate]: Defines start date of repeating events.
/// [endDate]: Defines end date of repeating events.
/// [interval]: Defines repetition of event after given [interval] in days.
/// [frequency]: Defines repeat daily, weekly, monthly or yearly.
/// [weekdays]: Contains list of weekdays to repeat starting from 0 index.
/// By default weekday of event is considered if not provided.
class RecurrenceSettings {
  final DateTime startDate;
  late DateTime? endDate; // TODO(Shubham): Review
  final int? interval;
  final RepeatFrequency frequency;
  final RecurrenceEnd recurrenceEndOn;
  final List<int> weekdays;
  final List<DateTime>? excludeDates;

  DateTime get _endDateMonthly {
    final occurrences = interval ?? 1;
    return DateTime(
      startDate.year,
      startDate.month + (occurrences - 1),
      startDate.day,
    );
  }

  /// Returns the calculated end date for the selected weekdays and occurrences,
  /// or null if the conditions are not met.
  ///
  /// This method calculates the end date for a recurring event based on the selected weekdays and the specified occurrences.
  /// It iterates through the dates starting from the start date and counts the occurrences of the selected weekdays until the target occurrence is met.
  ///
  /// Example: If the start date is 12-11-24 (Tuesday), and the selected weekdays are [Tuesday, Wednesday] for 3 occurrences,
  /// the event will repeat on 12-11-24, 13-11-24, and 19-11-24.
  ///
  DateTime? get _endDateWeekly {
    if (weekdays.isEmpty) {
      return null;
    }

    DateTime nextDate = startDate;
    final targetOccurrence = interval ?? 1;
    int occurrences = 0;

    while (occurrences < targetOccurrence) {
      if (weekdays.contains((nextDate.weekday - 1) % 7)) {
        occurrences++;
      }
      nextDate = nextDate.add(Duration(days: 1));
    }
    return nextDate.subtract(Duration(days: 1));
  }

  RecurrenceSettings({
    required this.startDate,
    this.endDate,
    this.interval,
    this.frequency = RepeatFrequency.weekly,
    this.recurrenceEndOn = RecurrenceEnd.never,
    this.excludeDates,
    List<int>? weekdays,
  }) : weekdays = weekdays ?? [startDate.weekday];

  // TODO(Shubham): Add asserts
  // Set by calculating end date for daily
  // Ex. If current date is 11-11-24 and interval is 5 then new end date will be
  // 15-11-24. Interval - 1 is added because event has been already occurred once on start date.

  // Set by calculating end date for weekly
  // Ex. If current date is 1-11-24 and interval is 5 then new end date will be 29-11-24.
  RecurrenceSettings.withCalculatedEndDate({
    required this.startDate,
    required DateTime endDate,
    this.interval,
    this.frequency = RepeatFrequency.weekly,
    this.recurrenceEndOn = RecurrenceEnd.never,
    this.excludeDates,
    List<int>? weekdays,
  }) : weekdays = weekdays ?? [startDate.weekday] {
    this.endDate = _getEndDate(endDate);
  }

  /// Determines the end date for a recurring event based on the
  /// `RepeatFrequency` & `RecurrenceEnd`.
  ///
  /// Returns null if the end date is not applicable.
  /// For example: An event that does not repeat and event that never ends.
  DateTime? _getEndDate(DateTime endDate) {
    if (frequency == RepeatFrequency.doNotRepeat ||
        recurrenceEndOn == RecurrenceEnd.never) {
      return null;
    }

    if (recurrenceEndOn == RecurrenceEnd.on &&
        (frequency == RepeatFrequency.daily ||
            frequency == RepeatFrequency.weekly ||
            frequency == RepeatFrequency.monthly)) {
      return endDate;
    }

    if (recurrenceEndOn == RecurrenceEnd.after) {
      return _handleOccurrence(endDate);
    }
    return null;
  }

  // Finds the end date to repeat and event for the given number of occurrences
  DateTime? _handleOccurrence(DateTime endDate) {
    final occurrence = interval ?? 1;
    if (occurrence <= 1) {
      return endDate;
    }
    switch (frequency) {
      case RepeatFrequency.doNotRepeat:
        return null;
      case RepeatFrequency.daily:
        return endDate.add(Duration(days: occurrence - 1));
      case RepeatFrequency.weekly:
        return _endDateWeekly ?? endDate;
      case RepeatFrequency.monthly:
        return _endDateMonthly;
      case RepeatFrequency.yearly:
        // TODO(Shubham): Implement end date for yearly recurrence event
        return null;
    }
  }

  @override
  String toString() {
    return "start date: ${startDate}, "
        "end date: ${endDate}, "
        "interval: ${interval}, "
        "frequency: ${frequency} "
        "weekdays: ${weekdays.toString()}"
        "recurrence Ends on: ${recurrenceEndOn}"
        "exclude dates: ${excludeDates}";
  }

  RecurrenceSettings copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? interval,
    RepeatFrequency? frequency,
    RecurrenceEnd? recurrenceEndOn,
    List<int>? weekdays,
    List<DateTime>? excludeDates,
  }) {
    return RecurrenceSettings(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      interval: interval ?? this.interval,
      frequency: frequency ?? this.frequency,
      recurrenceEndOn: recurrenceEndOn ?? this.recurrenceEndOn,
      weekdays: weekdays ?? this.weekdays,
      excludeDates: excludeDates ?? this.excludeDates,
    );
  }
}
