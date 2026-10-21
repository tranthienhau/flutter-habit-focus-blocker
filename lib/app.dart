import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/blocks/blocks_screens.dart';
import 'features/focus/focus_screens.dart';
import 'features/insights/insights_screen.dart';
import 'features/onboarding/onboarding_screens.dart';
import 'features/profile/profile_screen.dart';
import 'features/today/habit_detail_screen.dart';
import 'features/today/today_screen.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.read(sessionProvider).onboarded;
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: onboarded ? '/today' : '/welcome',
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/goals', builder: (_, _) => const GoalsScreen()),
      GoRoute(path: '/permission', builder: (_, _) => const PermissionScreen()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/paywall', parentNavigatorKey: _rootKey, builder: (_, _) => const PaywallScreen()),
      GoRoute(path: '/focus/live', parentNavigatorKey: _rootKey, builder: (_, _) => const FocusLiveScreen()),
      GoRoute(path: '/focus/complete', parentNavigatorKey: _rootKey, builder: (_, _) => const FocusCompleteScreen()),
      GoRoute(path: '/blocks/edit/:id', parentNavigatorKey: _rootKey, builder: (_, s) => BlockEditorScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/shield', parentNavigatorKey: _rootKey, builder: (_, _) => const ShieldScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/today', builder: (_, _) => const TodayScreen(), routes: [
              GoRoute(path: 'habit/:id', builder: (_, s) => HabitDetailScreen(id: s.pathParameters['id']!)),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/focus', builder: (_, _) => const FocusScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/blocks', builder: (_, _) => const BlocksScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/insights', builder: (_, _) => const InsightsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())]),
        ],
      ),
    ],
  );
});

class AnchorApp extends ConsumerWidget {
  const AnchorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Anchor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: ref.watch(routerProvider),
      );
}
