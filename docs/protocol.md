# Protocol contract

Contract between the Dart package (repo root, `lib/`), the iOS plugin
sources (`ios/flutter_watchkit/Sources/flutter_watchkit/`), and any watchOS
app talking to the phone over `WCSession`. The framework owns envelope and
transport only; payload keys inside `payload`/`context` maps are
app-defined.

## Channels

| Channel | Type | Purpose |
|---|---|---|
| `flutter_watchkit/methods` | `MethodChannel` | Phone-side commands from Dart to the iOS plugin. |
| `flutter_watchkit/events` | `EventChannel` | Watch-originated events pushed from the iOS plugin to Dart. |

Both names are compile-time constants on each side:
`PluginWatchConnectivityClient` (Dart) and `FlutterWatchKitPlugin` (Swift).
They must always match.

## Methods (Dart → iOS)

All payloads are string-keyed maps with plist-encodable values.

| Method | Arguments | Returns | Notes |
|---|---|---|---|
| `activate` | — | snapshot map | Activates the `WCSession` (idempotent), returns a snapshot. |
| `status` | — | snapshot map | Current session state plus cached latest context/message/userInfo. |
| `updateApplicationContext` | `Map` payload | snapshot map | Replaces the applicationContext pushed to the watch. Throws on failure. |
| `transferUserInfo` | `Map` payload | snapshot map | Queues a reliable background transfer to the watch. |
| `clearLatestUserInfo` | — | null | Clears the natively cached latest userInfo entry. |
| `sendMessage` | `Map` payload | reply map or null | Instant message to a reachable watch; fails with `UNREACHABLE` otherwise. |

### Snapshot map

```json
{
  "supported": true,
  "paired": true,
  "watchAppInstalled": true,
  "reachable": false,
  "activationState": "activated",
  "latestContext": { "...": "..." },
  "latestMessage": { "...": "..." },
  "latestUserInfo": { "...": "..." }
}
```

`activationState` ∈ `notActivated | inactive | activated | notSupported |
unknown`. When `supported` is false the remaining booleans are false and
`activationState` is `notSupported`.

## Error codes (`FlutterError.code`)

| Code | Raised by | Meaning |
|---|---|---|
| `UNSUPPORTED` | all transport methods | `WCSession` unavailable on this device. |
| `NOT_ACTIVATED` | context / userInfo / sendMessage | Session not yet `activated`; retry after activation completes. |
| `UNREACHABLE` | `sendMessage` | Watch app not reachable; use `transferUserInfo` instead. |
| `SEND_FAILED` | `sendMessage` | `sendMessage` error handler fired; message carries the OS error. |
| `CONTEXT_FAILED` | `updateApplicationContext` | `updateApplicationContext` threw; message carries the OS error. |
| `TRANSFER_FAILED` | `transferUserInfo` | Transfer failed; message carries the OS error. |
| `INVALID_ARGS` | payload-bearing methods | Arguments were not a string-keyed map. |

## Events (iOS → Dart)

Each event on `flutter_watchkit/events` is an envelope map:

```json
{ "kind": "message" | "userInfo", "payload": { "...": "..." } }
```

- `kind: "message"` — watch sent via `WCSession.sendMessage` (instant
  channel; requires the phone to be reachable from the watch).
- `kind: "userInfo"` — watch sent via `WCSession.transferUserInfo`
  (reliable queued channel; delivered even across app relaunches).

Both kinds additionally land in the native cache
(`WatchKitSessionCache.latestMessage` / `latestUserInfo`) and surface in
subsequent `status` snapshots. The Dart side exposes them as
`commandStream()` (message) and `reliableCommandStream()` (userInfo), and
`WatchUserInfoDrain` dedupes cached userInfo entries against live-channel
delivery so a command is applied exactly once.

## Watch → phone command convention

The demo uses `{ "action": "ping" }`. The framework only requires a
string-keyed map; the `action` string is a convention, not enforced.
