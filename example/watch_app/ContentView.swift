import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var sessionStore: WatchSessionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(statusLine).font(.headline)
            contextList
            Button("Send Ping") { sessionStore.sendPing() }
        }
        .padding()
    }

    private var statusLine: String {
        if !sessionStore.activated { return "Activating session..." }
        return sessionStore.reachable ? "Phone reachable" : "Phone not reachable"
    }

    @ViewBuilder
    private var contextList: some View {
        if contextEntries.isEmpty {
            Text("No context yet").font(.caption2).foregroundStyle(.secondary)
        } else {
            ForEach(contextEntries, id: \.0) { key, value in
                Text("\(key): \(value)").font(.caption2)
            }
        }
    }

    private var contextEntries: [(String, String)] {
        sessionStore.latestContext
            .map { ($0.key, String(describing: $0.value)) }
            .sorted { $0.0 < $1.0 }
    }
}
