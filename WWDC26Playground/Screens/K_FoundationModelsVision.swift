// WHAT TO LOOK FOR:
// An SF Symbol image is sent to the on-device model with the question "What is this?".
// If FoundationModels is available, the model's text answer appears.
// If not, a clear unavailability message is shown — no fake response.
//
// NOTE: Direct image-attachment API (passing UIImage into the prompt) is not confirmed
// in the iOS 26.2 SDK headers. This screen uses a text prompt describing the image
// by name as a stand-in for the vision attachment.
// TODO: Replace with Attachment.image(uiImage) once iOS 27 SDK confirms the API.

import SwiftUI
import UIKit

struct FoundationModelsVisionView: View {
    var body: some View {
        innerBody
            .navigationTitle("K · Foundation Models Vision")
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var innerBody: some View {
#if canImport(FoundationModels)
        if #available(iOS 18.1, *) {
            VisionAvailableView()
        } else {
            modelUnavailableView(reason: "Requires iOS 18.1+ with Apple Intelligence.")
        }
#else
        modelUnavailableView(reason: "FoundationModels framework is not importable on this SDK.\nExpected on simulators and non-Apple-Intelligence devices.")
#endif
    }

    private func modelUnavailableView(reason: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "eye.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Multimodal model unavailable")
                .font(.title3.bold())
            Text(reason)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            FallbackBanner(text: "⚠️ No fake response shown. Run on an Apple Intelligence device to test.")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 18.1, *)
@Observable @MainActor
final class VisionStore {
    var result = ""
    var isRunning = false
    var errorMessage: String?

    func describe() async {
        guard SystemLanguageModel.default.isAvailable else {
            errorMessage = "Apple Intelligence model is not available on this device or simulator.\nOn a real device: Settings → Apple Intelligence & Siri → enable and download the model."
            return
        }
        isRunning = true
        result = ""
        errorMessage = nil
        do {
            let session = LanguageModelSession()
            // TODO: Replace with vision attachment once iOS 27 SDK confirms Attachment.image API:
            //   let attachment = Attachment.image(uiImage)
            //   let response = try await session.respond(to: Prompt { "What is this?"; attachment })
            let prompt = "I am looking at an image of the Swift programming language logo (an orange/red stylized bird). Describe what you see in one sentence."
            let response = try await session.respond(to: prompt)
            result = response.content
        } catch let error as NSError where error.domain.contains("SensitiveContentAnalysisML") {
            errorMessage = "Model unavailable on simulator (code \(error.code)). Run on a physical Apple Intelligence device."
        } catch {
            errorMessage = error.localizedDescription
        }
        isRunning = false
    }
}

@available(iOS 18.1, *)
private struct VisionAvailableView: View {
    @State private var store = VisionStore()

    private let demoImage: UIImage = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 120, weight: .regular)
        return UIImage(systemName: "swift", withConfiguration: cfg)
            ?? UIImage(systemName: "photo")!
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(uiImage: demoImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text("Image: SF Symbol 'swift' (stand-in for vision demo)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                FallbackBanner(text: "⚠️ Vision attachment API (Attachment.image) not confirmed in iOS 26.2 SDK.\nShown: text prompt describing image — model response is real, image pass-through is TODO.")

                if !SystemLanguageModel.default.isAvailable {
                    Label("Apple Intelligence not available on this device or simulator.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                        .font(.caption)
                        .padding(.horizontal)
                }

                Button(store.isRunning ? "Asking model…" : "Ask: what is this?") {
                    Task { await store.describe() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.isRunning || !SystemLanguageModel.default.isAvailable)

                if !store.result.isEmpty {
                    GroupBox("Model answer") {
                        Text(store.result).padding()
                    }
                }
                if let err = store.errorMessage {
                    Text("Error: \(err)").foregroundStyle(.red).padding()
                }
            }
            .padding()
        }
    }
}
#endif
