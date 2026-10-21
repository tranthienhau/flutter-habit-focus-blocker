import 'package:anchor/app.dart';
import 'package:anchor/state/providers.dart';
import 'package:anchor/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the real app through onboarding, habits, focus, blocks, insights and profile,
/// capturing a screenshot per key screen. Fixed pump(Duration) steps instead of
/// pumpAndSettle because the focus timer ticks every second.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var converted = false;

  Future<void> settle(WidgetTester t, [int ms = 900]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shoot(WidgetTester t, String name) async {
    if (!converted) {
      await binding.convertFlutterSurfaceToImage();
      converted = true;
    }
    await settle(t, 600);
    await binding.takeScreenshot(name);
  }

  Future<void> tap(WidgetTester t, String key, [int ms = 1100]) async {
    await t.tap(find.byKey(Key(key)));
    await settle(t, ms);
  }

  testWidgets('capture Anchor flows', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await preloadFonts();
    await t.pumpWidget(ProviderScope(overrides: [prefsProvider.overrideWithValue(prefs)], child: const AnchorApp()));
    await settle(t, 2000);
    final c = ProviderScope.containerOf(t.element(find.byType(AnchorApp)));

    await shoot(t, '01-welcome');
    await tap(t, 'welcome-start');
    for (final g in ['Less doomscrolling', 'Deep work', 'Morning routine']) {
      await tap(t, 'goal-$g', 300);
    }
    await shoot(t, '02-goals');
    await tap(t, 'goals-continue');
    await shoot(t, '03-screen-time-permission');
    await tap(t, 'permission-allow', 1800);
    await shoot(t, '04-sign-in');
    await tap(t, 'apple-sign-in');
    await shoot(t, '05-paywall');
    await tap(t, 'start-trial', 2000);
    await shoot(t, '06-today');

    await tap(t, 'habit-read');
    await shoot(t, '07-habit-detail');
    await tap(t, 'back');
    await tap(t, 'add-habit');
    await shoot(t, '08-add-habit');
    await tap(t, 'sheet-cancel');

    await tap(t, 'tab-Focus');
    await shoot(t, '09-focus');
    await tap(t, 'start-focus', 1500);
    c.read(focusProvider.notifier).skip(const Duration(minutes: 6, seconds: 17));
    await settle(t, 1200);
    await shoot(t, '10-focus-live');
    final n = c.read(focusProvider.notifier);
    for (var i = 0; i < 3; i++) {
      n.attemptBlocked();
    }
    n.skip(const Duration(minutes: 18, seconds: 40));
    await settle(t, 2500);
    await shoot(t, '11-focus-complete');
    await tap(t, 'complete-done');

    await tap(t, 'tab-Blocks');
    await shoot(t, '12-blocks');
    await tap(t, 'schedule-morning');
    await shoot(t, '13-block-editor');
    await tap(t, 'editor-cancel');
    await t.scrollUntilVisible(find.byKey(const Key('preview-shield')), 300, scrollable: find.byType(Scrollable).last);
    await settle(t, 500);
    await tap(t, 'preview-shield');
    await shoot(t, '14-shield');
    await tap(t, 'shield-close');

    await tap(t, 'tab-Insights');
    await shoot(t, '15-insights');
    await tap(t, 'tab-Profile');
    await shoot(t, '16-profile');

    c.read(habitsProvider.notifier).clear();
    await tap(t, 'tab-Today');
    await shoot(t, '17-today-empty');
    c.read(blocksProvider.notifier).clear();
    await tap(t, 'tab-Blocks');
    await t.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await settle(t);
    await shoot(t, '18-blocks-empty');

    c.read(habitsProvider.notifier).reset();
    c.read(blocksProvider.notifier).reset();
    await tap(t, 'tab-Today');
    await settle(t, 1500);
  });
}
