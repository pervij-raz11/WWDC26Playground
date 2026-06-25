// WHAT TO LOOK FOR:
// Tap "Clear & reload" — images load from network (slight delay).
// Tap "Reload (cached)" — appear instantly from URLCache.
// .asyncImageURLSession(_:) is a real iOS 27 modifier for AsyncImage.

import SwiftUI
import UIKit

// RESULT: .asyncImageURLSession(_:) — REAL API, iOS 27 SDK.

private let cachedSession: URLSession = {
    let cache = URLCache(memoryCapacity: 20 * 1024 * 1024,
                        diskCapacity:   100 * 1024 * 1024)
    let config = URLSessionConfiguration.default
    config.urlCache = cache
    config.requestCachePolicy = .returnCacheDataElseLoad
    return URLSession(configuration: config)
}()

private let imageURLs: [URL] = [
    URL(string: "https://picsum.photos/seed/alpha/400/240")!,
    URL(string: "https://picsum.photos/seed/beta/400/240")!,
    URL(string: "https://picsum.photos/seed/gamma/400/240")!,
    URL(string: "https://picsum.photos/seed/delta/400/240")!,
]

struct AsyncImageCacheView: View {
    @State private var reloadID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            RealAPIBanner(text: "✅ Real API — AsyncImage + .asyncImageURLSession(_:) iOS 27.\nFirst load — network. Second — instant from URLCache.")

            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Button("Clear & reload") {
                            cachedSession.configuration.urlCache?.removeAllCachedResponses()
                            reloadID = UUID()
                        }
                        .buttonStyle(.borderedProminent)
                        Button("Reload (cached)") { reloadID = UUID() }
                            .buttonStyle(.bordered)
                    }
                    .padding(.top, 12)

                    ForEach(imageURLs, id: \.self) { url in
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(height: 150)
                                    .overlay(ProgressView())
                            case .success(let img):
                                img.resizable()
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            case .failure:
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                                    .frame(height: 150)
                                    .overlay(Image(systemName: "xmark.circle").foregroundStyle(.red))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .asyncImageURLSession(cachedSession)
                        .id(reloadID)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("F · AsyncImage Cache")
        .navigationBarTitleDisplayMode(.inline)
    }
}
