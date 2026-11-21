//
//  AddPurchaseView.swift
//  SpendingTracker
//

import SwiftData
import SwiftUI

struct AddPurchaseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Form fields. These only live in this screen until Save is tapped.
    @State private var merchant = ""
    @State private var amountText = ""
    @State private var date = Date.now
    @State private var card = PurchaseCards.all.first ?? ""
    @State private var category = "Miscellaneous"

    /// The decimal point for the user's region ("." in the US, "," in much of Europe).
    private let decimalSeparator = Locale.current.decimalSeparator ?? "."

    /// The typed amount as a Decimal, or nil if it isn't a valid number.
    private var parsedAmount: Decimal? {
        Decimal(string: amountText, locale: .current)
    }

    /// Keeps only digits and a single decimal point, with at most 2 digits after it.
    /// The decimal pad already limits what can be typed, but this also catches
    /// pasted text and hardware keyboards (like your Mac's keyboard in the Simulator).
    private func cleanedAmount(_ text: String) -> String {
        var result = ""
        var hasSeparator = false
        var digitsAfterSeparator = 0

        for character in text {
            if character.isASCII && character.isNumber {
                if hasSeparator {
                    guard digitsAfterSeparator < 2 else { continue }
                    digitsAfterSeparator += 1
                }
                result.append(character)
            } else if String(character) == decimalSeparator && !hasSeparator {
                hasSeparator = true
                result.append(character)
            }
        }
        return result
    }

    private var canSave: Bool {
        let hasMerchant = !merchant.trimmingCharacters(in: .whitespaces).isEmpty
        let hasPositiveAmount = (parsedAmount ?? 0) > 0
        return hasMerchant && hasPositiveAmount
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Merchant", text: $merchant)
                HStack(spacing: 4) {
                    Text(Locale.current.currencySymbol ?? "$")
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .onChange(of: amountText) { _, newValue in
                            let cleaned = cleanedAmount(newValue)
                            if cleaned != newValue {
                                amountText = cleaned
                            }
                        }
                }
                DatePicker("Date", selection: $date)
                Picker("Card", selection: $card) {
                    ForEach(PurchaseCards.all, id: \.self) { card in
                        Text(card)
                    }
                }
                Picker("Category", selection: $category) {
                    ForEach(PurchaseCategories.all, id: \.self) { category in
                        Text(category)
                    }
                }
            }
            .navigationTitle("New Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        guard let amount = parsedAmount else { return }
        let purchase = Purchase(
            rawMerchant: merchant,
            amount: amount,
            card: card,
            date: date,
            category: category,
            source: .manual
        )
        modelContext.insert(purchase)
        dismiss()
    }
}

#Preview {
    AddPurchaseView()
        .modelContainer(PreviewData.makeContainer())
}
