//
//  HelpAndFeedbackView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah
//

import SwiftUI

struct HelpAndFeedbackView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.red)
                    
                    Text("How can we help you?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("Get help with Notiva or send us your feedback")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section(header: Text("Help Center")) {
                Link(destination: URL(string: "https://your-website.com/faq")!) {
                    Label("Frequently Asked Questions", systemImage: "questionmark.circle.fill")
                }
                Link(destination: URL(string: "https://your-website.com/docs")!) {
                    Label("Documentation", systemImage: "document.on.clipboard.fill")
                }
            }
            
            Section(header: Text("Contact Us")) {
                Link(destination: URL(string: "mailto:support@your-email.com")!) {
                    Label("Email Support", systemImage: "envelope.badge.fill")
                }
                Link(destination: URL(string: "https://twitter.com/i8r4him")!) {
                    Label("Twitter Support", systemImage: "exclamationmark.bubble.fill")
                }
            }
            
            Section(header: Text("Feedback")) {
                Link(destination: URL(string: "https://your-website.com/feedback")!) {
                    Label("Submit Feedback", systemImage: "quote.bubble")
                }
                Link(destination: URL(string: "https://apps.apple.com/app/id<your-app-id>")!) {
                    Label("Rate on App Store", systemImage: "star.fill")
                }
            }
        }
        .symbolRenderingMode(.hierarchical)
        .navigationTitle("Help & Feedback")
        .listStyle(.insetGrouped)
    }
}

#Preview {
    NavigationStack {
        HelpAndFeedbackView()
    }
}

