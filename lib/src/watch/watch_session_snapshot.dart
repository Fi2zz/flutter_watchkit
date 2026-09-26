final class WatchSessionSnapshot {
  const WatchSessionSnapshot({
    required this.supported,
    required this.paired,
    required this.watchAppInstalled,
    required this.reachable,
    required this.activationState,
    required this.latestContext,
    required this.latestMessage,
    required this.latestUserInfo,
  });

  static const empty = WatchSessionSnapshot(
    supported: false,
    paired: false,
    watchAppInstalled: false,
    reachable: false,
    activationState: 'unsupported',
    latestContext: {},
    latestMessage: {},
    latestUserInfo: {},
  );

  final bool supported;
  final bool paired;
  final bool watchAppInstalled;
  final bool reachable;
  final String activationState;
  final Map<String, Object?> latestContext;
  final Map<String, Object?> latestMessage;
  final Map<String, Object?> latestUserInfo;

  WatchSessionSnapshot copyWith({
    bool? supported,
    bool? paired,
    bool? watchAppInstalled,
    bool? reachable,
    String? activationState,
    Map<String, Object?>? latestContext,
    Map<String, Object?>? latestMessage,
    Map<String, Object?>? latestUserInfo,
  }) {
    return WatchSessionSnapshot(
      supported: supported ?? this.supported,
      paired: paired ?? this.paired,
      watchAppInstalled: watchAppInstalled ?? this.watchAppInstalled,
      reachable: reachable ?? this.reachable,
      activationState: activationState ?? this.activationState,
      latestContext: latestContext ?? this.latestContext,
      latestMessage: latestMessage ?? this.latestMessage,
      latestUserInfo: latestUserInfo ?? this.latestUserInfo,
    );
  }
}
