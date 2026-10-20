import DeviceActivity
import FamilyControls
import Flutter
import ManagedSettings
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ScreenTimePlugin") {
      ScreenTimePlugin.register(with: registrar)
    }
  }
}

/// Method channel `anchor/screen_time` backing lib/platform/screen_time_service.dart.
///
/// - requestAuthorization: FamilyControls individual authorization (Face ID prompt).
/// - applyShield / clearShield: one named ManagedSettingsStore per schedule, shielding the
///   ApplicationTokens + category tokens the user picked in FamilyActivityPicker.
/// - startMonitoring: DeviceActivityCenter schedule; a DeviceActivityMonitor extension
///   applies/clears the shield at interval start/end even when the app is not running.
///
/// Shipping requires the com.apple.developer.family-controls entitlement (Apple approval)
/// and a physical device. On the simulator every call returns a FlutterError so the Dart
/// side falls back to its mock service and the demo keeps working.
final class ScreenTimePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "anchor/screen_time", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(ScreenTimePlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    #if targetEnvironment(simulator)
      result(FlutterError(code: "simulator", message: "Screen Time APIs need a physical device", details: nil))
    #else
      guard #available(iOS 16.0, *) else {
        result(FlutterError(code: "unsupported", message: "Requires iOS 16+", details: nil))
        return
      }
      let args = call.arguments as? [String: Any] ?? [:]
      let scheduleId = args["scheduleId"] as? String ?? "default"
      switch call.method {
      case "requestAuthorization":
        Task {
          do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            result("approved")
          } catch {
            result("denied")
          }
        }
      case "applyShield":
        let selection = SelectionStore.load(scheduleId)
        let store = ManagedSettingsStore(named: .init(scheduleId))
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories =
          selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        result(nil)
      case "clearShield":
        ManagedSettingsStore(named: .init(scheduleId)).clearAllSettings()
        result(nil)
      case "startMonitoring":
        guard let start = Self.components(args["start"] as? String),
          let end = Self.components(args["end"] as? String)
        else {
          result(FlutterError(code: "bad_args", message: "start/end must be like 6:00 AM", details: nil))
          return
        }
        do {
          try DeviceActivityCenter().startMonitoring(
            .init(scheduleId),
            during: DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: true))
          result(nil)
        } catch {
          result(FlutterError(code: "monitor_failed", message: error.localizedDescription, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    #endif
  }

  private static func components(_ text: String?) -> DateComponents? {
    guard let text else { return nil }
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "h:mm a"
    guard let date = f.date(from: text) else { return nil }
    return Calendar.current.dateComponents([.hour, .minute], from: date)
  }
}

/// Persists each schedule's FamilyActivitySelection (opaque tokens, Codable) so the app,
/// the DeviceActivityMonitor extension and the ShieldConfiguration extension share it.
/// In production this lives in an App Group container.
@available(iOS 16.0, *)
enum SelectionStore {
  static func load(_ id: String) -> FamilyActivitySelection {
    guard let data = UserDefaults.standard.data(forKey: "selection.\(id)"),
      let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    else { return FamilyActivitySelection() }
    return selection
  }

  static func save(_ selection: FamilyActivitySelection, for id: String) {
    UserDefaults.standard.set(try? JSONEncoder().encode(selection), forKey: "selection.\(id)")
  }
}
