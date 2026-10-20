import 'package:flutter/widgets.dart';

enum TimeOfDayBucket { morning, afternoon, evening }

extension TimeOfDayBucketLabel on TimeOfDayBucket {
  String get label => switch (this) {
        TimeOfDayBucket.morning => 'Morning',
        TimeOfDayBucket.afternoon => 'Afternoon',
        TimeOfDayBucket.evening => 'Evening',
      };
}

enum Frequency { daily, weekdays, custom }

/// A habit is either a checkbox (target 1) or a measured goal (e.g. 2.0 L of water).
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.bucket,
    required this.history,
    this.target = 1,
    this.unit,
    this.progressToday = 0,
    this.frequency = Frequency.daily,
    this.reminder,
    this.notes,
  });

  final String id;
  final String name;
  final IconData icon;
  final TimeOfDayBucket bucket;
  final double target;
  final String? unit;
  final double progressToday;
  final Frequency frequency;
  final String? reminder;
  final String? notes;

  /// Completed dates (yyyy-mm-dd) before today.
  final Set<String> history;

  bool get isMeasured => unit != null;
  bool get doneToday => progressToday >= target;
  double get ratio => (progressToday / target).clamp(0, 1).toDouble();

  Habit copyWith({double? progressToday, Set<String>? history}) => Habit(
        id: id,
        name: name,
        icon: icon,
        bucket: bucket,
        target: target,
        unit: unit,
        progressToday: progressToday ?? this.progressToday,
        frequency: frequency,
        reminder: reminder,
        notes: notes,
        history: history ?? this.history,
      );
}

/// A distracting app as surfaced by Screen Time. On iOS the real app identity is an opaque
/// ApplicationToken from FamilyActivityPicker; the POC keeps a display name and brand tile.
class BlockedApp {
  const BlockedApp(this.name, this.category, this.icon, this.tile, {this.limitMinutes, this.usedMinutes = 0});
  final String name;
  final String category;
  final IconData icon;
  final List<Color> tile;
  final int? limitMinutes;
  final int usedMinutes;
}

class BlockSchedule {
  const BlockSchedule({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.days,
    required this.apps,
    this.enabled = true,
    this.activeNow = false,
    this.strict = false,
    this.breaks = 1,
  });

  final String id;
  final String name;
  final String start;
  final String end;
  final String days;
  final List<String> apps;
  final bool enabled;
  final bool activeNow;
  final bool strict;
  final int breaks;

  BlockSchedule copyWith({bool? enabled, bool? strict, int? breaks}) => BlockSchedule(
        id: id,
        name: name,
        start: start,
        end: end,
        days: days,
        apps: apps,
        enabled: enabled ?? this.enabled,
        activeNow: activeNow,
        strict: strict ?? this.strict,
        breaks: breaks ?? this.breaks,
      );
}

enum FocusMode { timer, stopwatch }

enum FocusPhase { idle, running, paused, done }
