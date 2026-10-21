import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../data/seed.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class BlocksScreen extends ConsumerWidget {
  const BlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(blocksProvider);
    final n = ref.read(blocksProvider.notifier);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          Row(children: [
            Text('Blocks', style: AppText.display(size: 32)),
            const Spacer(),
            Material(
              color: Colors.white,
              shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
              child: IconButton(key: const Key('new-block'), onPressed: () => context.push('/blocks/edit/morning'), icon: const Icon(LucideIcons.plus, color: AppColors.accent)),
            ),
          ]),
          const SizedBox(height: 16),
          if (b.schedules.isEmpty) const _EmptyBlocks() else ...[
            const _ScreenTimeCard(),
            SectionHeader('Schedules', badge: '${b.schedules.where((s) => s.enabled).length} active',
                trailing: Text('Edit', style: AppText.label(color: AppColors.textSecondary, weight: FontWeight.w400))),
            for (final s in b.schedules)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  key: Key('schedule-${s.id}'),
                  padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
                  onTap: () => context.push('/blocks/edit/${s.id}'),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Flexible(child: Text(s.name, style: AppText.title(size: 18))),
                          if (s.activeNow && s.enabled) ...[const SizedBox(width: 8), const Tag('ACTIVE NOW')],
                        ]),
                        const SizedBox(height: 4),
                        Text('${s.start} - ${s.end}  ·  ${s.days}', style: AppText.caption()),
                      ]),
                    ),
                    Switch(value: s.enabled, onChanged: (v) => n.setEnabled(s.id, v)),
                  ]),
                ),
              ),
            SectionHeader('App limits', trailing: Text('${b.apps.where((a) => a.limitMinutes != null).length} configured', style: AppText.caption(color: AppColors.textTertiary))),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(children: [
                for (final (i, a) in b.apps.where((a) => a.limitMinutes != null).indexed) ...[
                  if (i > 0) const Divider(color: AppColors.border, height: 1),
                  _LimitRow(a),
                ],
              ]),
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(children: [
                const IconTile(LucideIcons.lock, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Strict mode', style: AppText.title(size: 17)),
                    Text('Blocks cannot be turned off early', style: AppText.caption()),
                  ]),
                ),
                Switch(value: b.strictMode, onChanged: n.setStrict),
              ]),
            ),
            const SizedBox(height: 14),
            SecondaryButton('Preview shield (open Instagram)', key: const Key('preview-shield'), icon: LucideIcons.eye, onTap: () => context.push('/shield')),
          ],
        ]),
      ),
    );
  }
}

class _ScreenTimeCard extends StatelessWidget {
  const _ScreenTimeCard();

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Screen time today', style: AppText.body(color: AppColors.textSecondary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFFBEFF3), borderRadius: BorderRadius.circular(999)),
              child: Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.support, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('2h 00m limit', style: AppText.caption()),
              ]),
            ),
          ]),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('1h 52m', key: const Key('screen-time-today'), style: AppText.display(size: 46, color: AppColors.accent)),
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('used', style: AppText.caption())),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tag('48 min less', bg: AppColors.successTint, fg: AppColors.success, icon: LucideIcons.arrowDown),
            ),
          ]),
          const SizedBox(height: 12),
          const LinearBar(value: .93, height: 8, gradient: AppColors.progressGradient),
          const SizedBox(height: 10),
          Row(children: [
            Text('93% of daily cap', style: AppText.caption()),
            const Spacer(),
            Text('8 min remaining', style: AppText.label()),
          ]),
        ]),
      );
}

class _LimitRow extends StatelessWidget {
  const _LimitRow(this.a);
  final BlockedApp a;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Row(children: [
            AppTile(icon: a.icon, colors: a.tile),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.name, style: AppText.title(size: 16)),
                Text(a.category, style: AppText.caption()),
              ]),
            ),
            Text('${a.usedMinutes} of ${a.limitMinutes} min', style: AppText.numerals(size: 14)),
          ]),
          const SizedBox(height: 12),
          LinearBar(value: a.usedMinutes / a.limitMinutes!, height: 7),
        ]),
      );
}

