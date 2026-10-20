import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ScreenTimeAuth { notDetermined, approved, denied }

/// Bridge to Apple's Screen Time stack (FamilyControls, ManagedSettings, DeviceActivity).
///
/// The iOS side lives in ios/Runner/ScreenTimeChannel.swift. Real shielding needs the
/// com.apple.developer.family-controls entitlement and a physical device, so the POC
/// falls back to [MockScreenTimeService] on the simulator and on Android.
abstract class ScreenTimeService {
  Future<ScreenTimeAuth> requestAuthorization();
  Future<void> applyShield({required String scheduleId, required List<String> apps, required bool strict});
  Future<void> clearShield(String scheduleId);
  Future<void> startMonitoring({required String scheduleId, required String start, required String end});
}

class MethodChannelScreenTimeService implements ScreenTimeService {
  MethodChannelScreenTimeService([this._fallback = const MockScreenTimeService()]);
  static const _channel = MethodChannel('anchor/screen_time');
  final ScreenTimeService _fallback;

  bool get _native => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<ScreenTimeAuth> requestAuthorization() async {
    if (!_native) return _fallback.requestAuthorization();
    try {
      final status = await _channel.invokeMethod<String>('requestAuthorization');
      return switch (status) {
        'approved' => ScreenTimeAuth.approved,
        'denied' => ScreenTimeAuth.denied,
        _ => ScreenTimeAuth.notDetermined,
      };
    } on PlatformException {
      // Simulator or missing entitlement: keep the demo flowing.
      return _fallback.requestAuthorization();
    }
  }

  @override
  Future<void> applyShield({required String scheduleId, required List<String> apps, required bool strict}) =>
      _call('applyShield', {'scheduleId': scheduleId, 'apps': apps, 'strict': strict},
          () => _fallback.applyShield(scheduleId: scheduleId, apps: apps, strict: strict));

  @override
  Future<void> clearShield(String scheduleId) =>
      _call('clearShield', {'scheduleId': scheduleId}, () => _fallback.clearShield(scheduleId));

  @override
  Future<void> startMonitoring({required String scheduleId, required String start, required String end}) =>
      _call('startMonitoring', {'scheduleId': scheduleId, 'start': start, 'end': end},
          () => _fallback.startMonitoring(scheduleId: scheduleId, start: start, end: end));

  Future<void> _call(String method, Map<String, Object?> args, Future<void> Function() fallback) async {
    if (!_native) return fallback();
    try {
      await _channel.invokeMethod<void>(method, args);
    } on PlatformException {
      return fallback();
    }
  }
}

class MockScreenTimeService implements ScreenTimeService {
  const MockScreenTimeService();

  @override
  Future<ScreenTimeAuth> requestAuthorization() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return ScreenTimeAuth.approved;
  }

  @override
  Future<void> applyShield({required String scheduleId, required List<String> apps, required bool strict}) async {}

  @override
  Future<void> clearShield(String scheduleId) async {}

  @override
  Future<void> startMonitoring({required String scheduleId, required String start, required String end}) async {}
}
