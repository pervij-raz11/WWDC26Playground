// WHAT TO LOOK FOR:
// Type some text and tap "Summarize". The on-device model responds without
// any network call. If the model or framework is unavailable, a clear message
// explains why — no fake response is shown.
//
// FoundationModels / LanguageModelSession — introduced iOS 18.1 (Apple Intelligence).
// Guarded with #if canImport(FoundationModels) and @available checks.
// SystemLanguageModel.default.isAvailable is checked at runtime before calling the model.

import SwiftUI

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 18.1, macOS 15.1, *)
@Observable @MainActor
final class TextSummarizeStore {
    var inputText = "Swift concurrency uses structured tasks and actors to make async code safe. Sendable types cross actor boundaries without data races. The Task tree propagates cancellation automatically."
    var result = ""
    var isRunning = false
    var errorMessage: String?

    func summarize() async {
        guard SystemLanguageModel.default.isAvailable else {
            errorMessage = "Apple Intelligence model is not available on this device or simulator.\nOn a real device: Settings → Apple Intelligence & Siri → enable and download the model."
            return
        }
        isRunning = true
        result = ""
        errorMessage = nil
        do {
            let session = LanguageModelSession()
            let prompt = "Summarize the following in one sentence:\n\n\(inputText)"
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
#endif

struct FoundationModelsTextView: View {
    var body: some View {
        Group {
#if canImport(FoundationModels)
            if #available(iOS 18.1, macOS 15.1, *) {
                FoundationModelsTextInner()
            } else {
                unavailableView(reason: "Requires iOS 18.1+ or macOS 15.1+ (Apple Intelligence).")
            }
#else
            unavailableView(reason: "FoundationModels framework not importable on this SDK/toolchain.\nExpected on simulators or non-Apple-Intelligence devices.")
#endif
        }
        .navigationTitle("J · Foundation Models Text")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func unavailableView(reason: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Foundation Models unavailable")
                .font(.title3.bold())
            Text(reason)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Text("No fake response is shown.\nRun on a real Apple Intelligence device to test.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.tertiary)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if canImport(FoundationModels)
@available(iOS 18.1, macOS 15.1, *)
private struct FoundationModelsTextInner: View {
    @State private var store = TextSummarizeStore()

    var body: some View {
        Form {
            Section("Input") {
                TextEditor(text: $store.inputText)
                    .frame(minHeight: 100)
            }

            if !SystemLanguageModel.default.isAvailable {
                Section {
                    Label("Apple Intelligence not available on this device or simulator.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }

            Section {
                Button(store.isRunning ? "Summarizing…" : "Summarize (on-device)") {
                    Task { await store.summarize() }
                }
                .disabled(store.isRunning || !SystemLanguageModel.default.isAvailable)
            }
            if !store.result.isEmpty {
                Section("On-device summary") {
                    Text(store.result)
                }
            }
            if let err = store.errorMessage {
                Section("Error") {
                    Text(err).foregroundStyle(.red)
                }
            }
        }
    }
}
#endif
