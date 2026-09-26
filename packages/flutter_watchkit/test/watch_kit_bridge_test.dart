import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_watchkit/flutter_watchkit.dart';

import 'fake_watch_connectivity_client.dart';

void main() {
  test('fetchStatus returns cached context and latest message', () async {
    final commands = StreamController<Map<String, Object?>>();
    final bridge = WatchKitBridge.test(
      client: FakeWatchConnectivityClient(
        supported: true,
        paired: true,
        watchAppInstalled: true,
        reachable: true,
        activationState: 'activated',
        context: const {'phase': 'idle'},
        commands: commands.stream,
      ),
    );

    bridge.start();
    commands.add(const {'action': 'ping'});
    await Future<void>.delayed(Duration.zero);
    final snapshot = await bridge.fetchStatus();

    expect(snapshot.supported, isTrue);
    expect(snapshot.activationState, 'activated');
    expect(snapshot.latestContext, const {'phase': 'idle'});
    expect(snapshot.latestMessage, const {'action': 'ping'});
    await commands.close();
  });

  test(
    'queueUserInfo forwards reliable commands into latestUserInfo',
    () async {
      final client = FakeWatchConnectivityClient(
        supported: true,
        paired: true,
        watchAppInstalled: true,
      );
      final bridge = WatchKitBridge.test(client: client);

      final snapshot = await bridge.queueUserInfo(const {'action': 'ping'});

      expect(client.transferredUserInfo, const {'action': 'ping'});
      expect(snapshot.latestUserInfo, const {'action': 'ping'});
    },
  );

  test(
    'reliable command 分发到 onCommand 回调',
    () async {
      final reliable = StreamController<Map<String, Object?>>();
      final bridge = WatchKitBridge.test(
        client: FakeWatchConnectivityClient(
          reliableCommands: reliable.stream,
        ),
      );
      final received = <Map<String, Object?>>[];
      bridge.onCommand = received.add;

      bridge.start();
      reliable.add(const {'action': 'ping', 'delta': 30});
      await Future<void>.delayed(Duration.zero);

      expect(received, [
        const {'action': 'ping', 'delta': 30},
      ]);
      await reliable.close();
    },
  );

  test(
    '即时 message 通道同样分发到 onCommand 回调',
    () async {
      final messages = StreamController<Map<String, Object?>>();
      final bridge = WatchKitBridge.test(
        client: FakeWatchConnectivityClient(commands: messages.stream),
      );
      final received = <Map<String, Object?>>[];
      bridge.onCommand = received.add;

      bridge.start();
      messages.add(const {'action': 'ping', 'delta': -30});
      await Future<void>.delayed(Duration.zero);

      expect(received, [
        const {'action': 'ping', 'delta': -30},
      ]);
      await messages.close();
    },
  );

  test('fetchStatus prefers native snapshot for activation fields', () async {
    final bridge = WatchKitBridge.test(
      client: FakeWatchConnectivityClient(
        supported: true,
        paired: true,
        watchAppInstalled: false,
        reachable: false,
        activationState: 'inactive',
        context: const {'screen': 'idle', 'status': 'idle'},
        cachedUserInfo: const {'action': 'ping', 'sentAt': '1'},
      ),
    );

    final snapshot = await bridge.fetchStatus();

    expect(snapshot.activationState, 'inactive');
    expect(snapshot.watchAppInstalled, isFalse);
    expect(snapshot.reachable, isFalse);
    expect(snapshot.latestUserInfo, const {'action': 'ping', 'sentAt': '1'});
  });

  test('fetchStatus 补发监听空窗期缓存的 userInfo 命令并清缓存', () async {
    final client = FakeWatchConnectivityClient(
      supported: true,
      paired: true,
      watchAppInstalled: true,
      cachedUserInfo: const {'action': 'ping'},
    );
    final bridge = WatchKitBridge.test(client: client);
    final received = <Map<String, Object?>>[];
    bridge.onCommand = received.add;

    await bridge.fetchStatus();

    expect(received, [const {'action': 'ping'}]);
    expect(client.cachedUserInfo, isEmpty);
  });

  test('活通道已分发的 userInfo 命令不被 fetchStatus 重复应用', () async {
    final reliable = StreamController<Map<String, Object?>>();
    final client = FakeWatchConnectivityClient(
      supported: true,
      reliableCommands: reliable.stream,
    );
    final bridge = WatchKitBridge.test(client: client);
    final received = <Map<String, Object?>>[];
    bridge.onCommand = received.add;

    bridge.start();
    reliable.add(const {'action': 'ping', 'reps': 3});
    await Future<void>.delayed(Duration.zero);
    // The native side also caches on live delivery (see WatchKitSessionService).
    client.cachedUserInfo = const {'action': 'ping', 'reps': 3};
    await bridge.fetchStatus();

    expect(received, [
      const {'action': 'ping', 'reps': 3},
    ]);
    await reliable.close();
  });
}
