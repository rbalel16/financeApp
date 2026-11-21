# SpendingTracker

iOS app (SwiftUI + SwiftData) that logs Apple Pay purchases via a Shortcuts
Transaction automation and auto-categorizes them.

## Keeping this file current

After any change that adds, removes, or restructures files, models, intents, or features,
update this file (especially **Project status** and **Planned architecture**) so it
reflects what the project currently contains and what's being worked on.

## Project status

- `SpendingTracker/SpendingTrackerApp.swift` — `@main` entry point; attaches
  `.modelContainer(for: Purchase.self)` to the `WindowGroup`
- `SpendingTracker/Purchase.swift` — SwiftData `@Model final class Purchase` plus
  `PurchaseSource` enum (`.wallet`, `.manual`, `.csvImport`)
  - Named `Purchase` (not `Transaction`) to avoid clashing with SwiftUI's `Transaction`
  - `amount` is `Decimal` (never `Double` for money); `formattedAmount` uses the locale currency
  - `rawMerchant` = exactly what Wallet sent; `merchant` = cleaned display name (currently just trimmed)
  - `category` is a `String` defaulting to `"Uncategorized"` — to be replaced by a `Category` model later
  - `init` sets `needsReview = true` when the trimmed merchant is blank or `amount <= 0`
    (bad Wallet data is flagged, never dropped)
- `SpendingTrackerTests/SpendingTrackerTests.swift` — Swift Testing suite for `Purchase`
  (defaults, trimming, `needsReview` rules, currency formatting, in-memory SwiftData save/fetch)
  - The test target must have **Host Application = SpendingTracker**. Debug builds put app code
    in `SpendingTracker.debug.dylib`, so tests won't link without proper hosting.
  - Tests run through the `SpendingTracker` scheme's `SpendingTracker.xctestplan` (⌘U).
  - In test code, build money values with `Decimal(string:)`, not `Decimal(Double)`.
- `SpendingTracker/ContentView.swift` — still the placeholder "Hello, world!" view
- `SpendingTracker/Assets.xcassets`

Not built yet: App Intent for the Shortcuts Transaction automation, categorization logic,
`Category` model, any real UI.

## Planned architecture

- **Persistence:** SwiftData `@Model` types — `Purchase` exists; a `Category` model is
  planned to replace the `category` string. Container is attached in `SpendingTrackerApp`.
- **Ingestion:** An App Intent exposed to Shortcuts. The user sets up a personal
  automation using the Wallet **Transaction** trigger, which passes merchant/amount/card
  details to the intent; the intent's `perform()` inserts a record into SwiftData.
  Because intents can run in the background, the intent must open its own `ModelContainer`
  (or a shared one) rather than relying on the SwiftUI environment.
- **Categorization:** Map merchant names to categories (rule-based first; keep it in a
  standalone, testable type separate from views and intents).
- **UI:** SwiftUI views reading data with `@Query`.

## Building & testing

- Use the Xcode MCP tools (`BuildProject`, `XcodeRefreshCodeIssuesInFile`, `RunSomeTests`,
  `RunAllTests`) rather than `xcodebuild` from the shell.
- Use Swift Testing (`import Testing`, `@Test`, `#expect`) for unit tests and
  XCUIAutomation for UI tests.
- Check Apple docs with `DocumentationSearch` for App Intents, SwiftData, and any
  newer SwiftUI APIs before assuming an API's shape.

## Conventions

- 4-space indentation; PascalCase types, camelCase members.
- `@State private var` for view state; `let` for constants; avoid force unwrapping.
- Prefer async/await over Combine.
- Keep changes scoped to what was asked.
