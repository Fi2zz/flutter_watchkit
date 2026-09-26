import Foundation
import WatchConnectivity

@MainActor
final class WatchSessionStore: NSObject, ObservableObject {
    @Published private(set) var activated = false
    @Published private(set) var reachable = false
    @Published private(set) var latestContext = [String: Any]()

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        latestContext = session.receivedApplicationContext
    }

    func sendPing() {
        sendAction(["action": "ping"])
    }

    /// Instant path while the phone is reachable (sendMessage); otherwise
    /// queued reliably via transferUserInfo. sendMessage failures caused by
    /// the peer turning unreachable fall back to transferUserInfo so the
    /// command is never silently lost.
    func sendAction(_ command: [String: Any]) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        if session.isReachable {
            session.sendMessage(command, replyHandler: nil) { error in
                guard (error as? WCError)?.code == .notReachable else { return }
                session.transferUserInfo(command)
            }
        } else {
            session.transferUserInfo(command)
        }
    }

    private func applyState(reachable: Bool, context: [String: Any]) {
        self.reachable = reachable
        latestContext = context
    }
}

extension WatchSessionStore: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        let activated = activationState == .activated
        let reachable = session.isReachable
        let context = session.receivedApplicationContext
        Task { @MainActor in
            self.activated = activated
            applyState(reachable: reachable, context: context)
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        let reachable = session.isReachable
        Task { @MainActor in self.reachable = reachable }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        let reachable = session.isReachable
        Task { @MainActor in
            applyState(reachable: reachable, context: applicationContext)
        }
    }
}
