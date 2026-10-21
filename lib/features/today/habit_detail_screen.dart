import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../data/seed.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = ref.watch(habitsProvider).firstWhere((e) => e.id == id);
    final streak = streakOf(h);
    final monthDays = DateTime(demoToday.year, demoToday.month + 1, 0).day;
    var monthDone = 0;
    for (var d = 1; d < demoToday.day; d++) {
      if (h.history.contains(dayKey(DateTime(demoToday.year, demoToday.month, d)))) monthDone++;
    }
    if (h.doneToday) monthDone++;
    final completion = (monthDone / demoToday.day * 100).round();
    final weekStart = demoToday.subtract(Duration(days: demoToday.weekday - 1));
    var week = h.doneToday ? 1 : 0;
    for (var d = weekStart; d.isBefore(demoToday); d = d.add(const Duration(days: 1))) {
      if (h.history.contains(dayKey(d))) week++;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 40), children: [
          Row(children: [
            IconButton(key: const Key('back'), onPressed: () => context.pop(), icon: const Icon(LucideIcons.chevronLeft)),
            IconTile(h.icon, size: 32),
            const SizedBox(width: 10),
            Expanded(child: Text(h.name, style: AppText.title(size: 19))),
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.ellipsis)),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 12),
              AppCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$streak', style: AppText.display(size: 64, color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(LucideIcons.flame, color: AppColors.support, size: 18),
                          const SizedBox(width: 4),
                          Text('day streak', style: AppText.title(size: 18)),
                        ]),
                        Text('Consistent since ${_since(streak)}', style: AppText.caption()),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Tag('Best ${bestStreakOf(h)}d', bg: const Color(0xFFFDF3DC), fg: AppColors.textPrimary, icon: LucideIcons.crown),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  Row(children: [
                    Text('October 2026', style: AppText.title(size: 18)),
                    const SizedBox(width: 8),
                    Tag('$monthDone days active', bg: AppColors.chip, fg: AppColors.textSecondary),
                    const Spacer(),
                    const Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary),
                  ]),
                  const SizedBox(height: 16),
                  _MonthGrid(habit: h, days: monthDays),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _legend(AppColors.accent, 'Completed'),
                    const SizedBox(width: 16),
                    _legend(AppColors.accentTint, 'Missed'),
                    const SizedBox(width: 16),
                    _legend(AppColors.support, 'Today', ring: true),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _Stat('COMPLETION', '$completion%', '+4%', AppColors.success)),
                const SizedBox(width: 10),
                Expanded(child: _Stat('TOTAL DAYS', '${h.history.length + (h.doneToday ? 1 : 0)}', 'All time', AppColors.textTertiary)),
                const SizedBox(width: 10),
                Expanded(child: _Stat('THIS WEEK', '$week/7', 'On track', AppColors.accent)),
              ]),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(children: [
                  _row(LucideIcons.bell, 'Reminder', h.reminder ?? 'Off'),
                  const Divider(color: AppColors.border, height: 1),
                  _row(LucideIcons.calendar, 'Frequency', h.frequency == Frequency.daily ? 'Daily' : 'Weekdays'),
                  const Divider(color: AppColors.border, height: 1),
                  _row(LucideIcons.notebookPen, 'Notes', h.notes ?? 'Add a note'),
                ]),
              ),
              const SizedBox(height: 20),
              SecondaryButton('Edit habit', icon: LucideIcons.squarePen, onTap: () {}),
              TextButton(onPressed: () {}, child: Text('Archive', style: AppText.label(color: AppColors.danger))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _legend(Color c, String l, {bool ring = false}) => Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: ring ? null : c, shape: BoxShape.circle, border: ring ? Border.all(color: c, width: 2) : null)),
        const SizedBox(width: 6),
        Text(l, style: AppText.caption()),
      ]);

  Widget _row(IconData i, String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(i, size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Text(l, style: AppText.label(weight: FontWeight.w400)),
          const SizedBox(width: 12),
          Expanded(child: Text(v, textAlign: TextAlign.end, style: AppText.label(), overflow: TextOverflow.ellipsis)),
        ]),
      );
}

String _since(int streak) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final d = demoToday.subtract(Duration(days: streak > 0 ? streak - 1 : 0));
  return '${m[d.month - 1]} ${d.day}';
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.habit, required this.days});
  final Habit habit;
  final int days;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(demoToday.year, demoToday.month, 1);
    final lead = first.weekday - 1;
    final cells = <Widget>[
      for (final l in 'MTWTFSS'.split('')) Center(child: Text(l, style: AppText.caption(color: AppColors.textTertiary))),
      for (var i = 0; i < lead; i++) const SizedBox(),
      for (var d = 1; d <= days; d++) _cell(DateTime(demoToday.year, demoToday.month, d)),
    ];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: cells,
    );
  }

  Widget _cell(DateTime d) {
    final isToday = d == demoToday;
    final future = d.isAfter(demoToday);
    final done = isToday ? habit.doneToday : habit.history.contains(dayKey(d));
    final bg = future ? Colors.transparent : (done ? AppColors.accent : AppColors.accentTint.withValues(alpha: .6));
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: isToday ? Border.all(color: AppColors.support, width: 2.5) : null,
      ),
      alignment: Alignment.center,
      child: Text('${d.day}', style: AppText.numerals(size: 12, color: future ? AppColors.textTertiary.withValues(alpha: .6) : (done ? Colors.white : AppColors.textSecondary))),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.sub, this.subColor);
  final String label, value, sub;
  final Color subColor;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(children: [
          Text(label, style: AppText.overline(color: AppColors.textTertiary).copyWith(fontSize: 10)),
          const SizedBox(height: 6),
          Text(value, style: value.contains('/') ? AppText.numerals(size: 24, weight: FontWeight.w900) : AppText.display(size: 24)),
          const SizedBox(height: 2),
          Text(sub, style: AppText.caption(color: subColor).copyWith(fontSize: 12)),
        ]),
      );
}
