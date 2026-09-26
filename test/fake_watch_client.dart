import 'package:flutter_watchkit/flutter_watchkit.dart';

final class FakeWatchClient implements WatchConnectivityClient {
  FakeWatchClient({
    this.supported = false,
    this.paired = false,
    this.watchAppInstalled = false,
    this.reachable = false,
    this.activationState = 'notActivated',
    Map<String, Object?> cachedUserInfo = const {},
    Stream<Map<String, Object?>>? commands,
    Stream<Map<String, Object?>>? reliableCommands,
  }) : _commands = commands ?? const Stream.empty(),
       _reliableCommands = reliableCommands ?? const Stream.empty(),
       _cachedUserInfo = Map<String, Object?>.from(cachedUserInfo);

  final bool supported;
  final bool paired;
  final bool watchAppInstalled;
  final bool reachable;
  final String activationState;
  final Stream<Map<String, Object?>> _commands;
  final Stream<Map<String, Object?>> _reliableCommands;
  Map<String, Object?> _cachedUserInfo;
  Map<String, Object?> updatedContext = const {};
  Map<String, Object?> latestUserInfoCache = const {};
  int activateCount = 0;

  @override
  Future<void> activate() async {
    activateCount += 1;
  }

  @override
  Future<Map<String, Object?>> status() async {
    return {
      'supported': supported,
      'paired': paired,
      'watchAppInstalled': watchAppInstalled,
      'reachable': reachable,
      'activationState': activationState,
      'latestUserInfo': _cachedUserInfo,
    };
  }

  @override
  Future<String> activationLabel() async => activationState;

  @override
  Future<Map<String, Object?>> applicationContext() async => updatedContext;

  @override
  Future<void> clearLatestUserInfo() async {
    _cachedUserInfo = const {};
    latestUserInfoCache = const {};
  }

  @override
  Stream<Map<String, Object?>> commandStream() => _commands;

  @override
  Future<Map<String, Object?>> latestUserInfo() async {
    latestUserInfoCache = Map<String, Object?>.from(_cachedUserInfo);
    return latestUserInfoCache;
  }

  @override
  Stream<Map<String, Object?>> reliableCommandStream() => _reliableCommands;

  @override
  Future<bool> installedWatchApp() async => watchAppInstalled;

  @override
  Future<bool> pairedDevice() async => paired;

  @override
  Future<bool> reachableDevice() async => reachable;

  @override
  Future<Map<String, Object?>?> sendMessage(
    Map<String, Object?> payload,
  ) async {
    return null;
  }

  @override
  Future<bool> supportedDevice() async => supported;

  @override
  Future<void> transferUserInfo(Map<String, Object?> payload) async {
    latestUserInfoCache = Map<String, Object?>.from(payload);
  }

  @override
  Future<void> updateContext(Map<String, Object?> payload) async {
    updatedContext = Map<String, Object?>.from(payload);
  }
}
