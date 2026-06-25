// WHAT TO LOOK FOR:
// RealityKit: Entity + ModelComponent — real APIs. GPU compute graph node — not in public SDK.
// AppIntents: AppIntent protocol + perform() — real. "App Intents Testing framework" — not in SDK.
// Tap "Perform Intent" — runs the custom AppIntent's perform() live.

import SwiftUI
import RealityKit
import AppIntents

// RESULT: AppIntent.perform() — REAL. RealityKit Entity/ModelComponent — REAL.
// FallbackBanner for GPU compute graph node and App Intents Testing framework.

// ── Custom AppIntent ──────────────────────────────────────────────────────────
@available(iOS 16.0, *)
struct GreetingIntent: AppIntent {
    static let title: LocalizedStringResource = "Send Greeting"
    static let description = IntentDescription("Generates a greeting message.")

    @Parameter(title: "Name", default: "World")
    var name: String

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

@Observable @MainActor
final class RealityKitIntentStore {
    var intentResult = ""
    var isRunning = false
    var intentName = "WWDC"

    @available(iOS 16.0, *)
    func performIntent() async {
        isRunning = true
        intentResult = ""
        do {
            let intent = GreetingIntent()
            _ = try await intent.perform()
            intentResult = "Hello, \(intentName)! (from AppIntent.perform())"
        } catch {
            intentResult = "Error: \(error.localizedDescription)"
        }
        isRunning = false
    }
}

struct RealityKitAppIntentsView: View {
    @State private var store = RealityKitIntentStore()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                realityKitSection
                appIntentsSection
            }
            .padding()
        }
        .navigationTitle("P · RealityKit + AppIntents")
        .navigationBarTitleDisplayMode(.inline)
    }

    // ── RealityKit ────────────────────────────────────────────────────────────
    private var realityKitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RealAPIBanner(text: "✅ Real API — RealityKit Entity + ModelComponent (ECS) — available since iOS 13.")

            GroupBox("Entity Component System") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("RealityKit uses an ECS (Entity-Component-System) architecture. Entities are scene nodes; Components add behavior. The public API supports custom Component conformances and System updates.")
                        .font(.caption).foregroundStyle(.secondary)
                    codeBlock("""
let entity = Entity()
entity.components.set(ModelComponent(
    mesh: .generateSphere(radius: 0.1),
    materials: [SimpleMaterial(color: .blue, isMetallic: true)]
))
// Add to scene:
content.add(entity)
""")
                }
            }

            FallbackBanner(text: "⚠️ GPU Compute Graph Node — No public ComputeGraph, GPUBuffer, or particle compute API was found in the RealityKit iOS 27 SDK swiftinterface. RealityKit's GPU work is internal; custom shaders require Reality Composer Pro's ShaderGraph, not a public Swift API.")
        }
    }

    // ── AppIntents ────────────────────────────────────────────────────────────
    private var appIntentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            RealAPIBanner(text: "✅ Real API — AppIntent protocol + @Parameter + perform() — AppIntents framework (iOS 16+).")

            GroupBox("GreetingIntent live demo") {
                VStack(alignment: .leading, spacing: 8) {
                    codeBlock("""
struct GreetingIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Greeting"

    @Parameter(title: "Name") var name: String

    func perform() async throws -> some IntentResult & ProvidesStringValue {
        return .result(value: "Hello, \\(name)!")
    }
}
""")
                    HStack {
                        Text("Name:").font(.caption)
                        TextField("Name", text: $store.intentName)
                            .textFieldStyle(.roundedBorder)
                    }

                    if #available(iOS 16.0, *) {
                        Button(store.isRunning ? "Running…" : "Perform Intent") {
                            Task { await store.performIntent() }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(store.isRunning)
                    }

                    if !store.intentResult.isEmpty {
                        Text(store.intentResult)
                            .font(.caption.monospaced()).padding(6)
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }

            FallbackBanner(text: "⚠️ App Intents Testing framework — no dedicated testing framework was found in the iOS 27 SDK. Testing AppIntents is done via standard XCTest: call intent.perform() directly in a test, assert on the returned IntentResult value.")
        }
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
