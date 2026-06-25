// WHAT TO LOOK FOR:
// Swipe left on any row in the LazyVStack (not a List!) — a Delete button appears.
// .swipeActionsContainer() enables swipeActions support outside of List.
// This is a real iOS 27 API.

import SwiftUI

// RESULT: .swipeActionsContainer() — REAL API, iOS 27 SDK.

struct SwipeOutsideListView: View {
    @State private var rows: [SwipeRow] = (1...12).map { SwipeRow(id: $0, text: "Row \($0)") }

    var body: some View {
        VStack(spacing: 0) {
            RealAPIBanner(text: "✅ Real API — .swipeActionsContainer() iOS 27.\nSwipe in LazyVStack (not List) — works!")

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(rows) { row in
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundStyle(.blue)
                                .frame(width: 32)
                            VStack(alignment: .leading) {
                                Text(row.text).font(.headline)
                                Text("Swipe left/right for actions").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                rows.removeAll { $0.id == row.id }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button { } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .leading) {
                            Button { } label: {
                                Label("Flag", systemImage: "flag")
                            }
                            .tint(.orange)
                        }
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .swipeActionsContainer()
        }
        .navigationTitle("B · Swipe Outside List")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SwipeRow: Identifiable {
    let id: Int
    let text: String
}
