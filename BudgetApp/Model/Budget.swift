//
//  Budget.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-15.
//

import SwiftUI
import SwiftData

@Model
class Category{
    
    //Properties
    var categoryName: String
    var limit: Double
    var date: Date
    var savings: Savings?
    var totalAmount: Double
    var isDone: Bool
    
    var leftover: Double {
        if let expenses = expenses, !expenses.isEmpty {
            let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
            return limit - totalExpenses
        } else if (self.isDone){
            // If there are no expenses, set leftover to the totalAmount
            return totalAmount
        } else {
            return limit
        }
    }
    
    @Relationship(deleteRule:.cascade,inverse: \Expense.category)
    var expenses: [Expense]?
    
    init(categoryName: String, limit: Double, date: Date, savings: Savings? = nil) {
        self.categoryName = categoryName
        self.limit = limit
        self.savings = savings
        self.date = date
        self.isDone = false
        self.totalAmount = 0
    }
    
    func findTotalBalance() -> Double {
        var totalExpenses = 0.0
        if let expenses = self.expenses, !expenses.isEmpty {
            for expense in expenses {
                totalExpenses += expense.amount
            }
        }
        return self.limit - totalExpenses
    }
    
    func updateTotal() {
        // Calculate the total amount of all expenses
        let totalExpenses = expenses?.reduce(0) { $0 + $1.amount } ?? 0.0
        
        // Update the totalAmount property with the sum of all expenses
        self.totalAmount = self.limit - totalExpenses
    }
    
    func duplicateCategory(context: ModelContext) {
        let newCategory = Category(
            categoryName: self.categoryName,
            limit: self.limit,
            date: Date(), // Set the date to the current date
            savings: self.savings
        )
        
        // Copy the properties
        newCategory.totalAmount = 0.0
        newCategory.isDone = false
        self.savings?.addCategory(newCategory)
        // Save the new category in the context
        context.insert(newCategory)
    }
    
    func checkMonthChange() -> Bool{
        let currentMonth = Calendar.current.component(.month, from: Date())
        let categoryMonth = Calendar.current.component(.month, from: self.date)
        
        if currentMonth != categoryMonth {
            self.isDone = true
            self.updateTotal()
            return true
        }
        return false
    }
    
    func addExpense(_ expense: Expense) {
            if self.expenses == nil {
                self.expenses = []
            }
            self.expenses?.append(expense)
        }

}
