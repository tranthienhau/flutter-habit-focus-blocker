import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../data/seed.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(focusProvider);
    final n = ref.read(focusProvider.notifier);
    final timer = f.mode == FocusMode.timer;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
          Row(children: [
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.rotateCcw, color: AppColors.textSecondary)),
            Expanded(child: Text('Focus', textAlign: TextAlign.center, style: AppText.display(size: 30))),
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 12),
          Center(
            child: Segmented<FocusMode>(
              values: FocusMode.values,
              value: f.mode,
              label: (m) => m == FocusMode.timer ? 'Timer' : 'Stopwatch',
              onChanged: n.setMode,
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: ProgressRing(
              value: timer ? f.duration.inMinutes / 90 : 0,
              size: 260,
              stroke: 14,
              color: AppColors.support,
              track: AppColors.accentTint,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(timer ? fmtClock(f.duration) : '00:00', style: AppText.display(size: 60, color: AppColors.accent)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(f.label, style: AppText.caption(color: AppColors.accent).copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(LucideIcons.pencil, size: 13, color: AppColors.accent),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          if (timer)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final m in const [15, 25, 50, 90])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: PillChip('${m}m', key: Key('dur-$m'), selected: f.duration.inMinutes == m, onTap: () => n.setDuration(m)),
                ),
            ])
          else
            Center(child: Text('Count up until you stop. Great for open-ended deep work.', style: AppText.caption())),
          const SizedBox(height: 24),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const IconTile(LucideIcons.shield, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Block distracting apps during session', style: AppText.label()),
                  const SizedBox(height: 2),
                  Text('Social, Games and 4 apps', style: AppText.caption()),
                ]),
              ),
              Switch(key: const Key('focus-block-toggle'), value: f.blockApps, onChanged: n.setBlockApps),
            ]),
          ),
          const SizedBox(height: 20),
          PrimaryButton('Start focus', key: const Key('start-focus'), icon: LucideIcons.play, onTap: () {
            n.start();
            context.push('/focus/live');
          }),
          const SizedBox(height: 14),
          Center(child: Text('${fmtHm(f.focusedToday)} focused today', style: AppText.caption())),
        ]),
      ),
    );
  }
}

class FocusLiveScreen extends ConsumerWidget {
  const FocusLiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(focusProvider);
    final n = ref.read(focusProvider.notifier);
    ref.listen(focusProvider.select((s) => s.phase), (_, p) {
      if (p == FocusPhase.done) context.pushReplacement('/focus/complete');
    });
    final timer = f.mode == FocusMode.timer;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A154B), Color(0xFF5A1F55), Color(0xFF6B2A5E)],
          ),
        ),
        child: Stack(children: [
          Positioned(
            bottom: -120,
            left: -60,
            right: -60,
            child: Container(
              height: 320,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.support.withValues(alpha: .22), Colors.transparent])),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                Row(children: [
                  _glassIcon(LucideIcons.x, () {
                    n.reset();
                    context.pop();
                  }),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
                    child: Row(children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.support, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(f.label, style: AppText.label(color: Colors.white)),
                    ]),
                  ),
                  const Spacer(),
                  _glassIcon(LucideIcons.ellipsis, () {}),
                ]),
                const Spacer(),
                ProgressRing(
                  key: const Key('live-ring'),
                  value: timer ? f.progress : (f.elapsed.inSeconds % 60) / 60,
                  size: 280,
                  stroke: 10,
                  track: Colors.white.withValues(alpha: .12),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(f.phase == FocusPhase.paused ? 'PAUSED' : 'FOCUSING', style: AppText.overline(color: AppColors.support).copyWith(letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Text(fmtClock(f.remaining), key: const Key('live-clock'), style: AppText.display(size: 68, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(timer ? 'of ${fmtClock(f.duration)}' : 'stopwatch', style: AppText.caption(color: Colors.white60)),
                  ]),
                ),
                const Spacer(),
                _glass(Row(children: [
                  const Icon(LucideIcons.cloudRain, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Rain', style: AppText.label(color: Colors.white)),
                      Text('Binaural layer 45%', style: AppText.caption(color: Colors.white60)),
                    ]),
                  ),
                  SizedBox(width: 80, child: LinearBar(value: .45, height: 4, color: AppColors.support)),
                  const SizedBox(width: 10),
                  const Icon(LucideIcons.waves, color: Colors.white70, size: 18),
                ])),
                const SizedBox(height: 12),
                if (f.blockApps)
                  _glass(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(LucideIcons.shieldCheck, color: AppColors.support, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('4 apps blocked', style: AppText.label(color: Colors.white)),
                          Text('Strict distraction shield active', style: AppText.caption(color: Colors.white60)),
                        ]),
                      ),
                      Tag('Locked', bg: AppColors.success.withValues(alpha: .2), fg: const Color(0xFF86EFAC)),
                    ]),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final a in seedApps)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(999)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: a.tile.first == const Color(0xFF111111) || a.tile.first == const Color(0xFF14171A) ? Colors.white : a.tile[1], shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(a.name, style: AppText.caption(color: Colors.white)),
                          ]),
                        ),
                    ]),
                  ])),
                const SizedBox(height: 22),
                PrimaryButton(f.phase == FocusPhase.paused ? 'Resume' : 'Pause', key: const Key('pause'), light: true,
                    icon: f.phase == FocusPhase.paused ? LucideIcons.play : LucideIcons.pause,
                    onTap: f.phase == FocusPhase.paused ? n.resume : n.pause),
                const SizedBox(height: 12),
                SecondaryButton('End session', key: const Key('end-session'), onDark: true, onTap: n.finish),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _glass(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Colors.white.withValues(alpha: .12)),
        ),
        child: child,
      );

  Widget _glassIcon(IconData i, VoidCallback onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), shape: BoxShape.circle),
          child: Icon(i, color: Colors.white, size: 20),
        ),
      );
}

