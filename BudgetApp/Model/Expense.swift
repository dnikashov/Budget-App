//
//  Expenses.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-15.
//

import SwiftUI
import SwiftData

@Model
class Expense{
    
    //Properties
    var title: String
    var amount:Double
    var date: Date
    var category: Category?
    var isDone: Bool
    
    init(title: String, amount: Double, date: Date, category: Category? = nil) {
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.isDone = false
    }
    
    func hasFortyDaysPassed() -> Bool{
        let currentDate = Date()
        let calendar = Calendar.current

        // Calculate the difference in days between the current date and the creation date
        if let daysDifference = calendar.dateComponents([.day], from: self.date, to: currentDate).day {
            if daysDifference >= 40 {
                self.isDone = true
                return true
            }
        }
        return false
    }
    
    @Transient
    var currencyString: String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter.string(for: amount) ?? ""
    }
}



