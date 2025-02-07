//
//  OnboardingView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah on 31.12.24.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: 40) {
                        Image("AppIcon") // Replace with your app icon
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(20)
                            .padding(.top, 40)
                        
                        Text("Welcome to Notiva")
                            .font(.largeTitle)
                            .bold()
                        
                        Group {
                            if horizontalSizeClass == .regular {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 40) {
                                    featureRows
                                }
                            } else {
                                VStack(spacing: 30) {
                                    featureRows
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Button {
                            hasCompletedOnboarding = true
                            dismiss()
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                        .padding(.vertical, 40)
                    }
                    .frame(maxWidth: horizontalSizeClass == .regular ? 800 : nil)
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var featureRows: some View {
        Group {
            FeatureRow(
                image: "timer",
                title: "Focus Mode",
                description: "Stay productive with our focus timer and task management features",
                tintColor: .blue
            )
            
            FeatureRow(
                image: "calendar.badge.clock",
                title: "Calendar",
                description: "Keep track of your schedule and never miss important deadlines",
                tintColor: .orange
            )
            
            FeatureRow(
                image: "chart.bar.xaxis",
                title: "Progress Tracking",
                description: "Monitor your productivity and achievements over time",
                tintColor: .green
            )
        }
    }
}

struct FeatureRow: View {
    let image: String
    let title: String
    let description: String
    let tintColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: image)
                .font(.system(size: 35))
                .foregroundColor(tintColor)
                .frame(width: 40)
                .symbolRenderingMode(.hierarchical)
                .alignmentGuide(.leading) { d in d[.leading] }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    OnboardingView()
}
