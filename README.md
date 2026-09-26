# flutter_watchkit

Generic Flutter ↔ Apple Watch connectivity framework built on
`WatchConnectivity` (`WCSession`). It provides only the transport layer —
session activation, connection status, applicationContext push, and
bidirectional messages/commands — with no app-specific semantics. Payload
keys are entirely yours: the framework defines the envelope and the
transport, not the business schema.

## Architecture

```
┌─────────────────────────────┐         ┌──────────────────────────────┐
│ Flutter app (Dart)          │         │ watchOS app (SwiftUI)        │
│                             │         │                              │
│  WatchKitCoordinator        │         │  WatchSessionStore           │
│    └─ WatchKitBridge        │         │    └─ WCSession.default      │
│         └─ WatchConnectivityClient     │         ▲                    │
│              └─ PluginWatchConnectivityClient      │                 │
│                    │ MethodChannel / EventChannel  │                 │
└────────────────────┼─────────────┴─────────────────┼─────────────────┘
                     ▼                               │
┌────────────────────────────────────────────────────┼─────────────────┐
│ iOS Runner (Swift plugin, local sources)           │                 │
│  FlutterWatchKitPlugin ── WatchKitSessionService ──┴─ WCSession      │
│       └─ WatchKitEventDispatcher / WatchKitSessionCache              │
└──────────────────────────────────────────────────────────────────────┘
```

- **Dart package** (`packages/flutter_watchkit/`): state coordinator,
  bridge with caching/dedup of reliable commands, and a
  MethodChannel/EventChannel client.
- **iOS plugin** (`ios/`): four plain Swift files added to your Runner
  target; owns the phone-side `WCSession` and re-emits watch-originated
  events onto the EventChannel.
- **watch app** (`watch_app/`): minimal SwiftUI demo (watchOS 10) showing
  activation, latest applicationContext rendering, and a ping command with
  `sendMessage` → `transferUserInfo` fallback.

## Dart API

| Type | Role |
|---|---|
| `WatchKitCoordinatorContract` | Abstract coordinator: `enabled`, `connected`, `status`, `updateEnabled`, `refresh`, `pushContext`. |
| `WatchKitCoordinator` | `ChangeNotifier` implementation; `start()`, `onCommand` setter. |
| `NoOpWatchKitCoordinator` | Disabled no-op implementation for non-iOS platforms or feature-off. |
| `WatchStatus` / `WatchConnectionKind` | Connection state: `disabled`, `connecting`, `connected`, `waitingWatch`, `watchAppMissing`, `unpaired`, `unsupported`. |
| `WatchKitBridge` | Transport facade: `activate`, `fetchStatus`, `pushContext`, `queueUserInfo`, `deliverMessage`, `onCommand`. Dedupes reliable commands via `WatchUserInfoDrain`. |
| `WatchContextSync` | Push helper: context dedup (`push`) and retry-until-activated (`pushWhenReady`). |
| `WatchConnectivityClient` | Low-level client interface; `PluginWatchConnectivityClient` is the channel-backed implementation. |
| `WatchSessionSnapshot` | Immutable snapshot of session state plus latest context/message/userInfo. |

## Integration into a new project

1. `flutter create` your app (iOS bundle id of your choice).
2. Add the Dart package as a path dependency:
   ```yaml
   dependencies:
     flutter_watchkit:
       path: flutter_watchkit/packages/flutter_watchkit
   ```
3. In Xcode, add a **watchOS App target** (Watch App, SwiftUI, watchOS 10+)
   and drag `watch_app/` sources in as a starting point (or write your own
   against the same `WCSession` patterns).
4. Drag the four Swift files from `ios/` into the **Runner target**, then
   wire `AppDelegate.swift` following `ios/AppDelegateGlue.md`.
5. Wire the Dart side per `example/main.dart`.

## Customization

- **Bundle ids / signing team**: set in Xcode for both targets. The watch
  app's `WKCompanionAppBundleIdentifier` must match the iOS app bundle id.
- **Channel names**: defined in
  `packages/flutter_watchkit/lib/src/watch/plugin_watch_connectivity_client.dart`
  and `ios/FlutterWatchKitPlugin.swift`; change both sides together if you
  need different names.
- **App Groups / entitlements**: the demo intentionally ships none. Add an
  App Group to both targets only if you need shared storage beyond
  `WCSession`.
- **Payload schema**: free-form. Convention used by the demo: phone → watch
  arbitrary context map; watch → phone `{ "action": "<string>", ... }`.

## Limitations

- The Swift sources are provided as syntax-reviewed code without an Xcode
  project; they have **not been compiled** in this repository. Build them in
  your own project before shipping.
- iOS/Apple Watch only. No WearOS support.

## Origin

This framework was extracted from the Apple Watch connectivity layer of the
Lifts workout app (`packages/lifts_watch` and the `ios/Runner`
WatchConnectivity plugin in that repository), generalized to remove all
workout-domain semantics. Behavioral logic (session lifecycle, cache drain,
command dedup, message fallback) is unchanged from that implementation.
