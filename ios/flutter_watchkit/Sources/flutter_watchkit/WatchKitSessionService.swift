import Flutter
import Foundation
import WatchConnectivity

public final class WatchKitSessionService: NSObject, WCSessionDelegate {
  public static let shared = WatchKitSessionService()

  private let cache = WatchKitSessionCache.shared
  private let dispatcher = WatchKitEventDispatcher.shared

  private var session: WCSession? {
    WCSession.isSupported() ? WCSession.default : nil
  }

  public func activateSession() {
    guard let session else { return }
    session.delegate = self
    session.activate()
  }

  public func snapshot() -> [String: Any] {
    guard let session else { return unsupportedSnapshot() }
    return [
      "supported": true,
      "paired": session.isPaired,
      "watchAppInstalled": session.isWatchAppInstalled,
      "reachable": session.isReachable,
      "activationState": activationLabel(for: session.activationState),
      "latestContext": cache.latestContext,
      "latestMessage": cache.latestMessage,
      "latestUserInfo": cache.latestUserInfo,
    ]
  }

  public func updateContext(_ payload: [String: Any]) throws {
    guard let session else { throw watchError("UNSUPPORTED", "WatchConnectivity unavailable.") }
    guard session.activationState == .activated else {
      throw watchError("NOT_ACTIVATED", "WatchConnectivity session is still activating.")
    }
    try session.updateApplicationContext(payload)
    cache.storeContext(payload)
  }

  public func transferUserInfo(_ payload: [String: Any]) throws {
    guard let session else { throw watchError("UNSUPPORTED", "WatchConnectivity unavailable.") }
    guard session.activationState == .activated else {
      throw watchError("NOT_ACTIVATED", "WatchConnectivity session is still activating.")
    }
    session.transferUserInfo(payload)
    cache.storeUserInfo(payload)
  }

  public func clearLatestUserInfo() {
    cache.clearUserInfo()
  }

  public func sendMessage(_ payload: [String: Any], result: @escaping FlutterResult) {
    guard let session else {
      result(flutterError("UNSUPPORTED", "WatchConnectivity unavailable."))
      return
    }
    guard session.activationState == .activated else {
      result(flutterError("NOT_ACTIVATED", "WatchConnectivity session is still activating."))
      return
    }
    guard session.isReachable else {
      result(flutterError("UNREACHABLE", "Apple Watch app is not reachable."))
      return
    }
    session.sendMessage(
      payload,
      replyHandler: { reply in result(reply) },
      errorHandler: { error in result(self.flutterError("SEND_FAILED", error.localizedDescription)) }
    )
  }

  public func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}

  public func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String: Any]
  ) {
    cache.storeContext(applicationContext)
  }

  public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    cache.storeMessage(message)
    dispatcher.emitMessage(message)
  }

  public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
    cache.storeUserInfo(userInfo)
    dispatcher.emitUserInfo(userInfo)
  }

  public func sessionDidBecomeInactive(_ session: WCSession) {}

  public func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  private func unsupportedSnapshot() -> [String: Any] {
    return [
      "supported": false,
      "paired": false,
      "watchAppInstalled": false,
      "reachable": false,
      "activationState": "notSupported",
      "latestContext": cache.latestContext,
      "latestMessage": cache.latestMessage,
      "latestUserInfo": cache.latestUserInfo,
    ]
  }

  private func activationLabel(for state: WCSessionActivationState) -> String {
    switch state {
    case .notActivated:
      return "notActivated"
    case .inactive:
      return "inactive"
    case .activated:
      return "activated"
    @unknown default:
      return "unknown"
    }
  }

  private func watchError(_ code: String, _ message: String) -> NSError {
    NSError(domain: "WatchConnectivity", code: 0, userInfo: [
      NSLocalizedDescriptionKey: message,
      "code": code,
    ])
  }

  private func flutterError(_ code: String, _ message: String) -> FlutterError {
    FlutterError(code: code, message: message, details: nil)
  }
}
