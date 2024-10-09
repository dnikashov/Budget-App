//
//  CategoriesCardView.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-09-24.
//

import SwiftUI
import SwiftData

struct CategoriesCardView: View {
    @Bindable var category: Category
    var displayTag: Bool = true
    @State private var deleteRequest: Bool = false
    @State private var requestedCategory: Category?
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        
        if displayTag {
            HStack{
                VStack(alignment: .leading){
                    Text(category.categoryName)
                        .font(.system(size: 24, weight: .bold))
                    HStack{
                        if let savingsName = category.savings?.savingsName, displayTag {
                            Text (savingsName)
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.green.gradient, in: .capsule)
                        Text("$" + formatValue(category.limit))
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        }
                    }
                }
                Spacer()
                Text("$" + formatValue(category.leftover))
                    .font(.title3.bold())
                    .foregroundColor(category.leftover < 0 ? .red : .green)
                    .bold()
            }
        } else if(category.isDone){
            HStack{
                VStack(alignment:.leading){
                    
                    Text(category.categoryName)
                    
                    Text(findMonth(category.date))
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                .lineLimit(1)
                Spacer(minLength: 5)
                
                Text("$" + formatValue(category.totalAmount))
                    .font(.title3.bold())
                    .foregroundColor(category.totalAmount < 0 ? .red : .green)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false){
                Button{
                    deleteRequest.toggle()
                    requestedCategory = category
                }label:{
                    Image(systemName: "trash")
                }
                .tint(.purple)
            }
            .alert("Do you want to delete this Category?", isPresented: $deleteRequest) {
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
        } else {
            HStack{
                VStack(alignment:.leading){
                    
                    Text(category.categoryName)
                    
                    Text(findMonth(category.date))
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                .lineLimit(1)
                Spacer(minLength: 5)
                
                Text("$" + formatValue(category.leftover))
                    .font(.title3.bold())
                    .foregroundColor(category.leftover < 0 ? .red : .green)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false){
                Button{
                    deleteRequest.toggle()
                    requestedCategory = category
                }label:{
                    Image(systemName: "trash")
                }
                .tint(.purple)
            }
            .alert("Do you want to delete this Budget?", isPresented: $deleteRequest) {
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
        
    }
    
    
    
    func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    func findMonth(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
}
