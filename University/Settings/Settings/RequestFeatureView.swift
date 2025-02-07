//
//  RequestFeatureView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah
//

import SwiftUI

struct RequestFeatureView: View {
    @State private var featureRequest = ""
    @Environment(\.dismiss) private var dismiss
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                    
                    Text("Have an idea?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("We'd love to hear your suggestions to make Notiva even better")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text("Feature Description")) {
                TextEditor(text: $featureRequest)
                    .frame(minHeight: 90)
            }
            
            Section {
                if showSuccess {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Thank you for your feedback!")
                                .foregroundColor(.green)
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Dismiss")
                                .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    Button(action: {
                        submitRequest()
                    }) {
                        HStack {
                            Text(showSuccess ? "Thank you!" : "Submit Request")
                                .frame(maxWidth: .infinity)
                            
                            if isSubmitting {
                                LoadingIndicator()
                                    .padding(.leading)
                            }
                        }
                    }
                    .disabled(featureRequest.isEmpty || isSubmitting || showSuccess)
                }
            }
            
            Section(header: Text("Other Ways to Contribute")) {
                Link(destination: URL(string: "https://twitter.com/i8r4him")!) {
                    Label("Suggest on Twitter", systemImage: "bubble.left.fill")
                }
            }
        }
        .navigationTitle("Request a Feature")
        .listStyle(.insetGrouped)
        .onChange(of: showSuccess) { oldValue, newValue in
            if newValue {
                // Dismiss the view after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            }
        }
    }
    
    private func submitRequest() {
        guard !featureRequest.isEmpty else { return }
        
        isSubmitting = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // TODO: Implement actual feature request submission
            isSubmitting = false
            withAnimation {
                showSuccess = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        RequestFeatureView()
    }
}
