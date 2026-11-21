//
//  SpendingTrackerTests.swift
//  SpendingTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import SpendingTracker

struct PurchaseTests {

    @Test func validPurchaseDoesNotNeedReview() throws {
        let amount = try #require(Decimal(string: "4.35"))
        let purchase = Purchase(rawMerchant: "Blue Bottle", amount: amount, card: "Apple Card")

        #expect(purchase.needsReview == false)
        #expect(purchase.source == .manual)
        #expect(purchase.category == "Uncategorized")
        #expect(purchase.notes == nil)
    }

    @Test func merchantIsTrimmedButRawIsKept() {
        let purchase = Purchase(rawMerchant: "  Blue Bottle \n", amount: 5, card: "Visa")

        #expect(purchase.merchant == "Blue Bottle")
        #expect(purchase.rawMerchant == "  Blue Bottle \n")
    }

    // Runs once per input: blank or whitespace-only merchants get flagged.
    @Test(arguments: ["", "   ", "\n"])
    func blankMerchantNeedsReview(merchant: String) {
        let purchase = Purchase(rawMerchant: merchant, amount: 10, card: "Visa")
        #expect(purchase.needsReview)
    }

    @Test(arguments: [Decimal(0), Decimal(-5)])
    func zeroOrNegativeAmountNeedsReview(amount: Decimal) {
        let purchase = Purchase(rawMerchant: "Target", amount: amount, card: "Visa")
        #expect(purchase.needsReview)
    }

    @Test func formattedAmountShowsCurrency() throws {
        let amount = try #require(Decimal(string: "4.35"))
        let purchase = Purchase(rawMerchant: "Cafe", amount: amount, card: "Visa")

        // Depends on the device's locale, so check the digits rather than the exact string.
        #expect(purchase.formattedAmount.contains("4"))
        #expect(purchase.formattedAmount.contains("35"))
    }

    // Checks that SwiftData can actually save and fetch a Purchase.
    // The in-memory store means nothing touches the real database.
    @MainActor @Test func purchaseSavesAndFetches() throws {
        let container = try ModelContainer(
            for: Purchase.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        context.insert(Purchase(rawMerchant: "Trader Joe's", amount: 42, card: "Visa", source: .wallet))
        try context.save()

        let results = try context.fetch(FetchDescriptor<Purchase>())
        #expect(results.count == 1)
        #expect(results.first?.source == .wallet)
    }
}
