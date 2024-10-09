//
//  Extension.swift
//  BudgetApp
//
//  Created by Natalia Nikashova on 2024-10-03.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
