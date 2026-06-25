// WHAT TO LOOK FOR:
// @available(anyAppleOS 27, *) — new Swift 6.4 condition covering all Apple platforms.
// @diagnose(DeprecatedDeclaration, as: error) — escalates a deprecated warning to ERROR.
// Both APIs compile. Tap the button for a live demo.

import SwiftUI

// ── Swift 6.4: anyAppleOS platform condition ─────────────────────────────────
@available(anyAppleOS 27, *)
func greetOnAnyApple() -> String {
    "Hello from Apple platform ≥ 27!"
}

// ── Swift 6.4: @diagnose — severity escalation to .error ─────────────────────
// Calling legacyGreet() is now a COMPILE ERROR, not just a warning.
@available(anyAppleOS 27, *)
@available(*, deprecated, renamed: "greetOnAnyApple()")
@diagnose(DeprecatedDeclaration, as: error)
func legacyGreet() -> String {
    greetOnAnyApple()
}

// RESULT: @available(anyAppleOS 27, *) + @diagnose — REAL API, Swift 6.4.

struct AnyAppleOSView: View {
    @State private var result = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RealAPIBanner(text: "✅ Real API — @available(anyAppleOS 27, *) + @diagnose(DeprecatedDeclaration, as: error)\nCompiles on Swift 6.4 + iOS 27 SDK.")

                Group {
                    sectionHeader("anyAppleOS condition")
                    codeBlock("""
@available(anyAppleOS 27, *)
func greetOnAnyApple() -> String { … }

// = @available(iOS 27, macOS 26, tvOS 26,
//              watchOS 26, visionOS 26, *)
// One version number covers all Apple platforms.
""")
                }

                Group {
                    sectionHeader("@diagnose — severity override")
                    codeBlock("""
@available(*, deprecated, renamed: "greetOnAnyApple()")
@diagnose(DeprecatedDeclaration, as: error)
func legacyGreet() -> String { … }

// Calling legacyGreet() → COMPILE ERROR (not just a warning).
// as: warning  — downgrade to warning
// as: error    — escalate to error
// as: ignored  — suppress the diagnostic
""")
                    Text("This lets you control the severity of an existing diagnostic group for a specific symbol.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Group {
                    sectionHeader("Live test")
                    if #available(anyAppleOS 27, *) {
                        Button("Call greetOnAnyApple()") {
                            result = greetOnAnyApple()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    if !result.isEmpty {
                        Text(result)
                            .font(.headline).padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("H · anyAppleOS + @diagnose")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(.headline).padding(.top, 4)
    }

    private func codeBlock(_ code: String) -> some View {
        Text(code)
            .font(.system(.caption, design: .monospaced))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
