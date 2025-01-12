//
//  SettingsView.swift
//  University
//
//  Created by Ibrahim Abdullah on 14.12.24.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedColorScheme: ColorSchemeOption = .green
    @State private var selectedLightDarkOrSystem: LightDarkOrSystem = .system
    @State private var showSubscriptionSheet = false
    @State private var showProfileEdit = false
    @State private var showAchievementDetail = false
    @State private var showTipView = false
    @State private var showTasksFocusDetail = false
    @State private var showPremiumSheet = false
    @State private var focusNotificationsOn = true
    @State private var calendarNotificationsOn = false
    
    @Environment(\.colorScheme) var scheme
    
    enum ColorSchemeOption: String, CaseIterable, Identifiable {

        case green = "Green"
        case purple = "Purple"
        case pink = "Pink"
        
        var id: String { self.rawValue }
    }
    
    
    
    enum LightDarkOrSystem: String, CaseIterable, Identifiable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        
        var id: String { self.rawValue }
    }

    var body: some View {
        NavigationStack {
            Form {
                /*
                // SECTION: Premium Subscription
                Section(header: Text("Premium")) {
                    Button(action: {
                        showPremiumSheet = true
                    }) {
                        HStack(alignment: .center) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.white)
                               
                            Text("Go Pro")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            MeshGradient(width: 2, height: 2, points: [
                                [0, 0], [1, 0],
                                [0, 1], [1, 1]
                            ], colors: [
                                .accentColor, .cyan,
                                .purple, .pink
                            ])
                        )
                        .shadow(color: scheme == .dark ? Color.black.opacity(0.7) : Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                    .listRowInsets(EdgeInsets())
                }
                 */
                
                // SECTION: Appearance
                Section(header: Text("Appearance")) {
                    Picker("Apperance", systemImage: "paintpalette.fill", selection: $selectedLightDarkOrSystem) {
                        ForEach(LightDarkOrSystem.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Main Color", selection: $selectedColorScheme) {
                        ForEach(ColorSchemeOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // SECTION: Import Data
                Section(header: Text("Import Data")) {
                    Button(action: {
                        // Import Calendar logic
                    }) {
                        Label("Import from Calendar", systemImage: "calendar")
                    }
                    
                    Button(action: {
                        // Import Reminders logic
                    }) {
                        Label("Import from Reminders", systemImage: "list.bullet.rectangle")
                    }
                }
                
                // SECTION: Notifications
                Section(header: Text("Notifications")) {
                    Toggle("Focus Reminders", isOn: $focusNotificationsOn)
                    Toggle("Calendar Events", isOn: $calendarNotificationsOn)
                    
                    Text("Enable these to stay on track with your tasks and events.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                // SECTION: Support the Developer (Buy Me a Coffee)
                Section(header: Text("Support the Developer")) {
                    Button(action: {
                        showTipView = true
                    }) {
                        Label("Buy Me a Coffee", systemImage: "cup.and.saucer")
                    }
                }
                
                // SECTION: About & Support
                Section(header: Text("About & Support")) {
                    Button(action: { /* Report problem logic */ }) {
                        Label("Report a Problem", systemImage: "exclamationmark.triangle")
                    }
                    
                    Button(action: { /* View use policy logic */ }) {
                        Label("View Use Policy", systemImage: "doc.text")
                    }
                    
                    Button(action: { /* Share the app logic */ }) {
                        Label("Share the App", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        // Open App Store review link
                    }) {
                        Label("Leave a Review", systemImage: "star")
                    }
                    
                    Button(action: {
                        // Q&A section link
                    }) {
                        Label("Help Q&A", systemImage: "questionmark.circle")
                    }
                }
                
                // SECTION: What's New
                Section(header: Text("What's New")) {
                    Text("Version 1.1: Added new premium features and improved UI!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("About")) {
                    VStack(spacing: 4) {
                        Button(action: {
                            // Open Instagram profile
                            if let url = URL(string: "https://instagram.com/i8r4him") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("@i8r4him")
                                .font(.footnote)
                                .foregroundColor(scheme == .dark ? .green : .blue)
                            
                        }
                        
                        HStack(spacing: 5) {
                            Text("Made by Ibrahim with ❤️")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Text("Version 1.0")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 2)
                    }
                    .padding(.vertical, 8)
                    
                    
                }
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPremiumSheet) {
                PremiumView(showSubscriptionSheet: $showPremiumSheet)
                    .presentationDetents([.large]) // full screen
            }
            .sheet(isPresented: $showTipView) {
                TipView(showTipView: $showTipView)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showTasksFocusDetail) {
                DetailUsageView(showSheet: $showTasksFocusDetail)
                    .presentationDetents([.medium])
            }
            // Footer
            
        }
    }
}

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userName: String
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .font(.headline)
                .padding(.trailing)
            }
            
            Spacer()
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.green)
            }
            
            Text("What’s your name?")
                .font(.title3.weight(.semibold))
                .foregroundColor(.green)
                .padding(.top)
            
            TextField("Enter your name", text: $userName)
                .padding(.horizontal)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green, lineWidth: 1)
                )
                .padding(.horizontal)
            
            Button("Confirm") {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.black)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 20)
            
            Text("Your name is used to personalize your experience.")
                .foregroundColor(.gray)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct PremiumView: View {
    @Binding var showSubscriptionSheet: Bool
    
    @State private var selectedPlan: Plan = .yearly
    
    enum Plan: String, CaseIterable, Identifiable {
        case yearly = "Yearly Subscription"
        case monthly = "Monthly Subscription"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Unlock Pro Access")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Get access to all of our features and content.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                featureRow("Remove all ads")
                featureRow("Daily new content")
                featureRow("Priority Support")
                featureRow("Exclusive Tutorials")
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Plans
            VStack(spacing: 15) {
                planOption(.yearly, price: "9.99 $/year")
                planOption(.monthly, price: "1.99 $/month")
            }
            .padding(.horizontal)
            .padding(.top, 30)
            
            Button("Purchase") {
                // Implement purchase logic
                showSubscriptionSheet = false
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 30)
            
            Button("Restore Purchases") {
                // Restore logic
            }
            .font(.footnote)
            .padding(.bottom, 40)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
    }
    
    func featureRow(_ text: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .foregroundColor(.blue)
            Text(text)
                .fontWeight(.medium)
        }
    }
    
    func planOption(_ plan: Plan, price: String) -> some View {
        Button(action: {
            selectedPlan = plan
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.rawValue)
                        .fontWeight(.semibold)
                    Text("Get full access for \(price)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.blue)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedPlan == plan ? Color.blue : Color.gray, lineWidth: 1)
            )
        }
        .foregroundColor(.primary)
    }
}

struct TipView: View {
    @Binding var showTipView: Bool
    
    let tipOptions: [Double] = [0.99, 1.99, 5.99, 9.99]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Support the Developer")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("I really appreciate your support! Choose a tip amount:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ForEach(tipOptions, id: \.self) { tip in
                Button(action: {
                    // handle tip logic
                    showTipView = false
                }) {
                    Text("Tip \(String(format: "%.2f", tip)) $")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                .foregroundColor(.primary)
                .padding(.horizontal)
            }
            
            Button("Close") {
                showTipView = false
            }
            .font(.headline)
            .padding(.bottom, 20)
            
            Spacer()
        }
        .padding(.top, 20)
        .background(Color(UIColor.systemBackground))
    }
}

struct DetailUsageView: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Long-Term Achievements")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            Text("Earn special rewards when you accumulate more than 200 tasks or 1000 focus minutes! Keep pushing your productivity and unlock amazing perks.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Close") {
                showSheet = false
            }
            .font(.headline)
            .padding()
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    SettingsView()
}
