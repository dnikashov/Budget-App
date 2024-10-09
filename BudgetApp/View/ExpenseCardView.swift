//
//  ExpenseCardView.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-16.
//

import SwiftUI

struct ExpenseCardView: View {
    @Bindable var expense: Expense
    var displayTag: Bool = true
    
    var body: some View {
        HStack{
            VStack(alignment:.leading){
                Text(expense.title)
                
                if let categoryName = expense.category?.categoryName, displayTag {
                    Text (categoryName)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.red.gradient, in: .capsule)
                }
            }
            .lineLimit(1)
            Spacer(minLength: 5)
            
            Text(expense.currencyString)
                .font(.title3.bold())
        }
    }
}
