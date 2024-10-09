//
//  CategoryView.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-15.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query (animation: .snappy) private var allCategories: [Category]
    @Environment(\.modelContext) private var context
    @Query (animation: .snappy) private var allSavings: [Savings]
    
    @State private var addCategory: Bool = false
    @State private var categoryName: String = ""
    @State private var limit: Double = 0
    @State private var deleteRequest: Bool = false
    @State private var requestedCategory: Category?
    @State private var date: Date = Date()
    @State private var savings: Savings?
    @State private var requestedEditCategories: Category?
    @State private var editMode = EditMode.inactive
    @State private var showEditSheet = false
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(allCategories
                    .filter { !$0.isDone }
                    .sorted(by: {($0.expenses?.count ?? 0) > ($1.expenses?.count ?? 0)
                })){ category in
                    DisclosureGroup{
                        if let expenses = category.expenses, !expenses.isEmpty{
                            ForEach (expenses) { expense in
                                ExpenseCardView(expense: expense, displayTag: false)
                            }
                        } else {
                            ContentUnavailableView{
                                Label("No Expenses", systemImage: "tray.fill")
                            }
                        }
                    }label:{
                        CategoriesCardView(category: category, displayTag: true)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false){
                                Button{
                                    deleteRequest.toggle()
                                    requestedCategory = category
                                }label:{
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                    }
                    .if(editMode == .active) { view in
                        view.onTapGesture {
                            requestedEditCategories = category
                            showEditSheet = true
                        }
                    }
                                    }
            }
            .navigationTitle("Categories")
            .onAppear {
                // Check the month change for all categories when the view appears
                for category in allCategories where !category.isDone {
                    if category.checkMonthChange(){
                        category.duplicateCategory(context: context)
                    }
                        
                }
            }
            .overlay{
                if allCategories.isEmpty || allCategories.allSatisfy({ $0.isDone }) {
                    ContentUnavailableView{
                        Label("No Categories", systemImage: "tray.fill")
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
                        if let currentName = requestedEditCategories?.categoryName{
                            Section("Title"){
                                TextField(currentName, text: $categoryName)
                            }
                        }
                        if let currentLimit = requestedEditCategories?.limit{
                            Section("Limit"){
                                TextField(formatValue(currentLimit), value: $limit, formatter: formatter)
                                    .keyboardType(.numberPad)
                            }
                        }
                        if !allSavings.isEmpty{
                            HStack{
                                Text("Savings")
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(allSavings) { saving in
                                        Button(saving.savingsName){
                                            self.savings = saving
                                            savings = saving
                                        }
                                    }
                                    Button("None"){
                                        savings = nil
                                    }
                                }label:{
                                    if let savingsName = savings?.savingsName {
                                        Text(savingsName)
                                    } else {
                                        Text("None")
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Edit Budget")
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
                                requestedEditCategories?.categoryName = categoryName
                                requestedEditCategories?.limit = limit
                                requestedEditCategories?.savings = savings
                                limit = 0.0
                                categoryName = ""
                                showEditSheet = false
                                
                            }
                            .disabled(categoryName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(350)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
            //Add Category
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        addCategory.toggle()
                    }label:{
                        Image(systemName:"plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $addCategory){
                categoryName = ""
                limit = 0
            } content: {
                NavigationStack{
                    List{
                        Section("Title"){
                            TextField("New Budget Name", text: $categoryName)
                        }
                        Section("Budget"){
                            TextField("0.0", value: $limit, formatter: formatter)
                                .keyboardType(.numberPad)
                        }
                        if !allSavings.isEmpty{
                            HStack{
                                Text("Savings")
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(allSavings) { saving in
                                        Button(saving.savingsName){
                                            self.savings = saving
                                            savings = saving
                                        }
                                    }
                                    Button("None"){
                                        savings = nil
                                    }
                                }label:{
                                    if let savingsName = savings?.savingsName {
                                        Text(savingsName)
                                    } else {
                                        Text("None")
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Add Budget")
                    .navigationBarTitleDisplayMode(.inline)
                    //Add and Cancel button
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading){
                            Button("Cancel"){
                                addCategory = false
                            }
                            .tint(.red)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing){
                            Button("Add"){
                                date = Date()
                                let category = Category(categoryName: categoryName, limit: limit, date: date, savings: savings)
                                savings?.addCategory(category)
                                context.insert(category)
                                try? context.save()
                                //Closing View
                                categoryName = ""
                                limit = 0
                                addCategory = false
                            }
                            .disabled(categoryName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(350)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
        }
        .alert("If you delete the category, all assosciated expenses will be deleted", isPresented: $deleteRequest) {
            Button(role: .destructive){
                if let requestedCategory{
                    context.delete(requestedCategory)
                    self.requestedCategory = nil
                }
            }label:{
                Text("Delete")
            }
            
            Button(role:.cancel){
                requestedCategory = nil
            } label: {
                Text("Cancel")
            }
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
            
}

#Preview {
    CategoriesView()
}
