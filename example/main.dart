import 'package:flutter_watchkit/flutter_watchkit.dart';

Future<void> main() async {
  final bridge = WatchKitBridge(client: PluginWatchConnectivityClient());
  final coordinator = WatchKitCoordinator(bridge: bridge, enabled: true);

  coordinator.onCommand = handleWatchCommand;
  coordinator.start();
  await coordinator.refresh();

  if (coordinator.connected) {
    await coordinator.pushContext(const {'screen': 'home'});
  }
}

void handleWatchCommand(Map<String, Object?> command) {
  final action = command['action'];
  if (action == 'ping') {
    // Route to your app logic here.
  }
}
