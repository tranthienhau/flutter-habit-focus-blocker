import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

Future<void> showAddHabitSheet(BuildContext context, {String? name}) => showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textPrimary.withValues(alpha: .45),
      builder: (_) => AddHabitSheet(initialName: name ?? 'Morning walk'),
    );

class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({super.key, required this.initialName});
  final String initialName;

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  late final _name = TextEditingController(text: widget.initialName);
  static const _icons = [LucideIcons.footprints, LucideIcons.bookOpen, LucideIcons.droplet, LucideIcons.dumbbell, LucideIcons.flower2, LucideIcons.notebookPen];
  static const _colors = [AppColors.accent, AppColors.support, Color(0xFF5E8C61), Color(0xFFE76F51), Color(0xFF3B82F6)];
  int _icon = 0, _color = 0, _goal = 30;
  Frequency _freq = Frequency.daily;
  TimeOfDayBucket _bucket = TimeOfDayBucket.morning;
  bool _remind = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .9),
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(3))),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              Expanded(child: Text('New habit', textAlign: TextAlign.center, style: AppText.display(size: 22))),
              TextButton(key: const Key('sheet-cancel'), onPressed: () => Navigator.pop(context), child: Text('Cancel', style: AppText.label(color: AppColors.textSecondary))),
            ]),
          ),
          Flexible(
            child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), children: [
              _label('HABIT NAME'),
              TextField(key: const Key('habit-name'), controller: _name, style: AppText.body()),
              _label('ICON'),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                for (var i = 0; i < _icons.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _icon = i),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _icon ? AppColors.accent : AppColors.surfaceAlt,
                      ),
                      child: Icon(_icons[i], size: 22, color: i == _icon ? Colors.white : AppColors.accent),
                    ),
                  ),
              ]),
              _label('COLOR'),
              Row(children: [
                for (var i = 0; i < _colors.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _color = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 14),
                      width: 34,
                      height: 34,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: i == _color ? _colors[i] : Colors.transparent, width: 2)),
                      child: Container(decoration: BoxDecoration(color: _colors[i], shape: BoxShape.circle),
                          child: i == _color ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null),
                    ),
                  ),
              ]),
              _label('FREQUENCY'),
              Segmented<Frequency>(
                values: Frequency.values,
                value: _freq,
                label: (f) => switch (f) { Frequency.daily => 'Daily', Frequency.weekdays => 'Weekdays', Frequency.custom => 'Custom' },
                onChanged: (f) => setState(() => _freq = f),
              ),
              _label('DAILY GOAL'),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(children: [
                  const Icon(LucideIcons.clock, size: 20, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Target duration', style: AppText.body())),
                  _round(LucideIcons.minus, () => setState(() => _goal = (_goal - 5).clamp(5, 180))),
                  SizedBox(width: 64, child: Text('$_goal min', textAlign: TextAlign.center, style: AppText.numerals(size: 15))),
                  _round(LucideIcons.plus, () => setState(() => _goal = (_goal + 5).clamp(5, 180))),
                ]),
              ),
              _label('TIME OF DAY'),
              Row(children: [
                for (final b in TimeOfDayBucket.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PillChip(b.label,
                        selected: b == _bucket,
                        icon: switch (b) { TimeOfDayBucket.morning => LucideIcons.sunrise, TimeOfDayBucket.afternoon => LucideIcons.sun, TimeOfDayBucket.evening => LucideIcons.moon },
                        onTap: () => setState(() => _bucket = b)),
                  ),
              ]),
              _label('NOTIFICATION'),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(children: [
                  const Icon(LucideIcons.bell, size: 20, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Daily reminder', style: AppText.body())),
                  Text('7:00 AM', style: AppText.numerals(size: 14)),
                  const SizedBox(width: 8),
                  Switch(value: _remind, onChanged: (v) => setState(() => _remind = v)),
                ]),
              ),
              const SizedBox(height: 20),
              PrimaryButton('Create habit', key: const Key('create-habit'), trailing: const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white), onTap: () {
                ref.read(habitsProvider.notifier).add(Habit(
                      id: 'h${DateTime.now().microsecondsSinceEpoch}',
                      name: _name.text.trim().isEmpty ? 'New habit' : _name.text.trim(),
                      icon: _icons[_icon],
                      bucket: _bucket,
                      frequency: _freq,
                      reminder: _remind ? '7:00 AM' : null,
                      history: const {},
                    ));
                Navigator.pop(context);
              }),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 10), child: Text(t, style: AppText.overline()));

  Widget _round(IconData i, VoidCallback onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
          child: Icon(i, size: 16, color: AppColors.accent),
        ),
      );
}
