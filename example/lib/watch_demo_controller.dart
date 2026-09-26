import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_watchkit/flutter_watchkit.dart';

final class WatchDemoController extends ChangeNotifier {
  WatchDemoController() {
    coordinator.onCommand = _handleWatchCommand;
    coordinator.start();
    unawaited(refresh());
  }

  final WatchKitBridge _bridge = WatchKitBridge();
  late final WatchKitCoordinator coordinator = WatchKitCoordinator(
    bridge: _bridge,
    enabled: true,
  );

  String activationState = 'unknown';
  Map<String, Object?>? lastCommand;

  Future<void> refresh() async {
    await coordinator.refresh();
    final snapshot = await _bridge.fetchStatus();
    activationState = snapshot.activationState;
    notifyListeners();
  }

  Future<void> pushDemoContext() async {
    await coordinator.pushContext({
      'screen': 'home',
      'pushedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sendDemoMessage() async {
    await _bridge.deliverMessage({'action': 'ping', 'from': 'phone'});
  }

  void _handleWatchCommand(Map<String, Object?> command) {
    lastCommand = command;
    notifyListeners();
  }

  @override
  void dispose() {
    coordinator.dispose();
    unawaited(_bridge.dispose());
    super.dispose();
  }
}
