//
//  PreviewData.swift
//  SpendingTracker
//

#if DEBUG
import Foundation
import SwiftData

/// Sample data for Xcode previews only (excluded from release builds).
@MainActor
enum PreviewData {
    /// Creates a throwaway in-memory database filled with sample purchases.
    static func makeContainer() -> ModelContainer {
        do {
            let container = try ModelContainer(
                for: Purchase.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            for purchase in samplePurchases() {
                container.mainContext.insert(purchase)
            }
            return container
        } catch {
            fatalError("Could not create preview container: \(error)")
        }
    }

    static func samplePurchases() -> [Purchase] {
        [
            Purchase(
                rawMerchant: "Blue Bottle Coffee",
                amount: Decimal(string: "5.75") ?? 0,
                card: "Apple Card",
                date: .now,
                category: "Food",
                source: .wallet
            ),
            Purchase(
                rawMerchant: "Trader Joe's",
                amount: Decimal(string: "62.18") ?? 0,
                card: "Visa",
                date: .now.addingTimeInterval(-86_400),
                category: "Groceries"
            ),
            Purchase(
                rawMerchant: "Netflix",
                amount: Decimal(string: "15.49") ?? 0,
                card: "Apple Card",
                date: .now.addingTimeInterval(-3 * 86_400),
                category: "Subscriptions"
            ),
            // Blank merchant and $0 amount, so the initializer sets needsReview = true.
            Purchase(
                rawMerchant: "  ",
                amount: 0,
                card: "Apple Card",
                date: .now.addingTimeInterval(-5 * 86_400),
                source: .wallet
            )
        ]
    }
}
#endif
