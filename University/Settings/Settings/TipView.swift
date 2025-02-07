//
//  TipView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah on 31.12.24.
//

import SwiftUI

struct TipView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TipViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Thank you section
                    VStack(spacing: 20) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.red)
                            .symbolEffect(.bounce)
                            .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 10)
                        
                        Text("Thank You!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Your support means the world to us and helps us continue building amazing features for you.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Tips Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(viewModel.tipOptions) { option in
                            makeTipButton(for: option)
                                .aspectRatio(1.0, contentMode: .fill)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Support Notiva")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Helper function to create consistent tip buttons
    private func makeTipButton(for option: TipOption) -> some View {
        Button(action: {
            viewModel.handleTipSelection(amount: option.amount) // TODO: Connect to tip logic
            dismiss()
        }) {
            VStack(spacing: 12) {
                Circle()
                    .fill(option.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: option.title == "Little Tip" ? "heart.fill" :
                                        option.title == "Small Tip" ? "star.fill" :
                                        option.title == "Medium Tip" ? "sparkles" :
                                        "crown.fill")
                            .font(.title2)
                            .foregroundStyle(option.color)
                    }
                
                Text(option.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(viewModel.currencyFormatter.string(from: NSNumber(value: option.amount)) ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(option.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(option.color.opacity(0.3), lineWidth: 4)
            )
        }
    }
}

#Preview {
    TipView()
}
