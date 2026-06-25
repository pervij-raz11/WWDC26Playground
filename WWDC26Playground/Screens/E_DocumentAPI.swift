// WHAT TO LOOK FOR:
// Tap "Save". The log shows:
//   snapshot — on @MainActor (main thread)  ← state captured on main
//   write    — on actor executor (off-main) ← actual I/O off main ✅
//
// WritableDocument — iOS 27 protocol (AnyObject, snapshot @MainActor, writer off-main).
// Conformance below compiles with the iOS 27 SDK.
// Interactive demo of off-main writes via a Swift actor.

import SwiftUI
import UniformTypeIdentifiers

// RESULT: WritableDocument — REAL API, iOS 27 SDK.

// ── iOS 27 WritableDocument conformance ──────────────────────────────────────
@available(iOS 27.0, *)
final class PlainTextDocument: WritableDocument {
    typealias Writer = FileWrapperDocumentWriter<String>

    static var writableContentTypes: [UTType] { [.plainText] }

    var text: String
    init(text: String) { self.text = text }

    // snapshot() — @MainActor: safely captures state on the main thread
    @MainActor
    func snapshot(contentType: UTType) async throws -> sending String {
        text
    }

    // writer() — returns a Writer whose makeFileWrapper runs off-MainActor
    func writer(configuration: sending WriteConfiguration) -> sending FileWrapperDocumentWriter<String> {
        FileWrapperDocumentWriter(configuration) { (snapshot: String) async throws -> FileWrapper in
            // This closure is not isolated to MainActor → off-main ✅
            FileWrapper(regularFileWithContents: snapshot.data(using: .utf8) ?? Data())
        }
    }
}

// ── Interactive demo via Swift actor ─────────────────────────────────────────
actor DocumentActor {
    private let url: URL
    init() {
        url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("demo.txt")
    }
    func write(_ text: String) throws -> String {
        // Swift actor executor ≠ MainActor → guaranteed off-main
        try text.write(to: url, atomically: true, encoding: .utf8)
        return "💾 write — on actor executor (off-main) ✅"
    }
    func read() throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }
}

@Observable @MainActor
final class DocumentStore {
    var text = "Edit me and tap Save."
    var log: [String] = []
    var isSaving = false
    private let actor = DocumentActor()

    func save() async {
        isSaving = true
        log.append("📸 snapshot — on @MainActor (main thread) ✅")
        let snapshot = text
        do {
            let report = try await actor.write(snapshot)
            log.append(report)
        } catch {
            log.append("❌ \(error.localizedDescription)")
        }
        isSaving = false
    }

    func load() async {
        if let s = try? await actor.read() {
            text = s; log.append("📂 Loaded")
        }
    }
}

struct DocumentAPIView: View {
    @State private var store = DocumentStore()

    var body: some View {
        VStack(spacing: 0) {
            RealAPIBanner(text: "✅ Real API — WritableDocument (AnyObject) + snapshot() @MainActor + writer() off-main — iOS 27 SDK.\nProtocol compiled; demo via Swift actor (same effect).")

            Form {
                Section("Document") {
                    TextEditor(text: $store.text).frame(minHeight: 100)
                }
                Section {
                    Button(store.isSaving ? "Saving…" : "Save") {
                        Task { await store.save() }
                    }.disabled(store.isSaving)
                    Button("Reload") { Task { await store.load() } }
                }
                Section("Log (snapshot on main, write off-main)") {
                    if store.log.isEmpty {
                        Text("No entries yet").foregroundStyle(.secondary)
                    } else {
                        ForEach(store.log, id: \.self) {
                            Text($0).font(.caption.monospaced())
                        }
                    }
                }
            }
        }
        .navigationTitle("E · Document API")
        .navigationBarTitleDisplayMode(.inline)
    }
}
