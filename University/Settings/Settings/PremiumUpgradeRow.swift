//
//  PremiumUpgradeRow.swift
//  Notiva
//
//  Created by Ibrahim Abdullah on 31.12.24.
//

import SwiftUI

struct PremiumUpgradeRow: View {
    var upgradeAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                Text("Upgrade to Premium")
                    .font(.subheadline).bold()
            
                Text("Calendar view and more features.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()

            Button("Upgrade") {
                upgradeAction() // Execute the upgrade action
            }
            .buttonStyle(.borderedProminent)
            .tint(.yellow)
            .foregroundColor(.black)
            .controlSize(.small)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    PremiumUpgradeRow {
        print("Upgrade tapped")
    }
}
