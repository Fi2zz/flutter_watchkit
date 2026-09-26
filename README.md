# flutter_watchkit

Generic Flutter ↔ Apple Watch connectivity plugin built on
`WatchConnectivity` (`WCSession`). It provides only the transport layer —
session activation, connection status, applicationContext push, and
bidirectional messages/commands — with no app-specific semantics. Payload
keys are entirely yours: the framework defines the envelope and the
transport, not the business schema.

iOS / watchOS only. No Android or WearOS support.

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
│ iOS plugin (SwiftPM)                               │                 │
│  FlutterWatchKitPlugin ── WatchKitSessionService ──┴─ WCSession      │
│       └─ WatchKitEventDispatcher / WatchKitSessionCache              │
└──────────────────────────────────────────────────────────────────────┘
```

- **Plugin package** (repo root): Dart state coordinator, bridge with
  caching/dedup of reliable commands, and a MethodChannel/EventChannel
  client (`lib/`), plus the iOS native implementation
  (`ios/flutter_watchkit/`, SwiftPM, iOS 13+).
- **Example app** (`example/`): runnable Flutter app showing status,
  context push, and command handling; `example/watch_app/` holds the
  companion watchOS reference sources.

## Quick start

1. Add the package as a dependency (path or git):
   ```yaml
   dependencies:
     flutter_watchkit:
       path: flutter_watchkit
   ```
2. `flutter pub get` — the iOS plugin registers itself through the
   generated plugin registrant. No manual Swift wiring needed.
3. Use the coordinator:
   ```dart
   final coordinator = WatchKitCoordinator(enabled: true);
   coordinator.onCommand = (command) { /* route watch commands */ };
   coordinator.start();
   await coordinator.refresh();
   if (coordinator.connected) {
     await coordinator.pushContext({'screen': 'home'});
   }
   ```
4. Add a watchOS App target in Xcode (see `example/README.md` for the
   step-by-step) and use `example/watch_app/` as a starting point.

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

## Notes

- **Early session activation**: WCSession activation is asynchronous and
  slow. If your app needs the session warm before Dart first calls
  `activate`/`status`, call `WatchKitSessionService.shared.activateSession()`
  from `application(_:didFinishLaunchingWithOptions:)` in your AppDelegate.
  Background/implicit Flutter engines get the plugin registered
  automatically via the generated registrant, same as any other plugin.
- **Channel names**: `flutter_watchkit/methods` and
  `flutter_watchkit/events`, defined in
  `lib/src/watch/plugin_watch_connectivity_client.dart` and
  `ios/flutter_watchkit/Sources/flutter_watchkit/FlutterWatchKitPlugin.swift`;
  change both sides together if you need different names.
  See `docs/protocol.md` for the full contract.
- **Payload schema**: free-form. Convention used by the demo: phone → watch
  arbitrary context map; watch → phone `{ "action": "<string>", ... }`.
- **App Groups / entitlements**: the plugin ships none. Add an App Group to
  both targets only if you need shared storage beyond `WCSession`.

## Origin

This framework was extracted from the Apple Watch connectivity layer of the
Lifts workout app (`packages/lifts_watch` and the `ios/Runner`
WatchConnectivity plugin in that repository), generalized to remove all
workout-domain semantics. Behavioral logic (session lifecycle, cache drain,
command dedup, message fallback) is unchanged from that implementation.
