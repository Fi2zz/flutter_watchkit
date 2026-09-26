import Flutter
import Foundation

final class WatchKitEventDispatcher {
  static let shared = WatchKitEventDispatcher()
  private static let kindKey = "kind"
  private static let payloadKey = "payload"

  private init() {}

  private var eventSink: FlutterEventSink?

  func updateSink(_ sink: FlutterEventSink?) {
    eventSink = sink
  }

  func emitMessage(_ payload: [String: Any]) {
    emit(kind: "message", payload: payload)
  }

  func emitUserInfo(_ payload: [String: Any]) {
    emit(kind: "userInfo", payload: payload)
  }

  private func emit(kind: String, payload: [String: Any]) {
    let event = [
      Self.kindKey: kind,
      Self.payloadKey: payload,
    ] as [String: Any]
    DispatchQueue.main.async { self.eventSink?(event) }
  }
}
