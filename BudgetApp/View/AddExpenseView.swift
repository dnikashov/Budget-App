//
//  AddExpenseView.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-16.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var title: String = ""
    @State private var date: Date = .init()
    @State private var amount: CGFloat = 0
    @State private var category: Category?
    @Query(animation: .snappy) private var allCategories: [Category]
    
    var body: some View {
        NavigationStack{
            List{
                Section("Title"){
                    TextField("Item Purchased", text: $title)
                }
                Section("Amount Spent"){
                    HStack(spacing: 4){
                        Text("$")
                            .fontWeight(.semibold)
                        TextField("0.0", value: $amount, formatter: formatter)
                            .keyboardType(.numberPad)
                    }
                }
                Section("Date"){
                    DatePicker("",selection: $date,displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                if !allCategories.isEmpty{
                    HStack{
                        Text("Category")
                        
                        Spacer()
                        
                        Menu {
                            ForEach(allCategories.filter { !$0.isDone }) { categoryy in
                                Button(categoryy.categoryName){
                                    self.category = categoryy
                                    category = categoryy
                                }
                            }
                            Button("None"){
                                category = nil
                            }
                        }label:{
                            if let categoryName = category?.categoryName {
                                Text(categoryName)
                            } else {
                                Text("None")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                //Cancel and Add button
                ToolbarItem (placement: .topBarLeading){
                    Button ("Cancel"){
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button ("Add", action:addExpense)
                        .disabled(isAddButtonDisabled)
                }
            }
        }
    }
    //Adding Expense
    func addExpense(){
        let expense = Expense(title: title, amount: amount, date: date, category: category)
        context.insert(expense)
        category?.addExpense(expense)
        dismiss()
    }
    
    var isAddButtonDisabled: Bool{
        return title.isEmpty || amount == .zero
    }
    
    var formatter: NumberFormatter{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

#Preview {
    AddExpenseView()
}
