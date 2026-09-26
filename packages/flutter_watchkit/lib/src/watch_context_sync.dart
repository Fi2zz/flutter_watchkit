import 'package:flutter/foundation.dart';
import 'watch/watch_kit_bridge.dart';

class WatchContextSync {
  WatchContextSync({WatchKitBridge? bridge, bool Function()? watchEnabled})
    : _bridge = bridge ?? WatchKitBridge(),
      _watchEnabled = watchEnabled ?? _alwaysEnabled;

  final WatchKitBridge _bridge;
  final bool Function() _watchEnabled;
  Map<String, Object?> _lastPayload = const {};
  static const _maxAttempts = 5;

  static bool _alwaysEnabled() => true;

  Future<void> activate() async {
    if (!_watchEnabled()) return;
    await _bridge.activate();
  }

  Future<void> push(Map<String, Object?> payload) async {
    if (!_watchEnabled()) return;
    final samePayload = mapEquals(_lastPayload, payload);
    if (samePayload) return;
    await _bridge.pushContext(payload);
    _lastPayload = payload;
  }

  Future<void> pushWhenReady(Map<String, Object?> Function() payloadOf) async {
    if (!_watchEnabled()) return;
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final snapshot = await _bridge.fetchStatus();
      if (snapshot.activationState != 'activated') {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        continue;
      }
      try {
        await push(payloadOf());
        return;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
  }
}
