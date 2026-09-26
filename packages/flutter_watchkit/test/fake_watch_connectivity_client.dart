import 'package:flutter_watchkit/flutter_watchkit.dart';

final class FakeWatchConnectivityClient implements WatchConnectivityClient {
  FakeWatchConnectivityClient({
    this.supported = false,
    this.paired = false,
    this.watchAppInstalled = false,
    this.reachable = false,
    this.activationState = 'notActivated',
    this.context = const {},
    this.cachedUserInfo = const {},
    Stream<Map<String, Object?>>? commands,
    Stream<Map<String, Object?>>? reliableCommands,
  }) : _commands = commands ?? const Stream.empty(),
       _reliableCommands = reliableCommands ?? const Stream.empty();

  final bool supported;
  final bool paired;
  final bool watchAppInstalled;
  final bool reachable;
  final String activationState;
  final Map<String, Object?> context;
  Map<String, Object?> cachedUserInfo;
  final Stream<Map<String, Object?>> _commands;
  final Stream<Map<String, Object?>> _reliableCommands;
  Map<String, Object?> transferredUserInfo = const {};
  Map<String, Object?> updatedContext = const {};

  @override
  Future<void> activate() async {}

  @override
  Future<Map<String, Object?>> status() async {
    return {
      'supported': supported,
      'paired': paired,
      'watchAppInstalled': watchAppInstalled,
      'reachable': reachable,
      'activationState': activationState,
      'latestUserInfo': cachedUserInfo,
    };
  }

  @override
  Future<String> activationLabel() async => activationState;

  @override
  Future<Map<String, Object?>> applicationContext() async => context;

  @override
  Future<void> clearLatestUserInfo() async {
    cachedUserInfo = const {};
    transferredUserInfo = const {};
  }

  @override
  Stream<Map<String, Object?>> commandStream() => _commands;

  @override
  Stream<Map<String, Object?>> reliableCommandStream() => _reliableCommands;

  @override
  Future<Map<String, Object?>> latestUserInfo() async => cachedUserInfo;

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
    cachedUserInfo = Map<String, Object?>.from(payload);
    transferredUserInfo = Map<String, Object?>.from(payload);
  }

  @override
  Future<void> updateContext(Map<String, Object?> payload) async {
    updatedContext = Map<String, Object?>.from(payload);
  }
}
