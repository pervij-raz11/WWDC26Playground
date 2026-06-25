import SwiftUI

struct FeatureItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
}

private let features: [FeatureItem] = [
    FeatureItem(id: "A", title: "A · Reorder Anywhere",         subtitle: "LazyVGrid drag-to-reorder"),
    FeatureItem(id: "B", title: "B · Swipe Outside List",       subtitle: "LazyVStack swipeActions"),
    FeatureItem(id: "C", title: "C · Prominent Tab",            subtitle: "Tab(role: .prominent)"),
    FeatureItem(id: "D", title: "D · Smart Toolbars",           subtitle: "visibilityPriority, overflow, minimize"),
    FeatureItem(id: "E", title: "E · Document API",             subtitle: "Off-main-thread writes"),
    FeatureItem(id: "F", title: "F · AsyncImage HTTP Cache",    subtitle: "URLCache + AsyncImage"),
    FeatureItem(id: "G", title: "G · @State @Observable",       subtitle: "Single init across re-renders"),
    FeatureItem(id: "H", title: "H · anyAppleOS + @diagnose",   subtitle: "Compile-time availability"),
    FeatureItem(id: "I", title: "I · async in defer",           subtitle: "Deferred async cleanup"),
    FeatureItem(id: "J", title: "J · Foundation Models Text",   subtitle: "On-device summarization"),
    FeatureItem(id: "K", title: "K · Foundation Models Vision", subtitle: "Image description"),
    FeatureItem(id: "L", title: "L · Modern Toolbar",          subtitle: "topBarPinnedTrailing + Liquid Glass alert"),
    FeatureItem(id: "M", title: "M · Swift 6.4 Safety",        subtitle: "InlineArray + Span + @diagnose"),
    FeatureItem(id: "N", title: "N · AI Capability Manager",    subtitle: "SystemLanguageModel + PCC"),
    FeatureItem(id: "O", title: "O · Media Intelligence",       subtitle: "FaceGroupAnalyzer"),
    FeatureItem(id: "P", title: "P · RealityKit + AppIntents",  subtitle: "GPU compute + Intent testing"),
]

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(features) { feature in
                NavigationLink {
                    destination(for: feature.id)
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

    @ViewBuilder
    private func destination(for id: String) -> some View {
        switch id {
        case "A": ReorderAnywhereView()
        case "B": SwipeOutsideListView()
        case "C": ProminentTabView()
        case "D": SmartToolbarsView()
        case "E": DocumentAPIView()
        case "F": AsyncImageCacheView()
        case "G": StateObservableView()
        case "H": AnyAppleOSView()
        case "I": AsyncDeferView()
        case "J": FoundationModelsTextView()
        case "K": FoundationModelsVisionView()
        case "L": ModernToolbarView()
        case "M": SwiftSafetyView()
        case "N": AICapabilityManagerView()
        case "O": MediaIntelligenceView()
        case "P": RealityKitAppIntentsView()
        default:  Text("Unknown screen")
        }
    }
}
