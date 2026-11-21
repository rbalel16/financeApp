//
//  Purchase.swift
//  SpendingTracker
//

import Foundation
import SwiftData

/// Where a purchase record came from.
enum PurchaseSource: String, Codable {
    case wallet
    case manual
    case csvImport
}

@Model
final class Purchase {
    var id: UUID
    var date: Date
    /// Merchant name exactly as received from Wallet (kept for future re-cleaning/matching).
    var rawMerchant: String
    /// Cleaned-up display name derived from `rawMerchant`.
    var merchant: String
    var amount: Decimal
    var card: String
    // TODO: Replace with a Category model relationship.
    var category: String
    var source: PurchaseSource
    var needsReview: Bool
    var notes: String?

    init(
        rawMerchant: String,
        amount: Decimal,
        card: String,
        date: Date = .now,
        category: String = "Uncategorized",
        source: PurchaseSource = .manual,
        notes: String? = nil
    ) {
        let cleanedMerchant = rawMerchant.trimmingCharacters(in: .whitespacesAndNewlines)

        self.id = UUID()
        self.date = date
        self.rawMerchant = rawMerchant
        self.merchant = cleanedMerchant
        self.amount = amount
        self.card = card
        self.category = category
        self.source = source
        self.notes = notes
        // The Wallet automation sometimes sends incomplete data; keep the record but flag it.
        self.needsReview = cleanedMerchant.isEmpty || amount <= 0
    }

    /// The amount formatted as currency in the user's locale.
    var formattedAmount: String {
        amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}
