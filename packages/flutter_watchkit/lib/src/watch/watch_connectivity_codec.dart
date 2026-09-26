Map<String, Object?> mapOf(Map<String, dynamic> value) {
  return value.map((key, entry) => MapEntry(key, entry as Object?));
}

Map<String, Object?> objectMapOf(Map value) {
  return value.map((key, entry) => MapEntry('$key', entry as Object?));
}

Map<String, dynamic> dynamicMapOf(Map<String, Object?> value) {
  return value.map((key, entry) => MapEntry(key, entry));
}

NativeWatchEvent eventEnvelopeOf(dynamic value) {
  if (value is! Map) return const NativeWatchEvent.empty();
  final event = objectMapOf(value);
  final kind = '${event['kind'] ?? ''}';
  final payload = event['payload'];
  if (payload is! Map) {
    return NativeWatchEvent(kind: kind, payload: const {});
  }
  return NativeWatchEvent(kind: kind, payload: objectMapOf(payload));
}

final class NativeWatchEvent {
  const NativeWatchEvent({required this.kind, required this.payload});

  const NativeWatchEvent.empty() : kind = '', payload = const {};

  final String kind;
  final Map<String, Object?> payload;
}
