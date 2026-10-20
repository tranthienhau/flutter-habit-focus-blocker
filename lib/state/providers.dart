import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import '../data/seed.dart';
import '../platform/screen_time_service.dart';

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('override in main'));

final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) => MethodChannelScreenTimeService());

// ---------------------------------------------------------------------------
// Session: onboarding, account, subscription.

class Session {
  const Session({this.onboarded = false, this.email, this.pro = false, this.auth = ScreenTimeAuth.notDetermined, this.goals = const {}});
  final bool onboarded;
  final String? email;
  final bool pro;
  final ScreenTimeAuth auth;
  final Set<String> goals;

  Session copyWith({bool? onboarded, String? email, bool? pro, ScreenTimeAuth? auth, Set<String>? goals}) => Session(
        onboarded: onboarded ?? this.onboarded,
        email: email ?? this.email,
        pro: pro ?? this.pro,
        auth: auth ?? this.auth,
        goals: goals ?? this.goals,
      );
}

class SessionNotifier extends Notifier<Session> {
  @override
  Session build() {
    final p = ref.read(prefsProvider);
    return Session(onboarded: p.getBool('onboarded') ?? false, email: p.getString('email'), pro: p.getBool('pro') ?? false);
  }

  void toggleGoal(String g) {
    final next = {...state.goals};
    next.contains(g) ? next.remove(g) : (next.length < 3 ? next.add(g) : null);
    state = state.copyWith(goals: next);
  }

  Future<void> requestScreenTime() async {
    final auth = await ref.read(screenTimeServiceProvider).requestAuthorization();
    state = state.copyWith(auth: auth);
  }

  void signIn(String email) {
    ref.read(prefsProvider).setString('email', email);
    state = state.copyWith(email: email);
  }

  /// StoreKit 2 / RevenueCat purchase is stubbed: a successful trial start flips Pro on.
  Future<void> startTrial() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    ref.read(prefsProvider)
      ..setBool('pro', true)
      ..setBool('onboarded', true);
    state = state.copyWith(pro: true, onboarded: true);
  }

  void skipPaywall() {
    ref.read(prefsProvider).setBool('onboarded', true);
    state = state.copyWith(onboarded: true);
  }

  void signOut() {
    ref.read(prefsProvider).clear();
    state = const Session();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);

// ---------------------------------------------------------------------------
// Habits.

int streakOf(Habit h) {
  var n = h.doneToday ? 1 : 0;
  var d = demoToday.subtract(const Duration(days: 1));
  while (h.history.contains(dayKey(d))) {
    n++;
    d = d.subtract(const Duration(days: 1));
  }
  return n;
}

