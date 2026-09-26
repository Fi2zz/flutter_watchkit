import 'package:flutter/services.dart';

import 'watch_connectivity_client.dart';
import 'watch_connectivity_codec.dart';

final class PluginWatchConnectivityClient implements WatchConnectivityClient {
  PluginWatchConnectivityClient();
  static const _nativeChannel = MethodChannel('flutter_watchkit/methods');
  static const _nativeEvents = EventChannel('flutter_watchkit/events');
  late final Stream<NativeWatchEvent> _eventStream = _nativeEvents
      .receiveBroadcastStream()
      .map(eventEnvelopeOf)
      .where((event) => event.payload.isNotEmpty)
      .asBroadcastStream();
  @override
  Future<void> activate() async =>
      _nativeChannel.invokeMethod<void>('activate');
  @override
  Future<Map<String, Object?>> status() async {
    final snapshot = await _nativeChannel.invokeMapMethod<String, dynamic>(
      'status',
    );
    if (snapshot == null) return const {};
    return mapOf(snapshot);
  }

  @override
  Future<String> activationLabel() async =>
      '${(await status())['activationState'] ?? 'notActivated'}';
  @override
  Future<bool> supportedDevice() => _flag('supported');
  @override
  Future<bool> pairedDevice() => _flag('paired');
  @override
  Future<bool> installedWatchApp() => _flag('watchAppInstalled');
  @override
  Future<bool> reachableDevice() => _flag('reachable');
  @override
  Future<Map<String, Object?>> applicationContext() =>
      _payloadFromStatus('latestContext');
  @override
  Future<Map<String, Object?>> latestUserInfo() =>
      _payloadFromStatus('latestUserInfo');
  @override
  Future<void> clearLatestUserInfo() =>
      _nativeChannel.invokeMethod<void>('clearLatestUserInfo');
  @override
  Stream<Map<String, Object?>> commandStream() => _streamFor('message');
  @override
  Stream<Map<String, Object?>> reliableCommandStream() =>
      _streamFor('userInfo');
  @override
  Future<void> updateContext(Map<String, Object?> payload) {
    return _nativeChannel.invokeMethod<void>(
      'updateApplicationContext',
      dynamicMapOf(payload),
    );
  }

  @override
  Future<void> transferUserInfo(Map<String, Object?> payload) async {
    await _nativeChannel.invokeMethod<void>(
      'transferUserInfo',
      dynamicMapOf(payload),
    );
  }

  @override
  Future<Map<String, Object?>?> sendMessage(
    Map<String, Object?> payload,
  ) async {
    final reply = await _nativeChannel.invokeMethod<dynamic>(
      'sendMessage',
      dynamicMapOf(payload),
    );
    if (reply is! Map) return null;
    return objectMapOf(reply);
  }

  Future<bool> _flag(String key) async => (await status())[key] == true;
  Stream<Map<String, Object?>> _streamFor(String kind) {
    return _eventStream
        .where((event) => event.kind == kind)
        .map((event) => event.payload);
  }

  Future<Map<String, Object?>> _payloadFromStatus(String key) async {
    final payload = (await status())[key];
    if (payload is! Map) return const {};
    return objectMapOf(payload);
  }
}
