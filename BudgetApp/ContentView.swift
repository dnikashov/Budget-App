//
//  ContentView.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-15.
//

import SwiftUI

struct ContentView: View {
    //View properties
    @State private var currentTab: String = "Expenses"
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        TabView(selection: $currentTab){
            ExpensesView(currentTab: $currentTab)
                .tag("Expenses")
                .tabItem{
                    Image(systemName: "creditcard.fill")
                    Text("Expenses")
                }
                .environment(\.editMode, $editMode)
            CategoriesView()
                .tag("Categories")
                .tabItem{
                    Image(systemName: "list.clipboard.fill")
                    Text("Categories")
                }
                .environment(\.editMode, $editMode)
            SavingsView()
                .tag("Savings")
                .tabItem{
                    Image(systemName: "list.clipboard.fill")
                    Text("Savings")
                }
                .environment(\.editMode, $editMode)
        }
    }
}

#Preview {
    ContentView()
}
