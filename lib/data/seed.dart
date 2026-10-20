import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'models.dart';

/// Demo clock pinned to the design's date so every screenshot matches the Stitch frames.
final demoToday = DateTime(2026, 10, 21);

String dayKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Builds a streak ending yesterday, with a few misses further back.
Set<String> _history(int streak, {int span = 60, List<int> misses = const []}) {
  final out = <String>{};
  for (var i = 1; i <= span; i++) {
    if (i > streak && misses.contains(i)) continue;
    if (i == streak + 1) continue;
    out.add(dayKey(demoToday.subtract(Duration(days: i))));
  }
  return out;
}

final seedHabits = <Habit>[
  Habit(id: 'meditate', name: 'Meditate 10 min', icon: LucideIcons.flower2, bucket: TimeOfDayBucket.morning,
      history: _history(22, misses: [30, 41]), progressToday: 1, reminder: '7:00 AM'),
  Habit(id: 'read', name: 'Read 20 pages', icon: LucideIcons.bookOpen, bucket: TimeOfDayBucket.afternoon,
      history: _history(13, misses: [19, 27, 33]), progressToday: 1, reminder: '8:30 PM', notes: 'Before bed, paper books only'),
  Habit(id: 'nosocial', name: 'No social before 10am', icon: LucideIcons.shield, bucket: TimeOfDayBucket.morning,
      history: _history(7, misses: [12, 20]), progressToday: 1),
  Habit(id: 'water', name: 'Drink 2L water', icon: LucideIcons.droplet, bucket: TimeOfDayBucket.morning,
      history: _history(12, misses: [16]), target: 2, unit: 'L', progressToday: 1.2),
  Habit(id: 'workout', name: 'Workout 30 min', icon: LucideIcons.dumbbell, bucket: TimeOfDayBucket.evening,
      history: _history(5, misses: [9, 10, 14]), reminder: '6:30 PM'),
  Habit(id: 'journal', name: 'Journal', icon: LucideIcons.notebookPen, bucket: TimeOfDayBucket.evening,
      history: _history(19, misses: [25])),
];

const _ig = [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)];
const _tt = [Color(0xFF111111), Color(0xFF111111)];
const _yt = [Color(0xFFE62117), Color(0xFFB31217)];
const _x = [Color(0xFF14171A), Color(0xFF14171A)];

const seedApps = <BlockedApp>[
  BlockedApp('Instagram', 'Social & Media', LucideIcons.camera, _ig, limitMinutes: 30, usedMinutes: 22),
  BlockedApp('TikTok', 'Short Video', LucideIcons.circlePlay, _tt, limitMinutes: 15, usedMinutes: 9),
  BlockedApp('YouTube', 'Entertainment', LucideIcons.tvMinimalPlay, _yt, limitMinutes: 45, usedMinutes: 31),
  BlockedApp('X', 'Social', LucideIcons.atSign, _x),
];

const seedSchedules = <BlockSchedule>[
  BlockSchedule(id: 'morning', name: 'Morning Focus', start: '6:00 AM', end: '10:00 AM', days: 'Weekdays',
      apps: ['Instagram', 'TikTok', 'X'], activeNow: true, strict: true),
  BlockSchedule(id: 'work', name: 'Work Hours', start: '9:00 AM', end: '5:00 PM', days: 'Mon-Fri', apps: ['Instagram', 'TikTok', 'YouTube', 'X']),
  BlockSchedule(id: 'wind', name: 'Wind Down', start: '10:00 PM', end: '7:00 AM', days: 'Every day', apps: ['Instagram', 'TikTok', 'YouTube']),
];

/// Focus minutes per weekday (Mon..Sun) for Insights.
const focusWeek = [130, 150, 95, 0, 244, 120, 131];
const screenTimeSavedWeek = [20, 45, 60, 85, 120, 210, 312];

const goalOptions = [
  ('Less doomscrolling', 'assets/images/goal-less-doomscrolling.jpg'),
  ('Deep work', 'assets/images/goal-deep-work.jpg'),
  ('Morning routine', 'assets/images/goal-morning-routine.jpg'),
  ('Better sleep', 'assets/images/goal-better-sleep.jpg'),
  ('Exercise', 'assets/images/goal-exercise.jpg'),
  ('Reading', 'assets/images/goal-reading.jpg'),
];

const focusQuotes = [
  'You will never change your life until you change something you do daily.',
  'Small disciplines repeated with consistency lead to great achievements.',
];
