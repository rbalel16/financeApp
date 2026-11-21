//
//  ContentView.swift
//  SpendingTracker
//
//  Created by Rohan Balel on 11/20/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Purchase.date, order: .reverse) private var purchases: [Purchase]
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(purchases) { purchase in
                    NavigationLink {
                        PurchaseDetailView(purchase: purchase)
                    } label: {
                        PurchaseRow(purchase: purchase)
                    }
                }
                .onDelete(perform: deletePurchases)
            }
            .navigationTitle("Purchases")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Purchase", systemImage: "plus") {
                        isShowingAddSheet = true
                    }
                }
            }
            .overlay {
                if purchases.isEmpty {
                    ContentUnavailableView(
                        "No purchases yet",
                        systemImage: "creditcard",
                        description: Text("Tap + to add a purchase, or pay with Apple Pay once the Shortcuts automation is set up.")
                    )
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddPurchaseView()
            }
        }
    }

    /// Deletes the purchases at the swiped row positions.
    private func deletePurchases(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(purchases[index])
        }
    }
}

/// One row in the purchase list.
struct PurchaseRow: View {
    let purchase: Purchase

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(purchase.merchant.isEmpty ? "Unknown merchant" : purchase.merchant)
                        .bold()
                    if purchase.needsReview {
                        Label("Needs review", systemImage: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                Text(purchase.category)
                    .foregroundStyle(.secondary)
                Text(purchase.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(purchase.formattedAmount)
        }
    }
}

#Preview("With purchases") {
    ContentView()
        .modelContainer(PreviewData.makeContainer())
}

#Preview("Empty") {
    ContentView()
        .modelContainer(for: Purchase.self, inMemory: true)
}
