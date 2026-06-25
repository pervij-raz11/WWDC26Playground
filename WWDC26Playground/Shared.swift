import SwiftUI

struct FallbackBanner: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .multilineTextAlignment(.leading)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.25))
            .overlay(Rectangle().frame(height: 1).foregroundStyle(.yellow), alignment: .bottom)
    }
}

struct RealAPIBanner: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .multilineTextAlignment(.leading)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.20))
            .overlay(Rectangle().frame(height: 1).foregroundStyle(.green), alignment: .bottom)
    }
}
