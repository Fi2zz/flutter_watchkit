import 'watch_session_snapshot.dart';

WatchSessionSnapshot snapshotOf({
  required Map<String, Object?> status,
  required Map<String, Object?> latestContext,
  required Map<String, Object?> latestMessage,
  required Map<String, Object?> latestUserInfo,
}) {
  final supported = status['supported'] == true;
  if (!supported) return WatchSessionSnapshot.empty;
  return WatchSessionSnapshot(
    supported: supported,
    paired: status['paired'] == true,
    watchAppInstalled: status['watchAppInstalled'] == true,
    reachable: status['reachable'] == true,
    activationState: '${status['activationState'] ?? 'notActivated'}',
    latestContext: latestContext,
    latestMessage: latestMessage,
    latestUserInfo: latestUserInfo,
  );
}
