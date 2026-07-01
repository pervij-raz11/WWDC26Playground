// WHAT TO LOOK FOR (matches the "Four tools + a standout tab" slide):
//   1. visibility priority  — on a narrow bar, the low-priority "Bookmark" button drops into the
//      overflow first, while the high-priority "Share" button stays visible longer.
//   2. overflow menu        — the "…" menu is a real ToolbarOverflowMenu; its items always live there.
//   3. pinned trailing item — the ⭐︎ button uses .topBarPinnedTrailing and never leaves the bar.
//   4. minimize-on-scroll   — scroll down and the whole navigation bar collapses to free up space.
// The standout tab (Tab(role: .prominent)) lives on screen C · Prominent Tab.
// All four modifiers are real iOS 27 SDK APIs — no fallback.

import SwiftUI

// RESULT: .visibilityPriority + ToolbarOverflowMenu + .topBarPinnedTrailing + .toolbarMinimizeBehavior — REAL iOS 27 SDK.

struct SmartToolbarsView: View {
    @State private var log: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RealAPIBanner(text: "✅ Real APIs — .visibilityPriority(.high/.low) + ToolbarOverflowMenu { } + .topBarPinnedTrailing + .toolbarMinimizeBehavior(.onScrollDown) — iOS 27 SDK.")

                Text("⬇︎ Scroll — the bar minimizes. The bar is intentionally crowded so the overflow \"…\" appears on compact screens.")
                    .font(.caption).padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.08))
                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    toolCard(
                        icon: "slider.horizontal.3",
                        title: "visibility priority",
                        code: ".visibilityPriority(.high)",
                        detail: "You say which buttons matter most; when space is tight, the less important ones hide into the overflow first. The bar is crowded on purpose: \"Bookmark\" is .low so it's demoted into the \"…\" before the default buttons, while \"Share\" is .high and survives the longest."
                    )
                    toolCard(
                        icon: "ellipsis.circle",
                        title: "overflow menu",
                        code: "ToolbarOverflowMenu { }",
                        detail: "Buttons that should always live behind the \"…\" — Duplicate, Archive, Delete here — go in a ToolbarOverflowMenu, never taking bar space."
                    )
                    toolCard(
                        icon: "pin.fill",
                        title: "pinned trailing item",
                        code: ".topBarPinnedTrailing",
                        detail: "The ⭐︎ button is pinned to the right edge and never moves into the overflow menu, no matter how constrained the bar gets."
                    )
                    toolCard(
                        icon: "arrow.up.left.and.arrow.down.right",
                        title: "minimize-on-scroll",
                        code: ".toolbarMinimizeBehavior(.onScrollDown)",
                        detail: "The bar collapses as you scroll down, freeing the screen for content, and expands again when you scroll back up."
                    )

                    GroupBox {
                        Text("⭐︎ The standout tab — Tab(role: .prominent) — is demonstrated on screen **C · Prominent Tab**.")
                            .font(.caption).foregroundStyle(.secondary)
                    }

                    if !log.isEmpty {
                        GroupBox("Tap log") {
                            ForEach(log.indices, id: \.self) { i in
                                Text(log[i]).font(.caption.monospaced())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding()

                ForEach(0..<50, id: \.self) { i in
                    HStack {
                        Text("Row \(i + 1)")
                        Spacer()
                    }
                    .padding(.horizontal).padding(.vertical, 9)
                    Divider().padding(.leading)
                }
            }
        }
        .navigationTitle("D · Smart Toolbars")
        .navigationBarTitleDisplayMode(.large)
        // The bar collapses as you scroll, freeing space for content.
        .toolbarMinimizeBehavior(.onScrollDown, for: .navigationBar)
        .toolbar {
            // 3 · pinned trailing item — never moves to the overflow menu
            ToolbarItem(placement: .topBarPinnedTrailing) {
                Button { log.append("⭐︎ Pinned star tapped") } label: {
                    Label("Favorite", systemImage: "star")
                }
            }
            // 1 · visibility priority — high stays in the bar longer
            ToolbarItem(placement: .topBarTrailing) {
                Button { log.append("Share tapped") } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .visibilityPriority(.high)
            ToolbarItem(placement: .topBarTrailing) {
                Button { log.append("Edit tapped") } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            // Default-priority items — crowd the bar so the .low item is demoted first.
            ToolbarItem(placement: .topBarTrailing) {
                Button { log.append("Comment tapped") } label: {
                    Label("Comment", systemImage: "bubble.left")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { log.append("Flag tapped") } label: {
                    Label("Flag", systemImage: "flag")
                }
            }
            // 1 · visibility priority — low overflows first, before any default item
            ToolbarItem(placement: .topBarTrailing) {
                Button { log.append("Bookmark tapped") } label: {
                    Label("Bookmark", systemImage: "bookmark")
                }
            }
            .visibilityPriority(.low)
            // 2 · overflow menu — these items always live behind "…"
            ToolbarOverflowMenu {
                Button("Duplicate", systemImage: "doc.on.doc") { log.append("Duplicate tapped") }
                Button("Archive", systemImage: "archivebox") { log.append("Archive tapped") }
                Button(role: .destructive) { log.append("Delete tapped") } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private func toolCard(icon: String, title: String, code: String, detail: String) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: icon).foregroundStyle(.tint)
                    Text(title).font(.headline)
                }
                Text(code).font(.caption.monospaced()).foregroundStyle(.secondary)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SmartToolbarsView_Previews: PreviewProvider {
    static var previews: some View {
        SmartToolbarsView()
    }
}

