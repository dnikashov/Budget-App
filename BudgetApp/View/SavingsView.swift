//
//  SavingsView.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-20.
//

import SwiftUI
import SwiftData


struct SavingsView: View {
    @Query (animation: .snappy) private var allSavings: [Savings]
    @Environment(\.modelContext) private var context
    
    @State private var addSavings: Bool = false
    @State private var savingsName: String = ""
    @State private var amount: Double = 0
    @State private var requestedEditSavings: Savings?
    @State private var deleteRequest: Bool = false
    @State private var requestedSavings: Savings?
    @State private var showEditSheet = false
    @State private var editMode = EditMode.inactive


    
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(allSavings.sorted(by: {
                    ($0.category?.count ?? 0) > ($1.category?.count ?? 0)
                })){ saving in
                    DisclosureGroup{
                        if let categories = saving.category, !categories.isEmpty{
                            ForEach (categories.sorted(by: { $0.date > $1.date })) { category in
                                CategoriesCardView(category: category, displayTag: false)
                            }
                        } else {
                            ContentUnavailableView{
                                Label("No Savings", systemImage: "tray.fill")
                            }
                        }
                    }label: {
                        HStack {
                            Text(saving.savingsName)
                                .font(.system(size: 24, weight: .bold))
                            Spacer()
                            let balance = findSavingsAmount(saving)
                            Text("$" + formatValue(balance))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(balance < 0 ? .red : .green)
                                .bold()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false){
                            Button{
                                deleteRequest.toggle()
                                requestedSavings = saving
                            }label:{
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                    }
                    .if(editMode == .active) { view in
                                            view.onTapGesture {
                                                requestedEditSavings = saving
                                                showEditSheet = true
                                            }
                                        }
                }
            }
            .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Savings")
            .overlay{
                if allSavings.isEmpty{
                    ContentUnavailableView{
                        Label("No Savings", systemImage: "tray.fill")
                    }
                }
            }
            .sheet(isPresented: $showEditSheet){
                NavigationStack{
                    List{
                        if let currentName = requestedEditSavings?.savingsName{
                            Section("Title"){
                                TextField(currentName, text: $savingsName)
                            }
                        }
                        Section("Amount"){
                            TextField("0.0", value: $amount, formatter: formatter)
                                .keyboardType(.numberPad)
                        }
                    }
                    .navigationTitle("Edit Savings")
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
                                requestedEditSavings?.savingsName = savingsName
                                requestedEditSavings?.amount = amount
                                if let categories = requestedEditSavings?.category {
                                    for category in categories {
                                        print(category.categoryName)
                                    }
                                } 
                                amount = 0.0
                                savingsName = ""
                                showEditSheet = false
                                
                            }
                            .disabled(savingsName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(270)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
            .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                    Button{
                        addSavings.toggle()
                    }label:{
                        Image(systemName:"plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $addSavings){
                savingsName = ""
                amount = 0
            } content: {
                NavigationStack{
                    List{
                        Section("Title"){
                            TextField("New Savings", text: $savingsName)
                        }
                    }
                    .navigationTitle("Savings Name")
                    .navigationBarTitleDisplayMode(.inline)
                    //Add and Cancel button
                    .toolbar{
                        ToolbarItem(placement: .topBarLeading){
                            Button("Cancel"){
                                addSavings = false
                            }
                            .tint(.red)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing){
                            Button("Add"){
                                
                                let saving = Savings(savingsName: savingsName, amount: 0)
                                context.insert(saving)
                                //Closing View
                                savingsName = ""
                                amount = 0
                                addSavings = false
                            }
                            .disabled(savingsName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(270)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
        }
        .alert("If you delete the Savings, It can't be recovered", isPresented: $deleteRequest) {
            Button(role: .destructive){
                if let requestedSavings{
                    context.delete(requestedSavings)
                    self.requestedSavings = nil
                }
            }label:{
                Text("Delete")
            }
            
            Button(role:.cancel){
                requestedSavings = nil
            } label: {
                Text("Cancel")
            }
        }
    }
    
    func findSavingsAmount(_ savings: Savings) -> Double {
        var totalCategories = 0.0
        if let categories = savings.category, !categories.isEmpty {
            for category in categories {
                if category.isDone{
                    totalCategories += category.totalAmount
                } else {
                    totalCategories += category.leftover
                }
            }
        }
        return totalCategories
    }
    
    func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    var formatter: NumberFormatter{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
    func setSavingsView (_ savings: Savings){
        
    }
}

#Preview {
    SavingsView()
}
