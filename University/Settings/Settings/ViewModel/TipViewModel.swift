//
//  TipViewModel.swift
//  Notiva
//
//  Created by Ibrahim Abdullah on 31.12.24.
//

import SwiftUI

class TipViewModel: ObservableObject {
    let tipOptions: [TipOption] = [
        TipOption(title: "Little Tip", amount: 0.99, color: .blue),
        TipOption(title: "Small Tip", amount: 1.99, color: .purple),
        TipOption(title: "Medium Tip", amount: 5.99, color: .green),
        TipOption(title: "Large Tip", amount: 9.99, color: .orange)
    ]

    // Currency Formatter
    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }

    // TODO: Add logic for handling tips (e.g., in-app purchases)
    func handleTipSelection(amount: Double) {
        // Handle the tip logic here
    }
}
