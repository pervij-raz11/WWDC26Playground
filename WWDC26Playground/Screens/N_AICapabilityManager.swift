// WHAT TO LOOK FOR:
// SystemLanguageModel.default — on-device model, shows live availability + availability enum.
// PrivateCloudComputeLanguageModel — PCC model type exists; session creation requires
//   special entitlements, so shown as code-only with FallbackBanner.
// ThirdParty unified API — does not exist in FoundationModels 1.x SDK → FallbackBanner.

import SwiftUI

#if canImport(FoundationModels)
import FoundationModels

// RESULT: SystemLanguageModel + PrivateCloudComputeLanguageModel — REAL, FoundationModels SDK.

@available(iOS 18.1, macOS 15.1, *)
@Observable @MainActor
final class AICapabilityStore {
    // On-device model — always inspectable
    var onDeviceAvailable: Bool { SystemLanguageModel.default.isAvailable }
    var onDeviceAvailabilityDescription: String {
        switch SystemLanguageModel.default.availability {
        case .available:
            return "✅ Available — model downloaded and ready"
        case .unavailable(let reason):
            return "⚠️ Unavailable — \(reason)"
        }
    }

    // PCC — type exists but @_hasMissingDesignatedInitializers: no public init
    var pccDescription: String {
        "PrivateCloudComputeLanguageModel exists in SDK (@available iOS 27+). " +
        "No public initializer — creation requires Apple entitlements. " +
        "Session: LanguageModelSession(model: pccInstance) would work if instantiable."
    }

    var onDeviceResult = ""
    var isRunning = false
    var errorMessage: String?

    func runOnDevice(prompt: String) async {
        guard onDeviceAvailable else {
            errorMessage = "On-device model not available."
            return
        }
        isRunning = true
        onDeviceResult = ""
        errorMessage = nil
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            onDeviceResult = response.content
        } catch let error as NSError where error.domain.contains("SensitiveContentAnalysisML") {
            errorMessage = "Model unavailable on simulator (code \(error.code)). Needs real Apple Intelligence device."
        } catch {
            errorMessage = error.localizedDescription
        }
        isRunning = false
    }
}
#endif

struct AICapabilityManagerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
#if canImport(FoundationModels)
                if #available(iOS 18.1, macOS 15.1, *) {
                    AICapabilityContent()
                } else {
                    FallbackBanner(text: "⚠️ FoundationModels requires iOS 18.1+.")
                }
#else
                FallbackBanner(text: "⚠️ FoundationModels not importable on this SDK.")
#endif
            }
            .padding()
        }
        .navigationTitle("N · AI Capability Manager")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if canImport(FoundationModels)
@available(iOS 18.1, macOS 15.1, *)
private struct AICapabilityContent: View {
    @State private var store = AICapabilityStore()
    @State private var prompt = "Name three benefits of Swift concurrency in one sentence each."

    var body: some View {
        RealAPIBanner(text: "✅ Real APIs — SystemLanguageModel.default.isAvailable + .availability + PrivateCloudComputeLanguageModel (type) — FoundationModels SDK.")

        // On-device model
        GroupBox("On-Device Model (SystemLanguageModel)") {
            VStack(alignment: .leading, spacing: 8) {
                Label(store.onDeviceAvailabilityDescription, systemImage: store.onDeviceAvailable ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(store.onDeviceAvailable ? .green : .orange)
                    .font(.caption)

                TextEditor(text: $prompt)
                    .frame(minHeight: 60)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                    .font(.caption)

                Button(store.isRunning ? "Running…" : "Run on-device") {
                    Task { await store.runOnDevice(prompt: prompt) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.isRunning || !store.onDeviceAvailable)

                if !store.onDeviceResult.isEmpty {
                    Text(store.onDeviceResult).font(.caption)
                        .padding(6).background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                if let err = store.errorMessage {
                    Text(err).foregroundStyle(.red).font(.caption)
                }
            }
        }

        // PCC model
        GroupBox("Private Cloud Compute (PrivateCloudComputeLanguageModel)") {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.pccDescription).font(.caption).foregroundStyle(.secondary)
                codeBlock("""
// PrivateCloudComputeLanguageModel conforms to LanguageModel:
// let session = LanguageModelSession(model: pccModel)
// PCC routes to Apple's servers with on-device cryptographic attestation.
// quotaUsage: tracks compute budget consumption.
// availability: .available | .unavailable(reason)
""")
                FallbackBanner(text: "⚠️ PrivateCloudComputeLanguageModel has no public initializer (@_hasMissingDesignatedInitializers). Session creation requires Apple entitlements. Shown as code-only.")
            }
        }

        // Third-party — FallbackBanner
        FallbackBanner(text: "⚠️ 'ThirdParty AI provider unified API' (Claude/Gemini switching) does not exist in FoundationModels SDK. FoundationModels only covers on-device (SystemLanguageModel) and Apple PCC (PrivateCloudComputeLanguageModel). Third-party models require each vendor's own SDK.")
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
#endif
