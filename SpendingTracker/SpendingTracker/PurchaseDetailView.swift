//
//  PurchaseDetailView.swift
//  SpendingTracker
//

import SwiftData
import SwiftUI

struct PurchaseDetailView: View {
    @Bindable var purchase: Purchase

    /// Notes is optional (String?), but TextField needs a plain String.
    /// This binding shows "" for nil and stores nil when the field is cleared.
    private var notesBinding: Binding<String> {
        Binding(
            get: { purchase.notes ?? "" },
            set: { purchase.notes = $0.isEmpty ? nil : $0 }
        )
    }

    /// Wallet (or older entries) can store a card or category that isn't in our list.
    /// Adding the current value keeps the picker from showing up blank.
    private func options(_ list: [String], including current: String) -> [String] {
        list.contains(current) ? list : [current] + list
    }

    private var sourceName: String {
        switch purchase.source {
        case .wallet: "Apple Wallet"
        case .manual: "Manual entry"
        case .csvImport: "CSV import"
        }
    }

    var body: some View {
        Form {
            if purchase.needsReview {
                Section {
                    Label("This purchase is missing a merchant or amount.", systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Button("Mark as reviewed") {
                        purchase.needsReview = false
                    }
                }
            }

            Section("Details") {
                TextField("Merchant", text: $purchase.merchant)
                TextField(
                    "Amount",
                    value: $purchase.amount,
                    format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                )
                .keyboardType(.decimalPad)
                DatePicker("Date", selection: $purchase.date)
                Picker("Card", selection: $purchase.card) {
                    ForEach(options(PurchaseCards.all, including: purchase.card), id: \.self) { card in
                        Text(card.isEmpty ? "None" : card)
                    }
                }
                Picker("Category", selection: $purchase.category) {
                    ForEach(options(PurchaseCategories.all, including: purchase.category), id: \.self) { category in
                        Text(category)
                    }
                }
            }

            Section("Notes") {
                TextField("Add a note", text: notesBinding, axis: .vertical)
            }

            Section("Original data") {
                LabeledContent("Raw merchant", value: purchase.rawMerchant.isEmpty ? "(blank)" : purchase.rawMerchant)
                LabeledContent("Source", value: sourceName)
            }
        }
        .navigationTitle(purchase.merchant.isEmpty ? "Purchase" : purchase.merchant)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let container = PreviewData.makeContainer()
    let purchase = Purchase(rawMerchant: "  SQ *BLUE BOTTLE  ", amount: 0, card: "Apple Card", source: .wallet)
    container.mainContext.insert(purchase)

    return NavigationStack {
        PurchaseDetailView(purchase: purchase)
    }
    .modelContainer(container)
}
