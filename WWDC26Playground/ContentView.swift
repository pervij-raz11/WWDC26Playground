import SwiftUI

/// Every feature screen in the playground, in display order.
///
/// Modeling features as an enum (rather than a string-keyed list) makes the
/// routing `switch` in `destination` exhaustive: the compiler guarantees a
/// destination exists for every case. There are no string keys to mistype and
/// no "Unknown screen" fallback to hide a missing route. The raw value is the
/// screen's canonical letter, matching the `A_`, `B_`, … source file names.
enum Feature: String, CaseIterable, Identifiable {
    case a = "A", b = "B", c = "C", d = "D", e = "E", f = "F", g = "G"
    case h = "H", i = "I", j = "J", k = "K", l = "L", m = "M", n = "N"
    case o = "O", p = "P", q = "Q", r = "R"

    var id: String { rawValue }

    /// The screen's name, without the leading letter.
    var name: String {
        switch self {
        case .a: "Reorder Anywhere"
        case .b: "Swipe Outside List"
        case .c: "Prominent Tab"
        case .d: "Smart Toolbars"
        case .e: "Document API"
        case .f: "AsyncImage HTTP Cache"
        case .g: "@State @Observable"
        case .h: "anyAppleOS + @diagnose"
        case .i: "async in defer"
        case .j: "Foundation Models Text"
        case .k: "Foundation Models Vision"
        case .l: "Modern Toolbar"
        case .m: "Swift 6.4 Safety"
        case .n: "AI Capability Manager"
        case .o: "Media Intelligence"
        case .p: "RealityKit + AppIntents"
        case .q: "Cleaner Presentation"
        case .r: "Context-Aware Localization"
        }
    }

    var subtitle: String {
        switch self {
        case .a: "LazyVGrid drag-to-reorder"
        case .b: "LazyVStack swipeActions"
        case .c: "Tab(role: .prominent)"
        case .d: "priority + overflow + pinned + minimize"
        case .e: "Off-main-thread writes"
        case .f: "URLCache + AsyncImage"
        case .g: "Single init across re-renders"
        case .h: "Compile-time availability"
        case .i: "Deferred async cleanup"
        case .j: "On-device summarization"
        case .k: "Image description"
        case .l: "topBarPinnedTrailing + Liquid Glass alert"
        case .m: "InlineArray + Span + @diagnose"
        case .n: "SystemLanguageModel + PCC"
        case .o: "FaceGroupAnalyzer"
        case .p: "GPU compute + Intent testing"
        case .q: "item-binding alert/dialog + crossFade"
        case .r: "String(localized:comment:) + String Catalog"
        }
    }

    /// The full title as shown in the list, e.g. "A · Reorder Anywhere".
    var title: String { "\(rawValue) · \(name)" }

    @MainActor @ViewBuilder
    var destination: some View {
        switch self {
        case .a: ReorderAnywhereView()
        case .b: SwipeOutsideListView()
        case .c: ProminentTabView()
        case .d: SmartToolbarsView()
        case .e: DocumentAPIView()
        case .f: AsyncImageCacheView()
        case .g: StateObservableView()
        case .h: AnyAppleOSView()
        case .i: AsyncDeferView()
        case .j: FoundationModelsTextView()
        case .k: FoundationModelsVisionView()
        case .l: ModernToolbarView()
        case .m: SwiftSafetyView()
        case .n: AICapabilityManagerView()
        case .o: MediaIntelligenceView()
        case .p: RealityKitAppIntentsView()
        case .q: CleanerPresentationView()
        case .r: LocalizationDemoView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(Feature.allCases) { feature in
                NavigationLink {
                    feature.destination
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title).font(.headline)
                        Text(feature.subtitle).font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("WWDC 2026 Playground")
        }
    }
}
