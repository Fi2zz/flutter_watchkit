abstract interface class WatchConnectivityClient {
  Future<void> activate();
  Future<Map<String, Object?>> status();
  Future<String> activationLabel();
  Future<bool> supportedDevice();
  Future<bool> pairedDevice();
  Future<bool> installedWatchApp();
  Future<bool> reachableDevice();
  Future<Map<String, Object?>> applicationContext();
  Future<Map<String, Object?>> latestUserInfo();
  Future<void> clearLatestUserInfo();
  Stream<Map<String, Object?>> commandStream();
  Stream<Map<String, Object?>> reliableCommandStream();
  Future<void> updateContext(Map<String, Object?> payload);
  Future<void> transferUserInfo(Map<String, Object?> payload);
  Future<Map<String, Object?>?> sendMessage(Map<String, Object?> payload);
}
