//
//  ExpensesView.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-15.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Binding var currentTab: String
    //Grouped Expenses Properties
    @Query(sort: [
        SortDescriptor(\Expense.date, order: .reverse)
    ],animation: .snappy) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context
    @Query(animation: .snappy) private var allCategories: [Category]
    
    
    //Grouped Expenses
    @State private var groupedExpenses: [GroupedExpenses] = []
    @State private var addExpense: Bool = false
    @State private var requestedEditExpense: Expense?
    @State private var editMode = EditMode.inactive
    @State private var showEditSheet = false
    @State private var title: String = ""
    @State private var amount: Double = 0.0
    @State private var category: Category?
    
    var body: some View {
        NavigationStack{
            List{
                ForEach($groupedExpenses){ $group in
                    Section(group.groupTitle){
                        ForEach(group.expenses) { expense in
                            //Card View
                            ExpenseCardView(expense: expense)
                                .if(editMode == .active) { view in
                                    view.onTapGesture {
                                        requestedEditExpense = expense
                                        showEditSheet = true
                                    }
                                }
                                .onAppear(){
                                    if expense.hasFortyDaysPassed(){
                                        context.delete(expense)
                                        withAnimation{
                                            group.expenses.removeAll(where:{ $0.id == expense.id})
                                            if group.expenses.isEmpty{
                                                groupedExpenses.removeAll(where: { $0.id == group.id})
                                            }
                                        }
                                    }
                                }
                                .swipeActions(edge:.trailing, allowsFullSwipe: false){
                                    Button{
                                        context.delete(expense)
                                        withAnimation{
                                            group.expenses.removeAll(where:{ $0.id == expense.id})
                                            if group.expenses.isEmpty{
                                                groupedExpenses.removeAll(where: { $0.id == group.id})
                                            }
                                        }
                                    }label:{
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .overlay{
                if allExpenses.isEmpty || groupedExpenses.isEmpty{
                    ContentUnavailableView{
                        Label("No Expenses",systemImage: "tray.fill")
                    }
                }
            }
            .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                }
            }
            .environment(\.editMode, $editMode)
            .sheet(isPresented: $showEditSheet){
                NavigationStack{
                    List{
                        if let currentName = requestedEditExpense?.title{
                            Section("Title"){
                                TextField(currentName, text: $title)
                            }
                        }
                    
                        if let currentamount = requestedEditExpense?.amount{
                            Section("Amount"){
                                TextField(formatValue(currentamount), value: $amount, formatter: formatter)
                                    .keyboardType(.numberPad)
                            }
                        }
                        if !allCategories.isEmpty{
                            HStack{
                                Text("Budget")
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(allCategories) { categorys in
                                        Button(categorys.categoryName){
                                            self.category = categorys
                                            category = categorys
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
                    .navigationTitle("Edit Expense")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading){
                            Button("Cancel"){
                                showEditSheet = false
                            }
                            .tint(.red)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing){
                            Button("Save"){
                                requestedEditExpense?.title = title
                                requestedEditExpense?.amount = amount
                                requestedEditExpense?.category = category
                                amount = 0.0
                                title = ""
                                showEditSheet = false
                                
                            }
                            .disabled(title.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(350)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
                        
            //New Category Add Button
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        addExpense.toggle()
                    }label:{
                        Image(systemName:"plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .onChange(of: allExpenses, initial: true){ oldValue, newValue in
            if newValue.count > oldValue.count || groupedExpenses.isEmpty || currentTab == "Categories" || currentTab == "Savings"{
                createGroupedExpenses(newValue)
            }
        }
        .sheet(isPresented: $addExpense){
            AddExpenseView()
                .interactiveDismissDisabled()
        }
    }
    var formatter: NumberFormatter{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
    func formatValue(_ limit: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: limit)) ?? "\(limit)"
    }
    //Creating Grouped Expenses (Grouping By Date)
    func createGroupedExpenses(_ expenses: [Expense]){
        Task.detached(priority: .high){
            let groupedDict = Dictionary(grouping: expenses){expense in
                let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: expense.date)
                return dateComponents
            }
            
            //Sorting in Descending Order
            let sortedDict = groupedDict.sorted{
                let calendar = Calendar.current
                let date1 = calendar.date(from: $0.key) ?? .init()
                let date2 = calendar.date(from: $1.key) ?? .init()
                
                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }
            
            //Adding to the Grouped Expenses Array
            await MainActor.run{
                groupedExpenses = sortedDict.compactMap({ dict in
                    let date = Calendar.current.date(from: dict.key) ?? .init()
                    return .init(date: date, expenses: dict.value)
                })
            }
        }
    }
}


#Preview {
    ContentView()
}
