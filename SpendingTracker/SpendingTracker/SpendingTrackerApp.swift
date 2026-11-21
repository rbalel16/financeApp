//
//  SpendingTrackerApp.swift
//  SpendingTracker
//
//  Created by Rohan Balel on 11/20/26.
//

import SwiftData
import SwiftUI

@main
struct SpendingTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Purchase.self)
    }
}
