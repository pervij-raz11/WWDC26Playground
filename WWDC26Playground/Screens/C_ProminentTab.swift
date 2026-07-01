// WHAT TO LOOK FOR:
// The bottom tab bar — the "Create" tab should appear visually prominent
// (larger / distinct style) due to role: .prominent.
// This is a real iOS 27 API — no fallback.
// WHAT TO LOOK FOR:
// The bottom tab bar — the "Create" tab should appear visually prominent
// (larger / distinct style) due to role: .prominent.
// This is a real iOS 27 API — no fallback.
// WHAT TO LOOK FOR:
// The bottom tab bar — the "Create" tab should appear visually prominent
// (larger / distinct style) due to role: .prominent.
// This is a real iOS 27 API — no fallback.

import SwiftUI

// RESULT: Tab(role: .prominent) — REAL API, iOS 27 SDK.

enum PlaygroundTab: Hashable {
    case home, explore, create, profile
}

struct ProminentTabView: View {
    @State private var selected: PlaygroundTab = .home

    var body: some View {
        VStack() {
            RealAPIBanner(text: "✅ Real API — Tab(role: .prominent) iOS 27 SDK. Notice the visually prominent Create tab.")
            Spacer()
            TabView(selection: $selected) {
                Tab("Home", systemImage: "house", value: PlaygroundTab.home) {
                    tabContent("Home", systemImage: "house.fill", color: .blue)
                }
                Tab("Explore", systemImage: "magnifyingglass", value: PlaygroundTab.explore) {
                    tabContent("Explore", systemImage: "magnifyingglass", color: .green)
                }
                Tab("Create", systemImage: "plus.circle.fill", value: PlaygroundTab.create, role: .prominent) {
                    tabContent("Create ✨", systemImage: "plus.circle.fill", color: .orange)
                }
                Tab("Profile", systemImage: "person", value: PlaygroundTab.profile) {
                    tabContent("Profile", systemImage: "person.fill", color: .purple)
                }
            }
        }
    }

    private func tabContent(_ title: String, systemImage: String, color: Color) -> some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(color)
            Text(title).font(.title2.bold())
            Text("The \"Create\" tab has role: .prominent — the system automatically gives it elevated visual weight.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        ProminentTabView()
    }
}
