# Anchor - Source Brief

## Title
Anchor - Habit & Focus

## Description
Anchor is a habit tracker and focus app for people who want better routines and fewer
distractions. Users pick what they want to change, connect Screen Time, and get a daily checklist
of habits with streaks. When it is time to work, they start a focus session that blocks
distracting apps until the timer ends, or they set block schedules (Morning Focus, Work Hours,
Wind Down) and daily app limits that run automatically. Opening a blocked app shows a calm shield
screen with the time the block ends and a short prompt. Weekly insights show focus hours, screen
time saved and habit completion.

## Store links
Not yet published (POC).

## Platform
iOS first, with the same Flutter codebase running on Android.

## Category
Productivity / Health & Fitness

## Features
- Daily habits: checkbox and measured goals, reminders, time of day, frequency
- Streaks: per habit, overall, best streak, week strip and monthly heatmap
- Add habit sheet with icon, color, goal stepper and reminder
- App blocking with Apple Screen Time: schedules, daily app limits, strict mode, break allowance
- Schedule editor: app and category picker, time window, repeat days, block or limit mode
- Custom shield screen shown over blocked apps, with unlock-for-5-minutes allowance
- Focus timer and stopwatch with 15/25/50/90 minute presets
- Live focus session that shields apps, with pause, end and ambient sound
- Session summary: minutes focused, blocked attempts, focus streak, focus rating
- Insights: weekly focus hours, screen time saved, habit completion, most blocked apps
- Onboarding: goal picker, Screen Time permission, Sign in with Apple / Google / email
- Subscription paywall: yearly with 7-day free trial, or monthly
- Empty states for first run

## Tech stack
- Flutter (Dart) for iOS and Android
- Riverpod 3 for state (session, habits, blocks, focus timer notifiers)
- go_router with a 5-tab StatefulShellRoute
- Swift platform channel for Screen Time: FamilyControls (AuthorizationCenter), ManagedSettings
  (named stores per schedule) and DeviceActivity (DeviceActivityCenter schedules)
- google_fonts (Lato, Gloock), lucide_icons_flutter, shared_preferences
- integration_test for screenshot capture

## Industry
Consumer productivity, digital wellbeing

## Metrics
Unpublished POC, no store metrics yet. Scope: 18 screens, including 2 empty states.

## Research notes
- Verified: the Swift Screen Time plugin compiles for device (iphoneos) and simulator; the full
  flow runs on the iOS simulator and the Android emulator from one codebase.
- Mocked: habit history, screen time usage, app limits and insights use realistic fixture
  data; the purchase and sign-in calls are stubbed; on the simulator Screen Time calls fall back to
  a mock service because the APIs need a physical device and the Family Controls entitlement.
- Future expansion:
  - DeviceActivityMonitor and ShieldConfiguration app extensions sharing tokens through an App Group
  - StoreKit 2 or RevenueCat for subscriptions
  - Backend (for example Supabase or Firebase) for auth, sync and analytics
  - Home screen widgets and Live Activity for running focus sessions
  - Android app blocking via UsageStatsManager plus an overlay or accessibility service
