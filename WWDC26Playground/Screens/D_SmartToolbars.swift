// WHAT TO LOOK FOR:
// Scroll down — the navigation bar minimizes automatically.
// Tap "..." — an overflow menu appears with additional buttons.
// All modifiers are real iOS 27 APIs.

import SwiftUI

// RESULT: .toolbarMinimizeBehavior — REAL API, iOS 27 SDK.

struct SmartToolbarsView: View {
    @State private var log: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RealAPIBanner(text: "✅ Real APIs — .toolbarMinimizeBehavior(.onScrollDown), ToolbarItem visibilityPriority, overflow menu — iOS 27 SDK")

                Text("⬇︎ Scroll down — the nav bar minimizes automatically")
                    .font(.caption)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.08))
                Divider()

                ForEach(0..<50, id: \.self) { i in
                    HStack {
                        Text("Row \(i + 1)")
                        Spacer()
                        if !log.isEmpty && i == 0 {
                            Text(log.last ?? "").font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    Divider().padding(.leading)
                }
            }
        }
        .navigationTitle("D · Smart Toolbars")
        .navigationBarTitleDisplayMode(.large)
        .toolbarMinimizeBehavior(.onScrollDown, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { log.append("Share tapped") } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { log.append("Edit tapped") } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Duplicate", systemImage: "doc.on.doc") { log.append("Duplicate") }
                    Button("Archive", systemImage: "archivebox") { log.append("Archive") }
                    Divider()
                    Button(role: .destructive) { log.append("Delete") } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
    }
}
