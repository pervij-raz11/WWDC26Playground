// WHAT TO LOOK FOR:
// Tap "Run". The log should show:
//   1. "▶︎ start"
//   2. "⚙️  doing work…"
//   3. "✅ work done"
//   4. "🧹 defer cleanup" ← LAST
// defer { await ... } directly — new Swift 6.4 syntax.

import SwiftUI

// RESULT: defer { await ... } — REAL API, Swift 6.4.

@Observable @MainActor
final class AsyncDeferStore {
    var log: [LogEntry] = []
    var running = false

    func asyncCleanup() async {
        try? await Task.sleep(for: .milliseconds(300))
        append("🧹 defer cleanup (fired last — async await in defer)", isDefer: true)
    }

    func run() async {
        running = true
        log.removeAll()
        await runWithAsyncDefer()
        running = false
    }

    // ── Swift 6.4: direct await inside defer ─────────────────────────────────
    private func runWithAsyncDefer() async {
        append("▶︎ start")
        defer { await asyncCleanup() }   // Swift 6.4 — works directly
        append("⚙️  doing work…")
        try? await Task.sleep(for: .seconds(1))
        append("✅ work done")
        // defer executes here, after the function body completes
    }

    private func append(_ msg: String, isDefer: Bool = false) {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm:ss.SSS"
        log.append(LogEntry(timestamp: fmt.string(from: .now), message: msg, isDefer: isDefer))
    }
}

struct AsyncDeferView: View {
    @State private var store = AsyncDeferStore()

    var body: some View {
        VStack(spacing: 0) {
            RealAPIBanner(text: "✅ Real API — defer { await ... } Swift 6.4.\nCleanup is guaranteed to run last.")

            VStack(alignment: .leading, spacing: 16) {
                Text("'defer cleanup' must appear LAST in the log.")
                    .font(.caption).foregroundStyle(.secondary)
                    .padding(.horizontal).padding(.top, 12)

                Button(store.running ? "Running…" : "Run operation") {
                    Task { await store.run() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.running)
                .padding(.horizontal)

                Divider()

                if store.log.isEmpty {
                    Text("Log is empty — tap the button.")
                        .foregroundStyle(.secondary).padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(store.log) { entry in
                                HStack(alignment: .top, spacing: 8) {
                                    Text(entry.timestamp)
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(.secondary)
                                        .frame(width: 80, alignment: .leading)
                                    Text(entry.message)
                                        .font(.caption.monospaced())
                                        .foregroundStyle(entry.isDefer ? .orange : .primary)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("I · async in defer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: String
    let message: String
    var isDefer: Bool = false
}
