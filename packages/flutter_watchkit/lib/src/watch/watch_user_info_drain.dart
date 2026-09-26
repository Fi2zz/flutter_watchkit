import 'dart:convert';

import 'watch_connectivity_client.dart';

/// Fallback dispatcher for cached commands: commands arriving via
/// transferUserInfo while the app was killed or before the event-channel
/// listener attached are dropped natively and only land in the cache.
/// On startup/resume, drain fetches the cached entry, republishes it and
/// clears the cache. A jsonEncode fingerprint dedupes against commands
/// already dispatched over the live channel (the native cache keeps only
/// the latest userInfo entry).
final class WatchUserInfoDrain {
  String? _dispatchedKey;

  /// Marks a command dispatched over the live channel
  /// (reliableCommandStream) so drain does not republish it.
  void markDispatched(Map<String, Object?> command) {
    _dispatchedKey = jsonEncode(command);
  }

  /// Reads the natively cached latest userInfo; if it is a fresh command
  /// never dispatched, clears the cache and returns it as undelivered,
  /// otherwise undelivered is null.
  Future<({Map<String, Object?> latest, Map<String, Object?>? undelivered})>
  drain(WatchConnectivityClient client) async {
    final cached = await client.latestUserInfo();
    final fresh = cached.isNotEmpty && jsonEncode(cached) != _dispatchedKey;
    if (!fresh) return (latest: cached, undelivered: null);
    _dispatchedKey = jsonEncode(cached);
    await client.clearLatestUserInfo();
    return (latest: cached, undelivered: cached);
  }
}
