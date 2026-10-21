import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _health = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider);
    final streak = ref.watch(overallStreakProvider);
    final focus = ref.watch(focusProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: [
          Row(children: [
            const SizedBox(width: 48),
            Expanded(child: Text('Profile', textAlign: TextAlign.center, style: AppText.display(size: 24))),
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.settings, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 16),
          const Center(child: Avatar(size: 104)),
          const SizedBox(height: 14),
          Center(child: Text('Maya Chen', style: AppText.display(size: 30))),
          const SizedBox(height: 2),
          Center(child: Text(s.email ?? 'Member since Aug 2026', style: AppText.caption())),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.flame, size: 16, color: AppColors.support),
                const SizedBox(width: 6),
                Text('$streak day streak', style: AppText.label()),
                _sep(),
                Text('164 done', style: AppText.label()),
                _sep(),
                Text('${fmtHm(focus.focusedToday)} focused', style: AppText.label()),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadows.card),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.support, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.anchor, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.pro ? 'Anchor Pro' : 'Anchor Free', style: AppText.display(size: 22, color: Colors.white)),
                    Text(s.pro ? 'Renews Aug 12, 2027' : 'Upgrade for unlimited blocks', style: AppText.caption(color: Colors.white70)),
                  ]),
                ),
                Tag(s.pro ? 'YEARLY' : 'FREE'),
              ]),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white12),
              const SizedBox(height: 12),
              Row(children: [
                Text('Unlimited blocks & sync', style: AppText.caption(color: Colors.white70)),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/paywall'),
                  child: Text('Manage subscription  ›', style: AppText.label(color: AppColors.support)),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              _row(LucideIcons.bell, 'Reminders'),
              _div(),
              _row(LucideIcons.shield, 'Screen Time permission', trailing: Tag('Granted', bg: AppColors.successTint, fg: AppColors.success)),
              _div(),
              _row(LucideIcons.layoutGrid, 'Home screen widgets'),
              _div(),
              _row(LucideIcons.heart, 'Apple Health sync', trailing: Switch(value: _health, onChanged: (v) => setState(() => _health = v)), chevron: false),
              _div(),
              _row(LucideIcons.palette, 'Appearance', trailing: Text('System theme', style: AppText.caption())),
              _div(),
              _row(LucideIcons.download, 'Export data'),
              _div(),
              _row(LucideIcons.messageCircle, 'Help and feedback'),
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            onTap: () {
              ref.read(sessionProvider.notifier).signOut();
              context.go('/welcome');
            },
            child: _row(LucideIcons.logOut, 'Sign out', color: AppColors.danger, chevron: false),
          ),
          const SizedBox(height: 16),
          Center(child: Text('Anchor 1.0.0 (1)', style: AppText.caption(color: AppColors.textTertiary))),
        ]),
      ),
    );
  }

  Widget _sep() => Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle));

  Widget _div() => const Divider(color: AppColors.border, height: 1);

  Widget _row(IconData i, String l, {Widget? trailing, bool chevron = true, Color color = AppColors.textPrimary}) => SizedBox(
        height: 56,
        child: Row(children: [
          Icon(i, size: 20, color: color == AppColors.danger ? color : AppColors.accent),
          const SizedBox(width: 14),
          Expanded(child: Text(l, style: AppText.body(color: color))),
          ?trailing,
          if (chevron) ...[const SizedBox(width: 6), const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary)],
        ]),
      );
}
