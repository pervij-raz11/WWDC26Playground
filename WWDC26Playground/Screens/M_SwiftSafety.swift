// WHAT TO LOOK FOR:
// Tap "Compute" — live moving average via InlineArray<256, Float> (stack-allocated).
// Span<Float> obtained from Array.span — safe, non-owning, ~Escapable view into a buffer.
// @diagnose(DeprecatedDeclaration, as: ignored) — suppresses deprecated warning at declaration site.
// FallbackBanner for @C and :: — those are not public Swift APIs.

import SwiftUI

// RESULT: InlineArray<256, Float> + Array.span + @diagnose(as: ignored) — REAL, Swift 6.4 SDK.

// ── @diagnose(as: ignored) — suppress deprecated at declaration site ──────────
@available(*, deprecated, renamed: "modernGreet()")
@diagnose(DeprecatedDeclaration, as: ignored)   // caller sees NO warning
func legacyGreetSuppressed() -> String { modernGreet() }

func modernGreet() -> String { "Hello from modern API" }

// ── Span<Float> consumer — safe, non-owning, non-escaping buffer view ─────────
func movingAverage(_ span: Span<Float>, windowSize: Int) -> Float {
    guard windowSize > 0, span.count >= windowSize else { return 0 }
    var sum: Float = 0
    for i in (span.count - windowSize)..<span.count {
        sum += span[i]
    }
    return sum / Float(windowSize)
}

// ── InlineArray<256, Float> — stack-allocated, fixed-size, zero heap alloc ───
func computeWithInlineArray(windowSize: Int) -> (inlineResult: Float, spanResult: Float) {
    // Stack-allocated 256-element Float buffer
    var buffer = InlineArray<256, Float>(repeating: 0.0)
    for i in 0..<256 {
        buffer[i] = Float(i % 32) * 0.25 + 1.0
    }

    // InlineArray moving average (index-based)
    var inlineSum: Float = 0
    let start = max(0, 256 - windowSize)
    for i in start..<256 { inlineSum += buffer[i] }
    let inlineResult = inlineSum / Float(256 - start)

    // Span<Float> from Array — Array.span is new in Swift 6
    let heapArray: [Float] = (0..<256).map { Float($0 % 32) * 0.25 + 1.0 }
    let spanResult = movingAverage(heapArray.span, windowSize: windowSize)

    return (inlineResult, spanResult)
}

@Observable @MainActor
final class SwiftSafetyStore {
    var windowSize = 16
    var inlineResult: Float = 0
    var spanResult: Float = 0
    var computed = false

    func compute() {
        let r = computeWithInlineArray(windowSize: windowSize)
        inlineResult = r.inlineResult
        spanResult   = r.spanResult
        computed = true
    }
}

struct SwiftSafetyView: View {
    @State private var store = SwiftSafetyStore()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RealAPIBanner(text: "✅ Real APIs — InlineArray<256, Float> (stack-allocated) + Array.span: Span<Float> (~Escapable) + @diagnose(as: ignored) — Swift 6.4.")

                // InlineArray
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("InlineArray<256, Float>").font(.headline)
                        codeBlock("var buffer = InlineArray<256, Float>(repeating: 0.0)\nbuffer[i] = Float(i % 32) * 0.25 + 1.0\n// Zero heap allocation — lives on the stack")
                        Text("Stack-allocated, fixed-size. Type parameter order: <count, Element>.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }

                // Span
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Span<Float>  (~Escapable)").font(.headline)
                        codeBlock("let arr: [Float] = [...]\nlet s = arr.span          // Span<Float>, borrows arr\nlet avg = movingAverage(s, windowSize: 8)\n// s cannot escape — lifetime tied to arr")
                        Text("Array.span is a non-owning, non-escaping view. ~Escapable means the Span cannot outlive its source buffer — zero-copy, zero-allocation buffer access.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }

                // @diagnose(as: ignored)
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("@diagnose(as: ignored)").font(.headline)
                        codeBlock("@available(*, deprecated, renamed: \"modernGreet()\")\n@diagnose(DeprecatedDeclaration, as: ignored)\nfunc legacyGreetSuppressed() -> String { ... }\n// Callers see NO deprecation warning")
                        Text("as: error escalates, as: warning downgrades, as: ignored suppresses. Applied at the declaration site.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }

                // FallbackBanner for @C
                FallbackBanner(text: "⚠️ @C attribute — NOT a public Swift attribute. @_cdecl is SPI-only (unavailable in user code). For C-callable function pointers use @convention(c). No public @C attribute exists in Swift 6.4.")

                // FallbackBanner for module selectors
                FallbackBanner(text: "⚠️ Module selectors (Engine::Core, UI::Core) — C++ interop syntax, not Swift user-space. In pure Swift, module disambiguation is not done with ::. This notation only applies when using Swift/C++ interop with actual C++ namespaces.")

                // Live demo
                GroupBox("Live demo") {
                    Stepper("Window size: \(store.windowSize)", value: $store.windowSize, in: 1...128)
                    Button("Compute") { store.compute() }
                        .buttonStyle(.borderedProminent)

                    if store.computed {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("InlineArray result: \(String(format: "%.4f", store.inlineResult))")
                                .font(.system(.body, design: .monospaced))
                            Text("Span result:        \(String(format: "%.4f", store.spanResult))")
                                .font(.system(.body, design: .monospaced))
                            Text("Results match: \(abs(store.inlineResult - store.spanResult) < 1e-4 ? "✅" : "❌")")
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("M · Swift 6.4 Safety")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func codeBlock(_ code: String) -> some View {
        Text(code)
            .font(.system(.caption, design: .monospaced))
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
