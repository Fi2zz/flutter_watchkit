import Flutter
import Foundation

final class FlutterWatchKitStreamHandler: NSObject, FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    WatchKitEventDispatcher.shared.updateSink(events)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    WatchKitEventDispatcher.shared.updateSink(nil)
    return nil
  }
}

final class FlutterWatchKitPlugin: NSObject, FlutterPlugin {
  private static let channelName = "flutter_watchkit/methods"
  private static let eventChannelName = "flutter_watchkit/events"

  private let service: WatchKitSessionService

  init(service: WatchKitSessionService = .shared) {
    self.service = service
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let events = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger()
    )
    let plugin = FlutterWatchKitPlugin()
    registrar.addMethodCallDelegate(plugin, channel: channel)
    events.setStreamHandler(FlutterWatchKitStreamHandler())
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "activate":
      service.activateSession()
      result(service.snapshot())
    case "status":
      result(service.snapshot())
    case "updateApplicationContext":
      handleContextUpdate(call.arguments, result: result)
    case "transferUserInfo":
      handleUserInfoTransfer(call.arguments, result: result)
    case "clearLatestUserInfo":
      service.clearLatestUserInfo()
      result(nil)
    case "sendMessage":
      handleMessageSend(call.arguments, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleContextUpdate(_ arguments: Any?, result: FlutterResult) {
    guard let payload = arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "Expected payload map.", details: nil))
      return
    }
    do {
      try service.updateContext(payload)
      result(service.snapshot())
    } catch {
      result(FlutterError(code: "CONTEXT_FAILED", message: error.localizedDescription, details: nil))
    }
  }

  private func handleUserInfoTransfer(_ arguments: Any?, result: FlutterResult) {
    guard let payload = arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "Expected payload map.", details: nil))
      return
    }
    do {
      try service.transferUserInfo(payload)
      result(service.snapshot())
    } catch {
      result(FlutterError(code: "TRANSFER_FAILED", message: error.localizedDescription, details: nil))
    }
  }

  private func handleMessageSend(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let payload = arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "Expected payload map.", details: nil))
      return
    }
    service.sendMessage(payload, result: result)
  }
}
