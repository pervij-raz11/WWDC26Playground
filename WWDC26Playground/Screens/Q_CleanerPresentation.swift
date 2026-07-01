// WHAT TO LOOK FOR:
// .alert(item:actions:message:) — iOS 27. No separate isPresented Bool needed.
//   Tap a fruit card → alert driven by Binding<Fruit?>.
// .confirmationDialog(item:actions:message:) — iOS 27. Same pattern, no Bool.
//   Long-press a fruit card → sheet driven by Binding<Fruit?>.
// .navigationTransition(.crossFade) — iOS 27. NavigationLink → detail view cross-fades in.
// Liquid Glass on alerts/sheets — automatic on iOS 26+, zero API change needed.

import SwiftUI

struct Fruit: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let fact: String
}

private let fruits: [Fruit] = [
    Fruit(name: "Apple",  emoji: "🍎", fact: "Apples are 25% air — that's why they float."),
    Fruit(name: "Banana", emoji: "🍌", fact: "Botanically, bananas are berries."),
    Fruit(name: "Cherry", emoji: "🍒", fact: "Cherries belong to the rose family."),
    Fruit(name: "Grape",  emoji: "🍇", fact: "Grapes will explode if microwaved."),
    Fruit(name: "Lemon",  emoji: "🍋", fact: "Lemons contain more sugar than strawberries."),
    Fruit(name: "Mango",  emoji: "🥭", fact: "Mangoes are related to poison ivy."),
]

struct CleanerPresentationView: View {
    @State private var alertFruit:  Fruit? = nil
    @State private var dialogFruit: Fruit? = nil

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RealAPIBanner(text: "✅ Real APIs — iOS 27: .alert(item:) + .confirmationDialog(item:) (no isPresented Bool) + .navigationTransition(.crossFade). Liquid Glass on alerts/sheets — automatic.")

                alertSection
                dialogSection
                crossFadeSection
            }
            .padding()
        }
        .navigationTitle("Q · Cleaner Presentation")
        .navigationBarTitleDisplayMode(.inline)
        // ── Item-binding alert — no separate Bool state ───────────────────────
        .alert("About \(alertFruit?.name ?? "")", item: $alertFruit) { fruit in
            Button("Got it") { }
        } message: { fruit in
            Text(fruit.fact)
        }
        // ── Item-binding confirmationDialog — no separate Bool state ──────────
        .confirmationDialog(
            "\(dialogFruit?.emoji ?? "") \(dialogFruit?.name ?? "")",
            item: $dialogFruit,
            titleVisibility: .visible
        ) { fruit in
            Button("Favourite \(fruit.emoji)") { }
            Button("Share info") { }
            Button("Cancel", role: .cancel) { }
        } message: { fruit in
            Text(fruit.fact)
        }
    }

    // ── Alert section ─────────────────────────────────────────────────────────
    private var alertSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("Item-binding Alert").font(.headline)
                Text("Tap a card — the alert title and message come from the item. No Bool state needed.")
                    .font(.caption).foregroundStyle(.secondary)

                codeBlock("""
// Before (iOS 16–26):
@State var isPresented = false
@State var selectedFruit: Fruit? = nil
.alert("About...", isPresented: $isPresented, presenting: selectedFruit) { fruit in
    Button("OK") { }
} message: { fruit in Text(fruit.fact) }

// After (iOS 27):
@State var alertFruit: Fruit? = nil
.alert("About \\(alertFruit?.name ?? "")", item: $alertFruit) { fruit in
    Button("Got it") { }
} message: { fruit in Text(fruit.fact) }
""")

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(fruits) { fruit in
                        Button { alertFruit = fruit } label: {
                            fruitCard(fruit, hint: "tap")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // ── ConfirmationDialog section ────────────────────────────────────────────
    private var dialogSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("Item-binding ConfirmationDialog").font(.headline)
                Text("Long-press a card — actions receive the item directly.")
                    .font(.caption).foregroundStyle(.secondary)

                codeBlock("""
// iOS 27:
@State var dialogFruit: Fruit? = nil
.confirmationDialog(fruit.name, item: $dialogFruit, titleVisibility: .visible) { fruit in
    Button("Favourite \\(fruit.emoji)") { }
    Button("Share info") { }
    Button("Cancel", role: .cancel) { }
} message: { fruit in Text(fruit.fact) }
""")

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(fruits) { fruit in
                        Button { dialogFruit = fruit } label: {
                            fruitCard(fruit, hint: "hold")
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Show options") { dialogFruit = fruit }
                        }
                    }
                }
            }
        }
    }

    // ── Cross-fade section ────────────────────────────────────────────────────
    private var crossFadeSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("Cross-Fade Navigation Transition").font(.headline)
                Text("Tap the link — the destination slides in with a cross-fade instead of the default push.")
                    .font(.caption).foregroundStyle(.secondary)

                codeBlock("""
NavigationLink {
    DetailView()
        .navigationTransition(.crossFade)  // iOS 27
} label: {
    Label("Open with cross-fade", systemImage: "arrow.right.circle")
}
""")

                NavigationLink {
                    CrossFadeDetailView()
                        .navigationTransition(.crossFade)
                } label: {
                    Label("Open with .crossFade transition", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Text("Liquid Glass on alerts and sheets is applied automatically by the system on iOS 26+ — no API change from the previous .alert(isPresented:) approach.")
                    .font(.caption).foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private func fruitCard(_ fruit: Fruit, hint: String) -> some View {
        VStack(spacing: 4) {
            Text(fruit.emoji).font(.largeTitle)
            Text(fruit.name).font(.caption).bold()
            Text(hint).font(.caption2).foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func codeBlock(_ code: String) -> some View {
        Text(code)
            .font(.system(.caption2, design: .monospaced))
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// ── Cross-fade destination ────────────────────────────────────────────────────
private struct CrossFadeDetailView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.arrow.right.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Cross-Fade Detail")
                .font(.title2.bold())
            Text("This view appeared via .navigationTransition(.crossFade) — no slide, just a smooth opacity blend.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("Cross-Fade Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
