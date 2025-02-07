//
//  PremiumUpgradeView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah
//

import SwiftUI

struct PremiumUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.yellow)
                        .padding(.top, 40)
                    
                    Text("Upgrade to Premium")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Unlock all features and get the most out of Notiva")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Features List
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow2(icon: "infinity", color: .blue, title: "Unlimited Notes", description: "Create as many notes as you want")
                    FeatureRow2(icon: "paintpalette.fill", color: .purple, title: "Custom Themes", description: "Personalize your app appearance")
                    FeatureRow2(icon: "icloud.fill", color: .cyan, title: "Cloud Sync", description: "Sync across all your devices")
                    FeatureRow2(icon: "chart.bar.fill", color: .orange, title: "Advanced Analytics", description: "Detailed insights and statistics")
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // Pricing
                VStack(spacing: 8) {
                    Text("$4.99")
                        .font(.system(size: 40, weight: .bold))
                    Text("per month")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Upgrade Button
                Button(action: handleUpgrade) {
                    HStack {
                        if isLoading {
                            LoadingIndicator()
                                .padding(.trailing, 8)
                        }
                        Text(isLoading ? "Processing..." : "Upgrade Now")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(isLoading)
                
                // Terms
                Text("Recurring billing, cancel anytime")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleUpgrade() {
        isLoading = true
        // TODO: Implement in-app purchase logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            dismiss()
        }
    }
}

struct FeatureRow2: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PremiumUpgradeView()
    }
}

