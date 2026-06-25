// WHAT TO LOOK FOR:
// Scroll down — the "bell" button stays pinned (.topBarPinnedTrailing) while the bar minimizes.
// Tap the bell or "Show Alert" — the system alert renders with Liquid Glass material (iOS 26+ automatic).
// Both .topBarPinnedTrailing and .toolbarMinimizeBehavior are new iOS 27 APIs.

import SwiftUI

// RESULT: .topBarPinnedTrailing + .toolbarMinimizeBehavior + .alert(isPresented:) — REAL iOS 27 SDK.

struct ModernToolbarView: View {
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var log: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RealAPIBanner(text: "✅ Real APIs — .topBarPinnedTrailing (iOS 27, stays visible on scroll) + .toolbarMinimizeBehavior(.onScrollDown) + .alert(isPresented:).\n\"Liquid Glass\" = automatic system material on iOS 26+, no opt-in API.")

                Text("⬇︎ Scroll down — bar minimizes, but the 🔔 button stays pinned.")
                    .font(.caption).padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.08))
                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Liquid Glass Alerts").font(.headline)
                    Text("In iOS 26+, system alerts automatically use Liquid Glass material — translucent blur, specular highlights, adaptive color. No API change needed from .alert(isPresented:); the visual update is applied by the system.")
                        .font(.caption).foregroundStyle(.secondary)

                    Button("Show Liquid Glass Alert") {
                        alertTitle = "Liquid Glass"
                        alertMessage = "This alert is rendered with Liquid Glass material automatically on iOS 26+. No new API needed — it's a system-level visual update."
                        showAlert = true
                    }
                    .buttonStyle(.borderedProminent)

                    GroupBox("topBarPinnedTrailing") {
                        Text("The 🔔 toolbar button uses `.topBarPinnedTrailing` — new in iOS 27. Unlike `.topBarTrailing`, this item remains anchored when `.toolbarMinimizeBehavior` collapses the navigation bar. Useful for critical actions that must always be reachable.")
                            .font(.caption).foregroundStyle(.secondary)
                    }

                    if !log.isEmpty {
                        GroupBox("Tap log") {
                            ForEach(log.indices, id: \.self) { i in
                                Text(log[i]).font(.caption.monospaced())
                            }
                        }
                    }
                }
                .padding()

                ForEach(0..<40, id: \.self) { i in
                    HStack {
                        Text("Row \(i + 1)")
                        Spacer()
                    }
                    .padding(.horizontal).padding(.vertical, 9)
                    Divider().padding(.leading)
                }
            }
        }
        .navigationTitle("L · Modern Toolbar")
        .navigationBarTitleDisplayMode(.large)
        .toolbarMinimizeBehavior(.onScrollDown, for: .navigationBar)
        .toolbar {
            // .topBarPinnedTrailing — new iOS 27 placement, stays visible during minimize
            ToolbarItem(placement: .topBarPinnedTrailing) {
                Button {
                    alertTitle = "Pinned Trailing"
                    alertMessage = "This button uses .topBarPinnedTrailing — it stays anchored even when the nav bar minimizes on scroll."
                    showAlert = true
                    log.append("🔔 Pinned button tapped")
                } label: {
                    Image(systemName: "bell.fill")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { log.append("✏️ Edit tapped") } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
}
