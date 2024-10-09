//
//  BudgetAppApp.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-15.
//

import SwiftUI
import SwiftData


@main
struct BudgetAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Expense.self, Category.self, Savings.self])
    }
}
