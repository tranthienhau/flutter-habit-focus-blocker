import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/seed.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  bool _week = true;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final total = focusWeek.fold<int>(0, (a, b) => a + b);
    final weekStart = demoToday.subtract(Duration(days: demoToday.weekday - 1));
    int weekDone(h) {
      var n = h.doneToday ? 1 : 0;
      for (var d = weekStart; d.isBefore(demoToday); d = d.add(const Duration(days: 1))) {
        if (h.history.contains(dayKey(d))) n++;
      }
      return n;
    }

    final top = [...habits]..sort((a, b) => weekDone(b).compareTo(weekDone(a)));
    final completion = habits.isEmpty ? 0.0 : habits.map((h) => weekDone(h) / demoToday.weekday).reduce((a, b) => a + b) / habits.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: [
          Row(children: [
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.calendar, color: AppColors.textSecondary)),
            Expanded(child: Text('Insights', textAlign: TextAlign.center, style: AppText.display(size: 30))),
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.slidersHorizontal, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 12),
          Center(child: Segmented<bool>(values: const [true, false], value: _week, label: (v) => v ? 'Week' : 'Month', onChanged: (v) => setState(() => _week = v))),
          const SizedBox(height: 24),
          Center(child: Text('TOTAL TIME ACTIVE', style: AppText.overline(color: AppColors.textTertiary))),
          const SizedBox(height: 4),
          Center(child: Text(fmtHm(Duration(minutes: total)), key: const Key('insights-total'), style: AppText.display(size: 56, color: AppColors.accent))),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('focused this week', style: AppText.caption()),
            const SizedBox(width: 8),
            Tag('+22% vs last week', bg: AppColors.successTint, fg: AppColors.success, icon: LucideIcons.trendingUp),
          ]),
          const SizedBox(height: 20),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Focus hours', style: AppText.title(size: 18)),
                  Text('Daily breakdown', style: AppText.caption()),
                ]),
                const Spacer(),
                Text('${fmtHm(Duration(minutes: total ~/ 7))} / day', style: AppText.numerals(size: 13, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 18),
              SizedBox(height: 170, child: _Bars(values: focusWeek, highlight: 4)),
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(LucideIcons.shield, size: 20, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Screen time saved', style: AppText.title(size: 18)),
                const Spacer(),
                Tag('+45m today', bg: AppColors.successTint, fg: AppColors.success),
              ]),
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('5h 12m', style: AppText.display(size: 34, color: AppColors.accent)),
                const SizedBox(width: 8),
                Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('averted this week', style: AppText.caption())),
              ]),
              const SizedBox(height: 12),
              SizedBox(height: 90, width: double.infinity, child: CustomPaint(painter: _LinePainter(screenTimeSavedWeek))),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                for (final d in const ['Mon', 'Wed', 'Fri', 'Sun']) Text(d, style: AppText.caption(color: AppColors.textTertiary)),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Row(children: [
              ProgressRing(
                value: completion,
                size: 92,
                stroke: 9,
                child: Text('${(completion * 100).round()}%', style: AppText.display(size: 22)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Habit completion', style: AppText.title(size: 18)),
                  const SizedBox(height: 4),
                  Text('Across ${habits.length} habits this week. Best day: Friday.', style: AppText.caption()),
                ]),
              ),
            ]),
          ),
          const SectionHeader('Top habits'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              for (final (i, h) in top.take(3).indexed) ...[
                if (i > 0) const Divider(color: AppColors.border, height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    IconTile(h.icon, size: 36),
                    const SizedBox(width: 12),
                    Expanded(child: Text(h.name, style: AppText.label())),
                    Text('${weekDone(h)}/${demoToday.weekday}', style: AppText.numerals(size: 14)),
                  ]),
                ),
              ],
            ]),
          ),
          const SectionHeader('Most blocked'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              for (final (i, e) in [(seedApps[0], 18), (seedApps[1], 11), (seedApps[2], 6)].indexed) ...[
                if (i > 0) const Divider(color: AppColors.border, height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    AppTile(icon: e.$1.icon, colors: e.$1.tile, size: 36),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.$1.name, style: AppText.label())),
                    Text('${e.$2} attempts', style: AppText.numerals(size: 14, color: AppColors.textSecondary, weight: FontWeight.w400)),
                  ]),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.values, required this.highlight});
  final List<int> values;
  final int highlight;

  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b).toDouble();
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      for (var i = 0; i < values.length; i++)
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (i == highlight)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.support, borderRadius: BorderRadius.circular(6)),
                child: Text(fmtHm(Duration(minutes: values[i])), style: AppText.numerals(size: 10)),
              ),
            Flexible(
              child: FractionallySizedBox(
                heightFactor: values[i] == 0 ? .03 : values[i] / max,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: i == highlight ? AppColors.support : (values[i] == 0 ? AppColors.accentTint : AppColors.accent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('MTWTFSS'[i], style: AppText.caption(color: AppColors.textTertiary)),
          ]),
        ),
    ]);
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values);
  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final max = values.reduce((a, b) => a > b ? a : b).toDouble();
    final pts = [
      for (var i = 0; i < values.length; i++) Offset(size.width * i / (values.length - 1), size.height - (values[i] / max) * (size.height - 8) - 4),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final c = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final c2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      path.cubicTo(c.dx, c.dy, c2.dx, c2.dy, pts[i].dx, pts[i].dy);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.accent.withValues(alpha: .18), AppColors.accent.withValues(alpha: 0)])
              .createShader(Offset.zero & size));
    canvas.drawPath(path, Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(pts.last, 6, Paint()..color = AppColors.support);
    canvas.drawCircle(pts.last, 6, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_LinePainter o) => false;
}
