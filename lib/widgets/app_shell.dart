import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Shared bottom tab bar from DESIGN.md: Today, Focus, Blocks, Insights, Profile.
/// Active tab = aubergine icon + label with a small gold dot above.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _tabs = [
    (LucideIcons.circleCheck, 'Today'),
    (LucideIcons.timer, 'Focus'),
    (LucideIcons.shield, 'Blocks'),
    (LucideIcons.chartColumn, 'Insights'),
    (LucideIcons.user, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: InkWell(
                    key: Key('tab-${_tabs[i].$2}'),
                    onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(color: i == shell.currentIndex ? AppColors.support : Colors.transparent, shape: BoxShape.circle),
                      ),
                      const SizedBox(height: 4),
                      Icon(_tabs[i].$1, size: 24, color: i == shell.currentIndex ? AppColors.accent : AppColors.textTertiary),
                      const SizedBox(height: 3),
                      Text(_tabs[i].$2,
                          style: AppText.caption(color: i == shell.currentIndex ? AppColors.accent : AppColors.textTertiary)
                              .copyWith(fontSize: 12, fontWeight: i == shell.currentIndex ? FontWeight.w700 : FontWeight.w400)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
