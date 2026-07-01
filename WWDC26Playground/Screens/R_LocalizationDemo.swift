// WHAT TO LOOK FOR:
// Context-aware localization. The word "Home" appears twice with two different
// meanings, and they MUST translate differently:
//   • "Home" as a tab / navigation label  → the home *screen*   → ru: "Главная"
//   • "Home" as a button to an address     → the user's *house*  → ru: "Дом"
// One source word, two meanings. A single shared string would mistranslate one of
// them, so each gets a DISTINCT key plus a `comment:` that pins down the context.
// Every user-facing string below is wrapped in String(localized:) with a comment,
// so it is extracted into Localizable.xcstrings with that context attached.

import SwiftUI

struct LocalizationDemoView: View {
    // Two "Home" strings — same word, different meaning, DIFFERENT keys.
    // The key + comment is what lets the translator (and Xcode's Generate
    // Translations) tell them apart.
    private var homeTabLabel: String {
        String(
            localized: "tab.home",
            defaultValue: "Home",
            comment: "Tab bar / navigation label for the home screen (the app's main screen)"
        )
    }

    private var homeAddressButton: String {
        String(
            localized: "address.home.button",
            defaultValue: "Home",
            comment: "Button that opens the user's saved home address (their house / dwelling)"
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RealAPIBanner(text: String(
                    localized: "demo.banner",
                    defaultValue: "✅ Context-aware localization — the word \"Home\" appears twice with two meanings. Distinct keys + comments let it translate to \"Главная\" (screen) vs \"Дом\" (house).",
                    comment: "Explanatory banner at the top of the localization demo screen"
                ))

                itemCard
                statusSection
                addressSection
            }
            .padding()
        }
        // Navigation title — the "Home" *screen* meaning.
        .navigationTitle(homeTabLabel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label(
                        String(
                            localized: "toolbar.share",
                            defaultValue: "Share",
                            comment: "Toolbar button that shares the current item with others"
                        ),
                        systemImage: "square.and.arrow.up"
                    )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label(
                        String(
                            localized: "toolbar.edit",
                            defaultValue: "Edit",
                            comment: "Toolbar button that puts the current item into edit mode"
                        ),
                        systemImage: "pencil"
                    )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label(
                        String(
                            localized: "toolbar.bookmark",
                            defaultValue: "Bookmark",
                            comment: "Toolbar button that saves the current item to the user's bookmarks"
                        ),
                        systemImage: "bookmark"
                    )
                }
            }
        }
    }

    // ── Item card with a descriptive sentence ──────────────────────────────────
    private var itemCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(
                    localized: "item.title",
                    defaultValue: "Riverside Cottage",
                    comment: "Title of the property item shown on the home screen"
                ))
                .font(.headline)

                Text(String(
                    localized: "item.description",
                    defaultValue: "A quiet two-bedroom cottage by the river, recently renovated with a sunlit kitchen and a small garden out back.",
                    comment: "Body paragraph describing the property item to the user"
                ))
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // ── Status message ─────────────────────────────────────────────────────────
    private var statusSection: some View {
        GroupBox {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(String(
                    localized: "status.synced",
                    defaultValue: "Your changes were saved and synced to all your devices.",
                    comment: "Status message confirming the user's edits have been saved and synced"
                ))
                .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // ── Address navigation — the "Home" *house* meaning ─────────────────────────
    private var addressSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text(String(
                    localized: "address.section.caption",
                    defaultValue: "Open one of your saved places in Maps:",
                    comment: "Caption above the saved-address navigation buttons"
                ))
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    // "Home" here means the user's house — translates to "Дом".
                    Button {
                    } label: {
                        Label(homeAddressButton, systemImage: "house.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                    } label: {
                        Label(
                            String(
                                localized: "address.work.button",
                                defaultValue: "Work",
                                comment: "Button that opens the user's saved work address in Maps"
                            ),
                            systemImage: "briefcase.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
