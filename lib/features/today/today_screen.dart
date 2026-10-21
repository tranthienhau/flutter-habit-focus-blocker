import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../data/seed.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'add_habit_sheet.dart';

const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _dateLabel(DateTime d) => '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final done = habits.where((h) => h.doneToday).length;
    return Scaffold(
      floatingActionButton: habits.isEmpty
          ? null
          : FloatingActionButton(
              key: const Key('add-habit'),
              backgroundColor: AppColors.support,
              foregroundColor: AppColors.textPrimary,
              elevation: 4,
              shape: const CircleBorder(),
              onPressed: () => showAddHabitSheet(context),
              child: const Icon(LucideIcons.plus, size: 28),
            ),
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 100), children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good morning, Maya', style: AppText.display(size: 28)),
                const SizedBox(height: 4),
                Text(_dateLabel(demoToday), style: AppText.body(color: AppColors.textSecondary)),
              ]),
            ),
            const Avatar(size: 52, dot: true),
          ]),
          const SizedBox(height: 20),
          if (habits.isEmpty) const _EmptyToday() else ...[
            _StreakCard(streak: ref.watch(overallStreakProvider), done: done, total: habits.length),
            const SizedBox(height: 16),
            _WeekStrip(habits: habits),
            SectionHeader('Habits', trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(999)),
              child: Text('$done of ${habits.length} completed', style: AppText.caption()),
            )),
            for (final h in habits) Padding(padding: const EdgeInsets.only(bottom: 12), child: _HabitRow(h)),
          ],
        ]),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak, required this.done, required this.total});
  final int streak, done, total;

  @override
  Widget build(BuildContext context) => Container(
        key: const Key('streak-card'),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(24), boxShadow: AppShadows.card),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Tag('CURRENT STREAK', bg: Colors.white.withValues(alpha: .1), fg: AppColors.support, icon: LucideIcons.flame),
              const SizedBox(height: 14),
              Text('$streak day streak', style: AppText.display(size: 30, color: Colors.white)),
              const SizedBox(height: 6),
              Text('Keep going, Maya!', style: AppText.body(color: Colors.white70)),
            ]),
          ),
          ProgressRing(
            value: total == 0 ? 0 : done / total,
            size: 76,
            stroke: 6,
            track: Colors.white.withValues(alpha: .15),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: '$done', style: AppText.display(size: 20, color: Colors.white)),
                TextSpan(text: '/$total', style: AppText.caption(color: Colors.white70)),
              ])),
              Text('DONE', style: AppText.overline(color: Colors.white70).copyWith(fontSize: 9)),
            ]),
          ),
        ]),
      );
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.habits});
  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final monday = demoToday.subtract(Duration(days: demoToday.weekday - 1));
    final allToday = habits.every((h) => h.doneToday);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        for (var i = 0; i < 7; i++)
          Builder(builder: (_) {
            final d = monday.add(Duration(days: i));
            final isToday = d == demoToday;
            final past = d.isBefore(demoToday);
            // A day counts when the anchor habit (first) was completed; today counts once 4+ are done.
            final hit = past ? habits.first.history.contains(dayKey(d)) : (isToday && (allToday || habits.where((h) => h.doneToday).length >= 4));
            return Column(children: [
              Text('MTWTFSS'[i], style: AppText.label(color: isToday ? AppColors.accent : AppColors.textTertiary)),
              const SizedBox(height: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hit ? AppColors.accent : AppColors.background,
                  border: Border.all(color: isToday ? AppColors.accent : AppColors.border, width: isToday ? 2 : 1),
                ),
                child: hit
                    ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                    : Center(child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle))),
              ),
              const SizedBox(height: 6),
              Text('${d.day}', style: AppText.caption(color: isToday ? AppColors.accent : AppColors.textSecondary).copyWith(fontWeight: isToday ? FontWeight.w700 : null)),
            ]);
          }),
      ]),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow(this.h);
  final Habit h;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = streakOf(h);
    return AppCard(
      key: Key('habit-${h.id}'),
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/today/habit/${h.id}'),
      child: Row(children: [
        IconTile(h.icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(h.name, style: AppText.title(size: 17))),
              if (h.isMeasured)
                Text('${h.progressToday.toStringAsFixed(1)} / ${h.target.toStringAsFixed(0)} ${h.unit}', style: AppText.numerals(size: 13)),
            ]),
            const SizedBox(height: 4),
            if (h.isMeasured) ...[
              LinearBar(value: h.ratio, height: 6, color: AppColors.support),
              const SizedBox(height: 6),
              Text('$streak day streak', style: AppText.caption()),
            ] else
              Text('$streak day streak  ·  ${h.bucket.label}', style: AppText.caption()),
          ]),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          key: Key('check-${h.id}'),
          onTap: () => ref.read(habitsProvider.notifier).toggle(h.id),
          child: h.isMeasured && !h.doneToday
              ? ProgressRing(value: h.ratio, size: 32, stroke: 3, child: Text('${(h.ratio * 100).round()}%', style: AppText.numerals(size: 9)))
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: h.doneToday ? AppColors.accent : Colors.transparent,
                    border: Border.all(color: h.doneToday ? AppColors.accent : AppColors.accentTint, width: 2),
                  ),
                  child: h.doneToday ? const Icon(LucideIcons.check, size: 18, color: Colors.white) : null,
                ),
        ),
      ]),
    );
  }
}

class _EmptyToday extends ConsumerWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(children: [
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: AspectRatio(aspectRatio: 1.3, child: Image.asset('assets/images/empty-notebook.jpg', fit: BoxFit.cover)),
        ),
        const SizedBox(height: 28),
        Text('Your first habit starts here', textAlign: TextAlign.center, style: AppText.display(size: 26)),
        const SizedBox(height: 10),
        Text('Small daily wins build big streaks. Add one habit to begin.', textAlign: TextAlign.center, style: AppText.body(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        PrimaryButton('Add a habit', key: const Key('empty-add-habit'), icon: LucideIcons.plus, onTap: () => showAddHabitSheet(context)),
        const SizedBox(height: 28),
        Text('QUICK SUGGESTIONS', style: AppText.overline(color: AppColors.textTertiary)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          for (final s in const ['Meditate', 'Read', 'Walk', 'No phone in bed']) PillChip(s, onTap: () => showAddHabitSheet(context, name: s)),
        ]),
      ]);
}
