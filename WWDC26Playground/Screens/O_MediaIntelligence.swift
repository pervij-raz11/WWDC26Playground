// WHAT TO LOOK FOR:
// FaceGroupAnalyzer — real MediaIntelligence API (iOS 27).
// init(workingDirectory:) throws — stores face group data in a CoreData-backed directory.
// allFaces / allEntities / state — real async-sequence properties.
// Video highlight generation — MediaIntelligenceVideoAsset type exists, but highlight
//   generation API was not found in the iOS 27 SDK → FallbackBanner.

import SwiftUI
import MediaIntelligence

// RESULT: FaceGroupAnalyzer + MediaIntelligenceImageAsset — REAL, MediaIntelligence iOS 27 SDK.

@available(iOS 27.0, *)
@Observable @MainActor
final class MediaIntelligenceStore {
    var analyzerState: String = "Not initialized"
    var faceCount = 0
    var entityCount = 0
    var log: [String] = []
    var isRunning = false

    func initializeAnalyzer() async {
        isRunning = true
        log.removeAll()
        do {
            let workDir = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("MediaIntelligence/FaceGroups", isDirectory: true)
            try FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)

            let analyzer = try FaceGroupAnalyzer(workingDirectory: workDir)
            log.append("✅ FaceGroupAnalyzer initialized")
            log.append("   workingDirectory: \(workDir.lastPathComponent)")

            // state is get async — must await
            switch await analyzer.state {
            case .ready:
                analyzerState = "Ready"
            case .stale:
                analyzerState = "Stale (call update() to re-process)"
            case .updating:
                analyzerState = "Updating…"
            @unknown default:
                analyzerState = "Unknown state"
            }
            log.append("   state: \(analyzerState)")

            // Count existing faces and entities (will be 0 on fresh install)
            var faces = 0
            for try await _ in analyzer.allFaces { faces += 1 }
            faceCount = faces

            var entities = 0
            for try await _ in analyzer.allEntities { entities += 1 }
            entityCount = entities

            log.append("   faces in store: \(faceCount)")
            log.append("   entities (groups) in store: \(entityCount)")
            log.append("ℹ️ Feed real photos via insertOrUpdateAssets(_:) then call update() to analyze.")

        } catch {
            log.append("❌ \(error.localizedDescription)")
        }
        isRunning = false
    }
}

struct MediaIntelligenceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if #available(iOS 27.0, *) {
                    MediaIntelligenceContent()
                } else {
                    FallbackBanner(text: "⚠️ MediaIntelligence requires iOS 27.0+.")
                }
            }
            .padding()
        }
        .navigationTitle("O · Media Intelligence")
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 27.0, *)
private struct MediaIntelligenceContent: View {
    @State private var store = MediaIntelligenceStore()

    var body: some View {
        RealAPIBanner(text: "✅ Real API — MediaIntelligence framework: FaceGroupAnalyzer(workingDirectory:) + allFaces + allEntities + state — iOS 27 SDK.")

        GroupBox("FaceGroupAnalyzer") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Analyzes photo libraries to group faces into people-entities using CoreData-backed storage. Requires photo assets via insertOrUpdateAssets(_:) — demo initializes with an empty store.")
                    .font(.caption).foregroundStyle(.secondary)

                codeBlock("""
let analyzer = try FaceGroupAnalyzer(workingDirectory: url)
// Feed assets:
for try await (assetID, faces) in analyzer.insertOrUpdateAssets(assets) { }
// Process:
try await analyzer.update()
// Query:
for try await face in analyzer.allFaces { ... }
for try await entity in analyzer.allEntities { ... }
""")

                Button(store.isRunning ? "Initializing…" : "Initialize Analyzer") {
                    Task { await store.initializeAnalyzer() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.isRunning)

                if !store.log.isEmpty {
                    ForEach(store.log.indices, id: \.self) { i in
                        Text(store.log[i]).font(.caption.monospaced())
                    }
                }
            }
        }

        GroupBox("MediaIntelligenceImageAsset") {
            codeBlock("""
// Wrap a photo for analysis:
let asset = MediaIntelligenceImageAsset(
    id: .init("photo-uuid"),
    kind: .photo           // or .video
)
// Asset.ID is a typed RawRepresentable<String>
""")
        }

        // Video highlights — not found in SDK
        FallbackBanner(text: "⚠️ Video highlight generation — MediaIntelligenceVideoAsset type exists in SDK, but a public highlight-generation API (e.g., 'generateHighlights()') was not found in the iOS 27 SDK swiftinterface. Possibly private/SPI or not yet shipped.")
    }

    private func codeBlock(_ code: String) -> some View {
        Text(code)
            .font(.system(.caption2, design: .monospaced))
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