int bestStreakOf(Habit h) {
  var best = 0, run = 0;
  for (var i = 120; i >= 1; i--) {
    if (h.history.contains(dayKey(demoToday.subtract(Duration(days: i))))) {
      run++;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  return [best, streakOf(h)].reduce((a, b) => a > b ? a : b);
}

class HabitsNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() => seedHabits;

  void toggle(String id) {
    state = [
      for (final h in state)
        if (h.id == id) h.copyWith(progressToday: h.doneToday ? 0 : h.target) else h,
    ];
  }

  void add(Habit h) => state = [...state, h];

  void clear() => state = const [];

  void reset() => state = seedHabits;
}

final habitsProvider = NotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

final overallStreakProvider = Provider<int>((ref) {
  final hs = ref.watch(habitsProvider);
  if (hs.isEmpty) return 0;
  return hs.map(streakOf).reduce((a, b) => a > b ? a : b);
});

// ---------------------------------------------------------------------------
// Blocks: schedules + per-app limits, pushed to ScreenTimeService.

class BlocksState {
  const BlocksState({required this.schedules, required this.apps, this.strictMode = true, this.unlocksLeft = 1, this.resisted = 3});
  final List<BlockSchedule> schedules;
  final List<BlockedApp> apps;
  final bool strictMode;
  final int unlocksLeft;
  final int resisted;

  BlocksState copyWith({List<BlockSchedule>? schedules, bool? strictMode, int? unlocksLeft, int? resisted}) => BlocksState(
        schedules: schedules ?? this.schedules,
        apps: apps,
        strictMode: strictMode ?? this.strictMode,
        unlocksLeft: unlocksLeft ?? this.unlocksLeft,
        resisted: resisted ?? this.resisted,
      );
}

class BlocksNotifier extends Notifier<BlocksState> {
  @override
  BlocksState build() => const BlocksState(schedules: seedSchedules, apps: seedApps);

  ScreenTimeService get _svc => ref.read(screenTimeServiceProvider);

  Future<void> setEnabled(String id, bool on) async {
    final s = state.schedules.firstWhere((e) => e.id == id);
    state = state.copyWith(schedules: [for (final e in state.schedules) e.id == id ? e.copyWith(enabled: on) : e]);
    if (on) {
      await _svc.startMonitoring(scheduleId: id, start: s.start, end: s.end);
      await _svc.applyShield(scheduleId: id, apps: s.apps, strict: state.strictMode);
    } else {
      await _svc.clearShield(id);
    }
  }

  void setStrict(bool on) => state = state.copyWith(strictMode: on);

  void useUnlock() => state = state.copyWith(unlocksLeft: (state.unlocksLeft - 1).clamp(0, 9));

  void resist() => state = state.copyWith(resisted: state.resisted + 1);

  void clear() => state = state.copyWith(schedules: const []);

  void reset() => state = build();
}

final blocksProvider = NotifierProvider<BlocksNotifier, BlocksState>(BlocksNotifier.new);

// ---------------------------------------------------------------------------
// Focus timer + stopwatch.

class FocusState {
  const FocusState({
    this.mode = FocusMode.timer,
    this.phase = FocusPhase.idle,
    this.duration = const Duration(minutes: 25),
    this.elapsed = Duration.zero,
    this.label = 'Deep work',
    this.blockApps = true,
    this.blockedAttempts = 0,
    this.focusedToday = const Duration(hours: 2, minutes: 10),
    this.focusStreak = 11,
  });

  final FocusMode mode;
  final FocusPhase phase;
  final Duration duration;
  final Duration elapsed;
  final String label;
  final bool blockApps;
  final int blockedAttempts;
  final Duration focusedToday;
  final int focusStreak;

  Duration get remaining => mode == FocusMode.timer ? duration - elapsed : elapsed;
  double get progress => mode == FocusMode.timer ? (elapsed.inMilliseconds / duration.inMilliseconds).clamp(0, 1).toDouble() : 0;

  FocusState copyWith({
    FocusMode? mode,
    FocusPhase? phase,
    Duration? duration,
    Duration? elapsed,
    bool? blockApps,
    int? blockedAttempts,
    Duration? focusedToday,
    int? focusStreak,
  }) =>
      FocusState(
        mode: mode ?? this.mode,
        phase: phase ?? this.phase,
        duration: duration ?? this.duration,
        elapsed: elapsed ?? this.elapsed,
        label: label,
        blockApps: blockApps ?? this.blockApps,
        blockedAttempts: blockedAttempts ?? this.blockedAttempts,
        focusedToday: focusedToday ?? this.focusedToday,
        focusStreak: focusStreak ?? this.focusStreak,
      );
}

class FocusNotifier extends Notifier<FocusState> {
  Timer? _tick;

  @override
  FocusState build() {
    ref.onDispose(() => _tick?.cancel());
    return const FocusState();
  }

  void setMode(FocusMode m) => state = state.copyWith(mode: m);
  void setDuration(int minutes) => state = state.copyWith(duration: Duration(minutes: minutes));
  void setBlockApps(bool on) => state = state.copyWith(blockApps: on);

  Future<void> start() async {
    state = state.copyWith(phase: FocusPhase.running, elapsed: Duration.zero, blockedAttempts: 0);
    if (state.blockApps) {
      await ref.read(screenTimeServiceProvider).applyShield(scheduleId: 'focus-session', apps: const ['Instagram', 'TikTok', 'X', 'YouTube'], strict: false);
    }
    _run();
  }

  void _run() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.elapsed + const Duration(seconds: 1);
      if (state.mode == FocusMode.timer && next >= state.duration) {
        state = state.copyWith(elapsed: state.duration);
        finish();
      } else {
        state = state.copyWith(elapsed: next);
      }
    });
  }

  void pause() {
    _tick?.cancel();
    state = state.copyWith(phase: FocusPhase.paused);
  }

  void resume() {
    state = state.copyWith(phase: FocusPhase.running);
    _run();
  }

  /// Demo hook: jump the clock forward so a long session can be shown mid-way or complete.
  void skip(Duration d) => state = state.copyWith(elapsed: state.elapsed + d);

  void attemptBlocked() => state = state.copyWith(blockedAttempts: state.blockedAttempts + 1);

  Future<void> finish() async {
    _tick?.cancel();
    await ref.read(screenTimeServiceProvider).clearShield('focus-session');
    state = state.copyWith(
      phase: FocusPhase.done,
      focusedToday: state.focusedToday + state.elapsed,
      focusStreak: state.focusStreak + 1,
    );
  }

  void reset() {
    _tick?.cancel();
    state = state.copyWith(phase: FocusPhase.idle, elapsed: Duration.zero);
  }
}

final focusProvider = NotifierProvider<FocusNotifier, FocusState>(FocusNotifier.new);

String fmtClock(Duration d) {
  final m = d.inMinutes.remainder(600).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

String fmtHm(Duration d) => d.inHours > 0 ? '${d.inHours}h ${d.inMinutes.remainder(60)}m' : '${d.inMinutes}m';