class FocusCompleteScreen extends ConsumerStatefulWidget {
  const FocusCompleteScreen({super.key});

  @override
  ConsumerState<FocusCompleteScreen> createState() => _FocusCompleteScreenState();
}

class _FocusCompleteScreenState extends ConsumerState<FocusCompleteScreen> {
  int _rating = 4;

  @override
  Widget build(BuildContext context) {
    final f = ref.watch(focusProvider);
    final minutes = (f.elapsed.inSeconds / 60).round();
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          TopBar(
            title: 'Session Summary',
            onBack: () {
              ref.read(focusProvider.notifier).reset();
              context.pop();
            },
            trailing: const Icon(LucideIcons.share2, size: 20, color: AppColors.textSecondary),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: AspectRatio(aspectRatio: 1.75, child: Image.asset('assets/images/sunlit-desk-plant.jpg', fit: BoxFit.cover)),
              ),
              const SizedBox(height: 22),
              Text('Session complete', textAlign: TextAlign.center, style: AppText.display(size: 30)),
              const SizedBox(height: 4),
              Text('$minutes min', key: const Key('complete-minutes'), textAlign: TextAlign.center, style: AppText.display(size: 52, color: AppColors.accent)),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'focused on '),
                  TextSpan(text: f.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
                textAlign: TextAlign.center,
                style: AppText.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _mini(LucideIcons.shield, '${f.blockedAttempts}', 'blocked\nattempts')),
                const SizedBox(width: 10),
                Expanded(child: _mini(LucideIcons.flame, '${f.focusStreak} day', 'focus\nstreak', gold: true)),
                const SizedBox(width: 10),
                Expanded(child: _mini(LucideIcons.clock, fmtHm(f.focusedToday), 'focused\ntoday')),
              ]),
              const SizedBox(height: 14),
              AppCard(
                child: Column(children: [
                  Text('How was your focus?', style: AppText.title(size: 17)),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    for (var i = 1; i <= 5; i++)
                      GestureDetector(
                        onTap: () => setState(() => _rating = i),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _rating ? AppColors.accent : Colors.transparent,
                            border: Border.all(color: i == _rating ? AppColors.accent : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text('$i', style: AppText.numerals(size: 15, color: i == _rating ? Colors.white : AppColors.textSecondary)),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('Distracted', style: AppText.caption(color: AppColors.textTertiary)),
                    const Spacer(),
                    Text('Flow state', style: AppText.caption(color: AppColors.textTertiary)),
                  ]),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Column(children: [
              PrimaryButton('Done', key: const Key('complete-done'), onTap: () {
                ref.read(focusProvider.notifier).reset();
                context.pop();
              }),
              const SizedBox(height: 10),
              SecondaryButton('Take a 5 min break', onTap: () {}),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _mini(IconData i, String v, String l, {bool gold = false}) => AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(children: [
          Icon(i, size: 20, color: gold ? AppColors.support : AppColors.accent),
          const SizedBox(height: 8),
          Text(v, style: AppText.numerals(size: 17)),
          const SizedBox(height: 2),
          Text(l, textAlign: TextAlign.center, style: AppText.caption(color: AppColors.textTertiary).copyWith(fontSize: 11)),
        ]),
      );
}
