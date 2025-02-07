//
//  SettingsView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah on 30.12.24.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingUserProfile = false
    @State private var showingOnboarding = false

    var body: some View {
        NavigationStack {
            Form {
                /*
                Section(header: Text("Premium")) {
                        NavigationLink(destination: PremiumUpgradeView()) {
                            Label {
                                Text("Upgrade to Premium")
                                    .foregroundColor(.primary)
                            } icon: {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                 */
                
                /*
                // In App Purchases
                Section(header: Text("In-App Purchases")) {
                    NavigationLink(destination: Text("In-App Purchases")) {
                        Label("Your subscriptions", systemImage: "bag.fill.badge.plus")
                    }
                    
                    NavigationLink(destination: Text("Manage Subscriptions")) {
                        Label("Customer Center", systemImage: "person.2.fill")
                    }
                }
                 */

                // User Preferences
                Section(header: Text("User Preferences")) {
                    NavigationLink(destination: AppearanceView(viewModel: viewModel)) {
                        Label("Appearance", systemImage: "paintpalette.fill")
                    }
                    NavigationLink(destination: SoundsNotificationView()) {
                        Label("Sounds & Notifications", systemImage: "bell.badge.fill")
                    }
                    /*
                     
                     
                    NavigationLink(destination: DateTimeView()) {
                        Label("Date & Time", systemImage: "calendar.badge.clock")
                    }
                    
                    
                    NavigationLink(destination: Text("General")) {
                        Label("General", systemImage: "slider.horizontal.below.square.and.square.filled")
                    }
                    
                    
                    NavigationLink(destination: CloudBackupView()) {
                        Label("Cloud & Backup", systemImage: "externaldrive.fill.badge.icloud")
                    }
                    
                    */
                }
                
                /*

                // Integration
                Section(header: Text("Integration")) {
                    NavigationLink(destination: ImportIntegrationView()) {
                        Label("Import & Integration", systemImage: "arrow.triangle.merge")
                    }
                }
                
                */

                // Help & Feedback
                Section(header: Text("Help & Support")) {
                    NavigationLink(destination: RequestFeatureView()) {
                        Label("Request a Feature", systemImage: "exclamationmark.bubble.fill")
                    }
                    NavigationLink(destination: HelpAndFeedbackView()) {
                        Label("Help & Feedback", systemImage: "questionmark.bubble.fill")
                    }
                }

                // What's New & Share
                Section(header: Text("Notiva")) {
                    NavigationLink(destination: WhatsNewView()) {
                        Label("What's New", systemImage: "text.badge.star")
                    }
                    
                    Button(action: {
                        // TODO: Share Notiva app logic here
                    }) {
                        Label("Share Notiva App", systemImage: "square.and.arrow.up.fill")
                    }
                }

                // Support the Developer
                Section(header: Text("Support the Developer")) {
                    Button(action: {
                        viewModel.showTipView = true
                    }) {
                        Label("Buy Me a Coffee", systemImage: "cup.and.heat.waves.fill")
                    }
                }

                // Footer Section
                Section {
                    VStack(spacing: 8) {
                        Text("Made with ❤️ by Ibrahim")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Text("Version 1.0.0")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Link("@i8r4him", destination: URL(string: "https://twitter.com/i8r4him")!)
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
            .environment(\.symbolRenderingMode, .hierarchical)
            .sheet(isPresented: $viewModel.showTipView) {
                TipView()
                    .presentationDetents([.medium])
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct OnboardingUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    let completion: (String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Welcome to Notiva!")) {
                    TextField("Your Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Set Up Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        if !name.isEmpty {
                            completion(name)
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
