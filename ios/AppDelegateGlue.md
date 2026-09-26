# AppDelegate glue

The four plugin files in this directory (`FlutterWatchKitPlugin.swift`,
`WatchKitSessionService.swift`, `WatchKitEventDispatcher.swift`,
`WatchKitSessionCache.swift`) are plain Swift sources, not a pod/SwiftPM
package. Add them to your app's **Runner target** in Xcode (drag in, "Copy
items if needed", target membership = the iOS app target).

The plugin is not auto-registered via `GeneratedPluginRegistrant`; wire it
in `AppDelegate.swift` yourself. Two concerns: activate the WCSession early
at launch, and register the method/event channels on every Flutter engine
the app creates (main engine + any background/implicit engines, e.g. the
one `flutter_local_notifications` spins up in its plugin registrant
callback).

## Snippet

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  static let watchGlue = WatchKitAppGlue()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    Self.watchGlue.applicationDidFinishLaunching()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Called for the implicitly created engine (Flutter 3.x implicit engine).
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    Self.watchGlue.registerPlugin(with: engineBridge.pluginRegistry)
  }
}

struct WatchKitAppGlue {
  func applicationDidFinishLaunching() {
    WatchKitSessionService.shared.activateSession()
  }

  func registerPlugin(with registry: FlutterPluginRegistry) {
    if registry.hasPlugin("FlutterWatchKitPlugin") { return }
    guard let registrar = registry.registrar(forPlugin: "FlutterWatchKitPlugin") else { return }
    FlutterWatchKitPlugin.register(with: registrar)
  }
}
```

## Insertion points

1. **Launch activation** — `application(_:didFinishLaunchingWithOptions:)`,
   before `super.application(...)`. WCSession activation is asynchronous and
   slow; starting it here means the session is usually `activated` by the
   time Dart first calls `activate`/`status`.
2. **Implicit engine** — `didInitializeImplicitFlutterEngine(_:)`, after
   `GeneratedPluginRegistrant.register(with:)`. Skip this override entirely
   if your app never uses implicit/background engines.
3. **Background engine callbacks** — if a plugin (e.g. local notifications)
   creates its own engine via a plugin registrant callback, call
   `watchGlue.registerPlugin(with:)` in that callback too, guarded by
   `registry.hasPlugin(...)` as shown.

## Notes

- If your app does not use implicit engines at all, the minimal wiring is
  just insertion point 1 plus registering the plugin in
  `application(_:didFinishLaunchingWithOptions:)` via
  `registrar(forPlugin:)` on `self`.
- The channel names (`flutter_watchkit/methods`, `flutter_watchkit/events`)
  must match the Dart side
  (`packages/flutter_watchkit/lib/src/watch/plugin_watch_connectivity_client.dart`).
  See `docs/protocol.md` for the full contract.
