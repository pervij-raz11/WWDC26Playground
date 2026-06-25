// WHAT TO LOOK FOR:
// The "Model init count" stays at 1 no matter how many times you tap "+".
// Tapping "+" increments the counter → SwiftUI re-renders the view → but the
// @Observable object held in @State is NOT recreated (init fires once only).
//
// This is the @State + @Observable guarantee introduced in iOS 17.
// It IS a real, shipping API — no fallback needed.
// RESULT: ✅ Real API (iOS 17+, works on iOS 26).

import SwiftUI

@Observable
@MainActor
final class CounterModel {
    var count = 0
    private(set) var initCount = 0
    // nonisolated(unsafe) because init fires on MainActor in practice but Swift 6
    // requires explicit annotation for mutable static on a @MainActor class.
    nonisolated(unsafe) static var globalInitCount = 0

    init() {
        CounterModel.globalInitCount += 1
        initCount = CounterModel.globalInitCount
        print("CounterModel.init() fired — total inits: \(CounterModel.globalInitCount)")
    }
}

struct StateObservableView: View {
    // @State ensures the @Observable object is created exactly once
    // even though SwiftUI may re-evaluate this view body many times.
    @State private var model = CounterModel()

    var body: some View {
        VStack(spacing: 24) {
            RealAPIBanner(text: "✅ Real API — @State + @Observable (iOS 17+). Works on iOS 26.")

            GroupBox("Counter") {
                HStack {
                    Text("\(model.count)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                    Spacer()
                    Button {
                        model.count += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 44))
                    }
                }
                .padding()
            }

            GroupBox("Model lifecycle") {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Model init() call count: **\(CounterModel.globalInitCount)**",
                          systemImage: "1.circle")
                    Text("This should always be **1**.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Divider()
                    Text("Each tap causes a view body re-evaluation (you can verify by adding a print there), but the @Observable inside @State is never re-initialised.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }

            Button("Force re-render without counter") {
                // Tapping this triggers a state change that re-evaluates body
                // without going through the counter path.
                model.count += 0
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("G · @State @Observable")
        .navigationBarTitleDisplayMode(.inline)
    }
}
