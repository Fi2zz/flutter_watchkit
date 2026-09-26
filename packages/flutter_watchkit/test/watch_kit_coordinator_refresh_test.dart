import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_watchkit/flutter_watchkit.dart';

import 'fake_watch_client.dart';

void main() {
  test('refresh activates bridge and reports connected status', () async {
    final client = FakeWatchClient(
      supported: true,
      paired: true,
      watchAppInstalled: true,
      reachable: true,
      activationState: 'activated',
    );
    final coordinator = WatchKitCoordinator(
      bridge: WatchKitBridge.test(client: client),
      enabled: true,
    );

    await coordinator.refresh();

    expect(client.activateCount, greaterThan(0));
    expect(coordinator.status.connected, isTrue);
  });

  test('disabled coordinator never activates bridge on refresh', () async {
    final client = FakeWatchClient(
      supported: true,
      paired: true,
      watchAppInstalled: true,
      reachable: true,
      activationState: 'activated',
    );
    final coordinator = WatchKitCoordinator(
      bridge: WatchKitBridge.test(client: client),
      enabled: false,
    );

    await coordinator.refresh();

    expect(coordinator.enabled, isFalse);
    expect(coordinator.status.kind, WatchConnectionKind.disabled);
    expect(client.activateCount, 0);
  });

  test('updateEnabled(true) allows later refresh to activate bridge', () async {
    final client = FakeWatchClient(
      supported: true,
      paired: true,
      watchAppInstalled: true,
      reachable: true,
      activationState: 'activated',
    );
    final coordinator = WatchKitCoordinator(
      bridge: WatchKitBridge.test(client: client),
      enabled: false,
    );

    coordinator.updateEnabled(false);
    coordinator.updateEnabled(true);
    await coordinator.refresh();

    expect(coordinator.enabled, isTrue);
    expect(coordinator.status.connected, isTrue);
    expect(client.activateCount, greaterThan(0));
  });
}
