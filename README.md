# Anchor - Habit Tracker, App Blocker & Focus Timer

A Flutter app for iOS (Android-ready) that helps people build daily routines and guard their
attention. It has three core features: a **habit tracker** with streaks, **app blocking** built on
Apple's Screen Time APIs, and a **focus timer** that shields distracting apps while a session runs.
Onboarding, sign-in and a subscription paywall complete the launch flow.

<p align="center"><img src="assets/brand/app-icon.png" width="96" alt="Anchor icon"></p>

## Demo

| iOS | Android |
|---|---|
| ![iOS demo](screenshots/demo.gif) | ![Android demo](screenshots/demo-android.gif) |

Same codebase running on both platforms.

## What it shows

- **Habits:** a daily checklist with checkbox and measured habits (for example 1.2 / 2 L of water),
  per-habit and overall streaks, a week strip, a monthly heatmap with best streak and completion
  stats, and an "add habit" sheet (icon, color, frequency, goal, time of day, reminder).
- **App blocking (Screen Time):** block schedules (Morning Focus, Work Hours, Wind Down) with
  per-schedule toggles, daily app limits with usage bars, strict mode, break allowance, a schedule
  editor (app and category picker, time window, days) and a preview of the custom shield screen
  people see when they open a blocked app.
- **Focus timer:** Timer and Stopwatch modes, 15/25/50/90 minute presets, an optional "block apps
  during session" switch, a live session screen (pause, end, ambient sound, blocked-apps card)
  and a session summary with blocked attempts, focus streak and a focus rating.
- **Insights:** weekly focus hours, screen time saved, habit completion ring, top habits and the
  apps blocked most often.
- **Launch flow:** welcome, goal picker, Screen Time permission, Sign in with Apple / Google /
  email, and a paywall (yearly with a 7-day trial or monthly) feeding the Pro state.
- **Empty states** for first-run Today and Blocks.

## Screenshots

| Welcome | Goals | Screen Time permission | Sign in | Paywall | Today |
|---|---|---|---|---|---|
| ![Welcome](screenshots/01-welcome.png) | ![Goals](screenshots/02-goals.png) | ![Permission](screenshots/03-screen-time-permission.png) | ![Sign in](screenshots/04-sign-in.png) | ![Paywall](screenshots/05-paywall.png) | ![Today](screenshots/06-today.png) |

| Habit detail | Add habit | Focus | Live session | Session complete | Blocks |
|---|---|---|---|---|---|
| ![Habit detail](screenshots/07-habit-detail.png) | ![Add habit](screenshots/08-add-habit.png) | ![Focus](screenshots/09-focus.png) | ![Live](screenshots/10-focus-live.png) | ![Complete](screenshots/11-focus-complete.png) | ![Blocks](screenshots/12-blocks.png) |

| Block editor | Shield | Insights | Profile | Today (empty) | Blocks (empty) |
|---|---|---|---|---|---|
| ![Block editor](screenshots/13-block-editor.png) | ![Shield](screenshots/14-shield.png) | ![Insights](screenshots/15-insights.png) | ![Profile](screenshots/16-profile.png) | ![Today empty](screenshots/17-today-empty.png) | ![Blocks empty](screenshots/18-blocks-empty.png) |

## Flow

```mermaid
flowchart TD
    A[Welcome] --> B[Pick goals]
    B --> C[Screen Time permission<br/>FamilyControls authorization]
    C --> D[Sign in<br/>Apple / Google / email]
    D --> E{Paywall}
    E -->|Start trial| F[Today]
    E -->|Close| F
    F --> G[Habit detail<br/>heatmap + streaks]
    F --> H[Add habit sheet]
    F --> I[Focus tab]
    I --> J[Live session<br/>apps shielded]
    J -->|Timer ends or End session| K[Session summary]
    F --> L[Blocks tab]
    L --> M[Schedule editor<br/>apps, window, strict mode]
    L --> N[Shield screen<br/>shown over a blocked app]
    F --> O[Insights]
    F --> P[Profile<br/>subscription + settings]
    M -. applyShield / startMonitoring .-> Q[(ManagedSettings +<br/>DeviceActivity)]
    J -. applyShield / clearShield .-> Q
```

## Architecture

```
lib/
  main.dart, app.dart          go_router: onboarding stack + 5-tab StatefulShellRoute
  theme/app_theme.dart         design tokens (aubergine #4A154B, gold #ECB22E, Lato + Gloock)
  data/models.dart, seed.dart  Habit, BlockSchedule, BlockedApp + realistic demo data
  state/providers.dart         Riverpod Notifiers: session, habits, blocks, focus timer
  platform/screen_time_service.dart
                               ScreenTimeService interface, MethodChannel impl, mock fallback
  features/                    onboarding, today, focus, blocks, insights, profile
ios/Runner/AppDelegate.swift   ScreenTimePlugin: FamilyControls, ManagedSettings, DeviceActivity
integration_test/              drives every screen and captures the screenshots above
```

- **State:** Riverpod 3 `Notifier`s. The focus timer is a `Timer.periodic` notifier with pause,
  resume, finish and stopwatch mode. When it finishes, the summary screen opens and the shield
  is cleared.
- **Screen Time bridge:** Dart calls `anchor/screen_time` (`requestAuthorization`, `applyShield`,
  `clearShield`, `startMonitoring`). On iOS the Swift plugin uses `AuthorizationCenter`
  (individual), one named `ManagedSettingsStore` per schedule, and `DeviceActivityCenter`
  schedules. The `FamilyActivitySelection` tokens are stored per schedule. On the simulator and on
  Android it returns an error and the app falls back to `MockScreenTimeService`, so every flow
  stays demoable.
- **Production pieces not in this POC:** a `DeviceActivityMonitor` extension (applies the shield
  at schedule start even if the app is closed), a `ShieldConfiguration` extension (renders the
  shield screen shown here natively), an App Group for shared tokens, the
  `com.apple.developer.family-controls` entitlement (needs Apple approval), StoreKit 2 /
  RevenueCat for the paywall, and a backend for auth and sync. On Android, app blocking would use
  `UsageStatsManager` plus an accessibility or overlay service behind the same `ScreenTimeService`
  interface.

## Run

```sh
flutter pub get
open -a Simulator
flutter run
```

Requires Flutter 3.44+ and Xcode 26 for iOS. Fonts load through `google_fonts` (Lato, Gloock).
Real images are bundled in `assets/images/`. The original screen designs are in `design/`.
