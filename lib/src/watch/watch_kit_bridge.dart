import 'dart:async';
import 'plugin_watch_connectivity_client.dart';
import 'watch_connectivity_client.dart';
import 'watch_session_snapshot.dart';
import 'watch_session_snapshot_builder.dart';
import 'watch_user_info_drain.dart';

final class WatchKitBridge {
  WatchKitBridge({WatchConnectivityClient? client})
    : _client = client ?? PluginWatchConnectivityClient();
  WatchKitBridge.test({required WatchConnectivityClient client})
    : _client = client;
  final WatchConnectivityClient _client;
  final WatchUserInfoDrain _drain = WatchUserInfoDrain();
  StreamSubscription<Map<String, Object?>>? _messageSubscription;
  StreamSubscription<Map<String, Object?>>? _reliableSubscription;
  Map<String, Object?> _latestContext = const {};
  Map<String, Object?> _latestMessage = const {};
  Map<String, Object?> _latestUserInfo = const {};
  bool _started = false;

  /// Unified dispatch entry for watch commands (sendMessage instant channel
  /// and transferUserInfo reliable channel), bound by the host app; while
  /// unbound, commands only land in the cache.
  void Function(Map<String, Object?> command)? onCommand;
  void start() {
    if (_started) return;
    _started = true;
    _messageSubscription = _client.commandStream().listen(_handleCommand);
    _reliableSubscription = _client.reliableCommandStream().listen(
      _handleReliableCommand,
    );
  }

  Future<WatchSessionSnapshot> activate() async {
    start();
    await _client.activate();
    return _snapshot();
  }

  Future<WatchSessionSnapshot> fetchStatus() async {
    start();
    _latestContext = await _client.applicationContext();
    final drained = await _drain.drain(_client);
    _latestUserInfo = drained.latest;
    if (drained.undelivered != null) onCommand?.call(drained.undelivered!);
    return _snapshot();
  }

  Future<WatchSessionSnapshot> pushContext(
    Map<String, Object?> payload,
  ) async {
    start();
    await _client.updateContext(payload);
    _latestContext = Map<String, Object?>.from(payload);
    return _snapshot();
  }

  Future<WatchSessionSnapshot> queueUserInfo(
    Map<String, Object?> payload,
  ) async {
    start();
    await _client.transferUserInfo(payload);
    _latestUserInfo = Map<String, Object?>.from(payload);
    return _snapshot();
  }

  Future<Map<String, Object?>?> deliverMessage(Map<String, Object?> payload) {
    start();
    return _client.sendMessage(payload);
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _reliableSubscription?.cancel();
  }

  void _handleCommand(Map<String, Object?> command) {
    if (command.isEmpty) return;
    _latestMessage = Map<String, Object?>.from(command);
    onCommand?.call(command);
  }

  void _handleReliableCommand(Map<String, Object?> command) {
    if (command.isEmpty) return;
    _latestUserInfo = Map<String, Object?>.from(command);
    _drain.markDispatched(command);
    onCommand?.call(command);
  }

  Future<WatchSessionSnapshot> _snapshot() async => snapshotOf(
    status: await _client.status(),
    latestContext: _latestContext,
    latestMessage: _latestMessage,
    latestUserInfo: _latestUserInfo,
  );
}
