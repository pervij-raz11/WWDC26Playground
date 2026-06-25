// WHAT TO LOOK FOR:
// Press and hold any card in the LazyVGrid, then drag to reorder.
// .reorderable() on ForEach + .reorderContainer(for: ColorCard.self, move:) on the container.
// ReorderDifference.sources — IDs of items being moved.
// ReorderDifference.destination.position — .before(ID) or .end.

import SwiftUI

// RESULT: .reorderable() + .reorderContainer(for:move:) — REAL API, iOS 27 SDK.

struct ReorderAnywhereView: View {
    @State private var items: [ColorCard] = ColorCard.sample

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]

    var body: some View {
        let binding = $items
        ScrollView {
            VStack(spacing: 0) {
                RealAPIBanner(text: "✅ Real API — .reorderable() + .reorderContainer(for:move:) iOS 27.\nPress and hold a card, then drag to reorder.")
                    .padding(.bottom, 4)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(items) { card in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(card.color.gradient)
                            .frame(height: 90)
                            .overlay(
                                Text(card.label)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            )
                    }
                    .reorderable()
                }
                .padding()
                .reorderContainer(for: ColorCard.self) { difference in
                    var arr = binding.wrappedValue
                    let moved = difference.sources.compactMap { id in arr.first { $0.id == id } }
                    arr.removeAll { difference.sources.contains($0.id) }
                    switch difference.destination.position {
                    case .before(let anchorID):
                        let idx = arr.firstIndex { $0.id == anchorID } ?? arr.endIndex
                        arr.insert(contentsOf: moved, at: idx)
                    case .end:
                        arr.append(contentsOf: moved)
                    }
                    binding.wrappedValue = arr
                }
            }
        }
        .navigationTitle("A · Reorder Anywhere")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ColorCard: Identifiable {
    let id = UUID()
    let label: String
    let color: Color

    static let sample: [ColorCard] = [
        .init(label: "Red",    color: .red),
        .init(label: "Orange", color: .orange),
        .init(label: "Yellow", color: .yellow),
        .init(label: "Green",  color: .green),
        .init(label: "Teal",   color: .teal),
        .init(label: "Blue",   color: .blue),
        .init(label: "Indigo", color: .indigo),
        .init(label: "Purple", color: .purple),
        .init(label: "Pink",   color: .pink),
        .init(label: "Brown",  color: .brown),
        .init(label: "Cyan",   color: .cyan),
        .init(label: "Mint",   color: .mint),
    ]
}