class _EmptyBlocks extends ConsumerWidget {
  const _EmptyBlocks();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: AspectRatio(aspectRatio: 1.25, child: Image.asset('assets/images/phone-face-down-desk.jpg', fit: BoxFit.cover)),
        ),
        const SizedBox(height: 26),
        Text('Take back your attention', textAlign: TextAlign.center, style: AppText.display(size: 26)),
        const SizedBox(height: 10),
        Text('Create a schedule to block distracting apps when it matters most.', textAlign: TextAlign.center, style: AppText.body(color: AppColors.textSecondary)),
        const SizedBox(height: 22),
        PrimaryButton('Create your first block', key: const Key('first-block'), icon: LucideIcons.circlePlus, onTap: () => ref.read(blocksProvider.notifier).reset()),
        const SizedBox(height: 28),
        Row(children: [
          Text('START FROM A TEMPLATE', style: AppText.overline(color: AppColors.textTertiary)),
          const Spacer(),
          Text('3 presets', style: AppText.caption(color: AppColors.textTertiary)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          for (final (i, t) in const [(LucideIcons.sun, 'Morning', '7 - 10 AM'), (LucideIcons.briefcase, 'Work hours', '9 - 5 PM'), (LucideIcons.moon, 'Bedtime', '10 PM - 7 AM')].indexed) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                onTap: () => ref.read(blocksProvider.notifier).reset(),
                child: Column(children: [
                  IconTile(t.$1, size: 40),
                  const SizedBox(height: 10),
                  Text(t.$2, style: AppText.label()),
                  Text(t.$3, style: AppText.caption(color: AppColors.textTertiary).copyWith(fontSize: 11)),
                ]),
              ),
            ),
          ],
        ]),
      ]);
}

class BlockEditorScreen extends ConsumerStatefulWidget {
  const BlockEditorScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<BlockEditorScreen> createState() => _BlockEditorScreenState();
}

class _BlockEditorScreenState extends ConsumerState<BlockEditorScreen> {
  late BlockSchedule _s = ref.read(blocksProvider).schedules.firstWhere((e) => e.id == widget.id, orElse: () => seedSchedules.first);
  final _days = {0, 1, 2, 3, 4};
  String _category = 'Social';
  bool _block = true;

  @override
  Widget build(BuildContext context) {
    final apps = seedApps.where((a) => _s.apps.contains(a.name)).toList();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          SizedBox(
            height: 52,
            child: Row(children: [
              TextButton(key: const Key('editor-cancel'), onPressed: () => context.pop(), child: Text('Cancel', style: AppText.label(color: AppColors.textSecondary, weight: FontWeight.w400))),
              Expanded(child: Text(_s.name, textAlign: TextAlign.center, style: AppText.title(size: 18))),
              TextButton(onPressed: () => context.pop(), child: Text('Save', style: AppText.label(color: AppColors.accent))),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const IconTile(LucideIcons.sunrise, size: 48, bg: Color(0xFFFDF3DC), fg: Color(0xFFB7831A)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(_s.name, style: AppText.display(size: 20)),
                        const SizedBox(width: 6),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                      ]),
                      Text('Active ${_s.days} · ${_s.start} - ${_s.end}', style: AppText.caption()),
                    ]),
                  ),
                  const Icon(LucideIcons.pencil, size: 18, color: AppColors.textSecondary),
                ]),
              ),
              _label('APPS TO BLOCK', '${apps.length} restricted'),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // On device this opens Apple's FamilyActivityPicker; tokens come back opaque.
                  Row(children: [
                    const Icon(LucideIcons.shield, size: 20, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Choose apps', style: AppText.body())),
                    Tag('${apps.length} selected', bg: AppColors.chip, fg: AppColors.accent),
                    const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary),
                  ]),
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final c in const ['Social', 'Entertainment', 'Games'])
                      PillChip(c, selected: c == _category, icon: c == _category ? LucideIcons.check : null, onTap: () => setState(() => _category = c)),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.control), border: Border.all(color: AppColors.border)),
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final a in apps)
                        Container(
                          padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.border)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            AppTile(icon: a.icon, colors: a.tile, size: 22),
                            const SizedBox(width: 6),
                            Text(a.name, style: AppText.label()),
                            const SizedBox(width: 6),
                            const Icon(LucideIcons.x, size: 14, color: AppColors.textTertiary),
                          ]),
                        ),
                    ]),
                  ),
                ]),
              ),
              _label('SCHEDULE', 'Daily automation'),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Segmented<bool>(values: const [true, false], value: _block, label: (v) => v ? 'Block' : 'Limit', onChanged: (v) => setState(() => _block = v)),
                  const SizedBox(height: 16),
                  _timeRow('Start', _s.start),
                  const SizedBox(height: 10),
                  _timeRow('End', _s.end),
                  const SizedBox(height: 16),
                  Row(children: [
                    Text('Repeat', style: AppText.body()),
                    const Spacer(),
                    Text('Every weekday', style: AppText.caption()),
                  ]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    for (var i = 0; i < 7; i++)
                      GestureDetector(
                        onTap: () => setState(() => _days.contains(i) ? _days.remove(i) : _days.add(i)),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _days.contains(i) ? AppColors.accent : AppColors.chip),
                          alignment: Alignment.center,
                          child: Text('MTWTFSS'[i], style: AppText.label(color: _days.contains(i) ? Colors.white : AppColors.textTertiary)),
                        ),
                      ),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(children: [
                  const IconTile(LucideIcons.lock, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Strict mode', style: AppText.label()),
                      Text('Cannot be turned off until it ends', style: AppText.caption()),
                    ]),
                  ),
                  Switch(value: _s.strict, onChanged: (v) => setState(() => _s = _s.copyWith(strict: v))),
                ]),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const IconTile(LucideIcons.hourglass, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Break allowance', style: AppText.label()),
                      Text('${_s.breaks} x 5 min unlock', style: AppText.caption()),
                    ]),
                  ),
                  IconButton(onPressed: () => setState(() => _s = _s.copyWith(breaks: (_s.breaks - 1).clamp(0, 5))), icon: const Icon(LucideIcons.minus, size: 18)),
                  Text('${_s.breaks}', style: AppText.numerals(size: 16)),
                  IconButton(onPressed: () => setState(() => _s = _s.copyWith(breaks: (_s.breaks + 1).clamp(0, 5))), icon: const Icon(LucideIcons.plus, size: 18)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t, String r) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Row(children: [Text(t, style: AppText.overline()), const Spacer(), Text(r, style: AppText.caption(color: AppColors.textTertiary))]),
      );

  Widget _timeRow(String l, String v) => Row(children: [
        Text(l, style: AppText.body()),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
          child: Text(v, style: AppText.numerals(size: 15)),
        ),
      ]);
}

