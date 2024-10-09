//
//  Savings.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-15.
//

import SwiftUI
import SwiftData

@Model
class Savings{
    
    //Properties
    var savingsName: String
    var amount: Double
 
    
    @Relationship(deleteRule:.cascade,inverse: \Category.savings)
    var category: [Category]?
    
    init(savingsName: String, amount: Double) {
        self.savingsName = savingsName
        self.amount = amount
    }
    func addCategory(_ category: Category) {
            if self.category == nil {
                self.category = []
            }
            self.category?.append(category)
        }
}
