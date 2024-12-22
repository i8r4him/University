//
//  SettingsFormView.swift
//  University
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import SwiftUI

struct SettingsFormView: View {
    
    @Binding var isPresented: Bool
    @Binding var major: String
    @Binding var targetCredits: Int
    
    @State private var targetCreditsString: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Major")) {
                    TextField("Major's name", text: $major)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Required Credits")) {
                    TextField("Total credits required to graduate", text: $targetCreditsString)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Major and Credits")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    if let credits = Int(targetCreditsString), credits > 0 {
                        targetCredits = credits
                        isPresented = false
                    }
                }
                .disabled(!isFormValid())
            )
            .onAppear {
                if targetCredits > 0 {
                    targetCreditsString = String(targetCredits)
                }
            }
        }
    }
    
    private func isFormValid() -> Bool {
        guard !major.isEmpty,
              let credits = Int(targetCreditsString),
              credits > 0 else {
            return false
        }
        return true
    }
}
#Preview {
    SettingsFormView(isPresented: .constant(true), major: .constant(""), targetCredits: .constant(0))
}
