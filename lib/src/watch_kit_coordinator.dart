import 'dart:async';

import 'package:flutter/widgets.dart';

import 'contract/watch_kit_coordinator_contract.dart';
import 'contract/watch_status.dart';
import 'watch/watch_kit_bridge.dart';
import 'watch/watch_session_snapshot.dart';

class WatchKitCoordinator extends ChangeNotifier
    implements WatchKitCoordinatorContract {
  WatchKitCoordinator({WatchKitBridge? bridge, required bool enabled})
    : _bridge = bridge ?? WatchKitBridge(),
      _enabled = enabled,
      _status = enabled
          ? const WatchStatus.connecting()
          : const WatchStatus.disabled();

  final WatchKitBridge _bridge;
  bool _enabled;
  WatchStatus _status;
  bool _started = false;
  bool _disposed = false;

  @override
  bool get enabled => _enabled;

  @override
  bool get connected => _status.connected;

  /// Forwards the bridge's watch command callback (both channels unified);
  /// the host app binds its command router here.
  set onCommand(void Function(Map<String, Object?> command)? handler) {
    _bridge.onCommand = handler;
  }

  @override
  WatchStatus get status => _status;

  void start() {
    if (!enabled) {
      _updateStatus(const WatchStatus.disabled());
      return;
    }
    if (_started) return;
    _started = true;
    unawaited(refresh());
  }

  @override
  void updateEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) return _disable();
    _updateStatus(const WatchStatus.connecting());
    start();
  }

  @override
  Future<void> refresh() async {
    if (!enabled) return _disable();
    _updateStatus(const WatchStatus.connecting());
    try {
      await _bridge.activate();
      final latest = await _bridge.fetchStatus();
      _updateStatus(_statusFromSnapshot(latest));
    } catch (_) {
      _updateStatus(const WatchStatus.connecting());
    }
  }

  void _disable() {
    _started = false;
    _updateStatus(const WatchStatus.disabled());
  }

  void _updateStatus(WatchStatus next) {
    if (_disposed) return;
    _status = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  static WatchStatus _statusFromSnapshot(WatchSessionSnapshot snapshot) {
    if (!snapshot.supported) return const WatchStatus.unsupported();
    if (!snapshot.paired) return const WatchStatus.unpaired();
    if (snapshot.reachable) return const WatchStatus.connected();
    if (!snapshot.watchAppInstalled) return const WatchStatus.watchAppMissing();
    return const WatchStatus.waitingWatch();
  }

  @override
  Future<void> pushContext(Map<String, Object?> context) async {
    if (!enabled) return;
    await _bridge.pushContext(context);
  }
}