/// In-app preview of the ShieldConfiguration extension UI that iOS shows over a blocked app.
class ShieldScreen extends ConsumerWidget {
  const ShieldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(blocksProvider);
    final n = ref.read(blocksProvider.notifier);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF4A154B), Color(0xFF6B2A5E)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              const SizedBox(height: 40),
              Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: Image.asset('assets/brand/mark.png'),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(width: 20, height: 20, decoration: BoxDecoration(color: AppColors.support, shape: BoxShape.circle, border: Border.all(color: AppColors.accent, width: 3))),
                ),
              ]),
              const SizedBox(height: 28),
              Text('Instagram is blocked', textAlign: TextAlign.center, style: AppText.display(size: 32, color: Colors.white)),
              const SizedBox(height: 10),
              Text('Morning Focus ends at 10:00 AM', style: AppText.body(color: Colors.white.withValues(alpha: .8))),
              const SizedBox(height: 14),
              Tag('DEEP WORK PROTOCOL', bg: Colors.white.withValues(alpha: .1), fg: AppColors.support),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: Colors.white.withValues(alpha: .12)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(LucideIcons.quote, color: AppColors.support, size: 26),
                    const Spacer(),
                    Text('DAILY PROMPT', style: AppText.overline(color: AppColors.support)),
                  ]),
                  const SizedBox(height: 12),
                  Text('"${focusQuotes.first}"', style: AppText.title(color: Colors.white, size: 18).copyWith(fontWeight: FontWeight.w400, height: 1.4)),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: Text('John C. Maxwell', style: AppText.caption(color: Colors.white60))),
                ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .06), borderRadius: BorderRadius.circular(AppRadius.control)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(LucideIcons.shieldCheck, size: 18, color: AppColors.support),
                  const SizedBox(width: 8),
                  Text.rich(TextSpan(children: [
                    const TextSpan(text: 'You have resisted '),
                    TextSpan(text: '${b.resisted} times', style: const TextStyle(color: AppColors.support, fontWeight: FontWeight.w700)),
                    const TextSpan(text: ' today'),
                  ]), style: AppText.caption(color: Colors.white)),
                ]),
              ),
              const Spacer(),
              PrimaryButton('Close app', key: const Key('shield-close'), light: true, trailing: const Icon(LucideIcons.arrowRight, size: 18, color: AppColors.accent), onTap: () {
                n.resist();
                context.pop();
              }),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: b.unlocksLeft == 0
                    ? null
                    : () {
                        n.useUnlock();
                        context.pop();
                      },
                icon: const Icon(LucideIcons.hourglass, size: 16, color: Colors.white70),
                label: Text('Unlock for 5 min (${b.unlocksLeft} left)', style: AppText.label(color: Colors.white70, weight: FontWeight.w400)),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }
}
