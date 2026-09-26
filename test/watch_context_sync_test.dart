import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_watchkit/flutter_watchkit.dart';

import 'fake_watch_client.dart';

void main() {
  test('WatchContextSync skips push when watch is disabled', () async {
    final client = FakeWatchClient(
      supported: true,
      paired: true,
      watchAppInstalled: true,
      reachable: true,
      activationState: 'activated',
    );
    final sync = WatchContextSync(
      bridge: WatchKitBridge.test(client: client),
      watchEnabled: () => false,
    );

    await sync.activate();
    await sync.push(const {'screen': 'home'});

    expect(client.activateCount, 0);
    expect(client.updatedContext, isEmpty);
  });
}
