import 'dart:async';

import 'package:flutter/foundation.dart';

import 'watch_status.dart';

abstract class WatchKitCoordinatorContract extends ChangeNotifier {
  bool get enabled;
  bool get connected;
  WatchStatus get status;
  void updateEnabled(bool enabled);

  /// Reactivates the session and pulls the latest connection state;
  /// short-circuits while disabled (including non-iOS platforms).
  Future<void> refresh();
  Future<void> pushContext(Map<String, Object?> context);
}

class NoOpWatchKitCoordinator extends ChangeNotifier
    implements WatchKitCoordinatorContract {
  NoOpWatchKitCoordinator() : _status = const WatchStatus.disabled();

  WatchStatus _status;

  @override
  bool get enabled => false;

  @override
  bool get connected => false;

  @override
  WatchStatus get status => _status;

  @override
  void updateEnabled(bool enabled) {
    _status = enabled
        ? const WatchStatus.connecting()
        : const WatchStatus.disabled();
    notifyListeners();
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> pushContext(Map<String, Object?> context) async {}
}
