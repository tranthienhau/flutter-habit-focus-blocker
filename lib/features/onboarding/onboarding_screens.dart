import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/seed.dart';
import '../../platform/screen_time_service.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      body: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/welcome-hero.jpg', fit: BoxFit.cover, alignment: Alignment.topCenter),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, .35, .62, 1],
              colors: [Color(0x33000000), Color(0x004A154B), Color(0xE64A154B), Color(0xFF3A103B)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              Row(children: [
                Image.asset('assets/brand/mark.png', width: 28, color: Colors.white),
                const SizedBox(width: 6),
                Text('Anchor', style: AppText.label(color: Colors.white).copyWith(fontSize: 17)),
                const Spacer(),
                Text('Skip', style: AppText.label(color: Colors.white70)),
              ]),
              const Spacer(),
              Row(children: [
                Container(width: 22, height: 6, decoration: BoxDecoration(color: AppColors.support, borderRadius: BorderRadius.circular(3))),
                for (var i = 0; i < 2; i++)
                  Container(margin: const EdgeInsets.only(left: 6), width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle)),
              ]),
              const SizedBox(height: 18),
              Text('Build habits.\nGuard your focus.', style: AppText.display(size: 40, color: Colors.white)),
              const SizedBox(height: 14),
              Text('Track streaks, block distracting apps, and do your best work every single morning.',
                  style: AppText.body(color: Colors.white.withValues(alpha: .86))),
              const SizedBox(height: 28),
              PrimaryButton('Get started', key: const Key('welcome-start'), light: true, onTap: () => context.push('/goals'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.accent)),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/sign-in'),
                  child: Text('I already have an account', style: AppText.label(color: Colors.white, weight: FontWeight.w400)),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ]),
    );
  }
}

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(sessionProvider).goals;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          TopBar(onBack: () => context.pop(), title: null, trailing: Text('Skip', style: AppText.label(color: AppColors.textSecondary))),
          const StepProgress(step: 2, of: 4),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), children: [
              Text('What do you want\nto change?', style: AppText.display(size: 32)),
              const SizedBox(height: 8),
              Text('Pick up to 3. We will set up your first habits.', style: AppText.body(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .92,
                children: [
                  for (final (label, img) in goalOptions)
                    _GoalCard(label: label, image: img, selected: goals.contains(label), onTap: () => ref.read(sessionProvider.notifier).toggleGoal(label)),
                ],
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: PrimaryButton('Continue', key: const Key('goals-continue'), onTap: goals.isEmpty ? null : () => context.push('/permission'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(999)),
                  child: Text('${goals.length}/3', style: AppText.caption(color: Colors.white)),
                )),
          ),
        ]),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.label, required this.image, required this.selected, required this.onTap});
  final String label, image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: Key('goal-$label'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: selected ? 2 : 1),
            boxShadow: AppShadows.card,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset(image, fit: BoxFit.cover)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : Colors.white.withValues(alpha: .85),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: selected ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null,
                  ),
                ),
              ]),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(6, 10, 6, 6), child: Text(label, style: AppText.label())),
          ]),
        ),
      );
}

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  bool _busy = false;

  Future<void> _connect() async {
    setState(() => _busy = true);
    await ref.read(sessionProvider.notifier).requestScreenTime();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ref.read(sessionProvider).auth == ScreenTimeAuth.approved) context.push('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          TopBar(onBack: () => context.pop(), trailing: Text('Skip', style: AppText.label(color: AppColors.textSecondary))),
          const StepProgress(step: 3, of: 4),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: AspectRatio(aspectRatio: 1.45, child: Image.asset('assets/images/phone-in-box.jpg', fit: BoxFit.cover)),
              ),
              const SizedBox(height: 24),
              Text('Allow Screen Time access', style: AppText.display(size: 30)),
              const SizedBox(height: 10),
              Text("Anchor uses Apple's official Screen Time API to help you stay present and build intentional routines.",
                  style: AppText.body(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              const _Bullet(LucideIcons.shield, 'Block distracting apps during focus', 'Choose apps and categories once, Anchor shields them on schedule.'),
              const _Bullet(LucideIcons.hourglass, 'Set daily limits for social and games', 'Gentle friction when you hit your daily minutes.'),
              const _Bullet(LucideIcons.lock, 'Private by design, strictly on-device', 'App names and usage never leave your iPhone. Apple only gives Anchor opaque tokens.'),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: PrimaryButton(_busy ? 'Waiting for Face ID...' : 'Continue with Screen Time',
                key: const Key('permission-allow'), icon: LucideIcons.shieldCheck, onTap: _busy ? null : _connect),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 6),
            child: Text('iOS will ask you to confirm with Face ID.', style: AppText.caption(color: AppColors.textTertiary)),
          ),
        ]),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.icon, this.title, this.sub);
  final IconData icon;
  final String title, sub;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconTile(icon, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppText.label()),
                const SizedBox(height: 4),
                Text(sub, style: AppText.caption()),
              ]),
            ),
          ]),
        ),
      );
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();

  void _done(String email) {
    ref.read(sessionProvider.notifier).signIn(email);
    context.push('/paywall');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          TopBar(onBack: () => context.pop()),
          const StepProgress(step: 4, of: 4),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(22), boxShadow: AppShadows.card),
                  padding: const EdgeInsets.all(14),
                  child: Image.asset('assets/brand/mark.png', color: AppColors.support),
                ),
              ),
              const SizedBox(height: 24),
              Text('Save your streaks', textAlign: TextAlign.center, style: AppText.display(size: 32)),
              const SizedBox(height: 8),
              Text('Sync habits and blocks across your devices seamlessly.', textAlign: TextAlign.center, style: AppText.body(color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              Center(child: Tag('End-to-end encrypted iCloud sync', bg: AppColors.chip, fg: AppColors.textSecondary, icon: LucideIcons.lock)),
              const SizedBox(height: 32),
              _SocialButton(key: const Key('apple-sign-in'), dark: true, icon: LucideIcons.apple, label: 'Continue with Apple', onTap: () => _done('maya.chen@icloud.com')),
              const SizedBox(height: 12),
              _SocialButton(dark: false, icon: LucideIcons.mail, label: 'Continue with Google', onTap: () => _done('maya.chen@gmail.com')),
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: AppText.caption(color: AppColors.textTertiary))),
                const Expanded(child: Divider(color: AppColors.border)),
              ]),
              const SizedBox(height: 20),
              TextField(
                key: const Key('email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'you@email.com', prefixIcon: Icon(LucideIcons.mail, size: 20, color: AppColors.textTertiary)),
              ),
              const SizedBox(height: 14),
              PrimaryButton('Continue with email', onTap: () => _done(_email.text.isEmpty ? 'maya.chen@gmail.com' : _email.text)),
              const SizedBox(height: 24),
              Text('By continuing you agree to the Terms and Privacy Policy.', textAlign: TextAlign.center, style: AppText.caption(color: AppColors.textTertiary)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({super.key, required this.dark, required this.icon, required this.label, required this.onTap});
  final bool dark;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: Material(
          color: dark ? Colors.black : Colors.white,
          shape: StadiumBorder(side: dark ? BorderSide.none : const BorderSide(color: AppColors.border)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: dark ? Colors.white : AppColors.textPrimary, size: 20),
              const SizedBox(width: 10),
              Text(label, style: AppText.label(color: dark ? Colors.white : AppColors.textPrimary).copyWith(fontSize: 16)),
            ]),
          ),
        ),
      );
}

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _yearly = true;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Row(children: [
            IconButton(key: const Key('paywall-close'), onPressed: () {
              ref.read(sessionProvider.notifier).skipPaywall();
              context.go('/today');
            }, icon: const Icon(LucideIcons.x)),
            const Spacer(),
            TextButton(onPressed: () {}, child: Text('Restore', style: AppText.label(color: AppColors.textSecondary))),
          ]),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(24), boxShadow: AppShadows.card),
                child: Column(children: [
                  Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), shape: BoxShape.circle),
                    child: Image.asset('assets/brand/mark.png', color: AppColors.support),
                  ),
                  const SizedBox(height: 14),
                  Text('Anchor Pro', style: AppText.display(size: 34, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Unlock your full focus toolkit', style: AppText.body(color: Colors.white70)),
                ]),
              ),
              const SizedBox(height: 18),
              for (final f in const ['Unlimited habits', 'Unlimited block schedules', 'Strict mode', 'Advanced insights', 'Home screen widgets'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(children: [
                    const Icon(LucideIcons.circleCheck, size: 20, color: AppColors.accent),
                    const SizedBox(width: 12),
                    Text(f, style: AppText.body()),
                  ]),
                ),
              const SizedBox(height: 16),
              _Plan(
                selected: _yearly,
                title: 'Yearly',
                price: r'$39.99',
                per: '/ year',
                sub: r'7-day free trial, then $3.33/mo',
                badge: 'Save 58%',
                onTap: () => setState(() => _yearly = true),
              ),
              const SizedBox(height: 12),
              _Plan(selected: !_yearly, title: 'Monthly', price: r'$7.99', per: '/ month', onTap: () => setState(() => _yearly = false)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
            child: PrimaryButton(_busy ? 'Starting...' : (_yearly ? 'Start free trial' : 'Subscribe'), key: const Key('start-trial'), onTap: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await ref.read(sessionProvider.notifier).startTrial();
                    if (context.mounted) context.go('/today');
                  }),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('No commitment. Cancel anytime in App Store settings.   Terms   Privacy', style: AppText.caption(color: AppColors.textTertiary)),
          ),
        ]),
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({required this.selected, required this.title, required this.price, required this.per, required this.onTap, this.sub, this.badge});
  final bool selected;
  final String title, price, per;
  final String? sub, badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        border: selected ? AppColors.accent : null,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(selected ? LucideIcons.circleCheck : LucideIcons.circle, color: selected ? AppColors.accent : AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: AppText.title(size: 18)),
                if (badge != null) ...[const SizedBox(width: 8), Tag(badge!)],
              ]),
              if (sub != null) ...[const SizedBox(height: 4), Text(sub!, style: AppText.caption())],
            ]),
          ),
          Text(price, style: AppText.numerals(size: 18)),
          Text(' $per', style: AppText.caption()),
        ]),
      );
}
