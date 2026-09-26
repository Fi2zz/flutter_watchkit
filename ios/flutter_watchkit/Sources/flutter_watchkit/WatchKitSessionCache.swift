import Foundation

final class WatchKitSessionCache {
  static let shared = WatchKitSessionCache()

  private init() {}

  private(set) var latestContext = [String: Any]()
  private(set) var latestMessage = [String: Any]()
  private(set) var latestUserInfo = [String: Any]()

  func storeContext(_ payload: [String: Any]) {
    latestContext = payload
  }

  func storeMessage(_ payload: [String: Any]) {
    latestMessage = payload
  }

  func storeUserInfo(_ payload: [String: Any]) {
    latestUserInfo = payload
  }

  func clearUserInfo() {
    latestUserInfo = [:]
  }
}
