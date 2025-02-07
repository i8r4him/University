//
//  SettingsViewModel.swift
//  Notiva
//
//  Created by Ibrahim Abdullah on 31.12.24.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var showTipView = false
    @Published var selectedColorScheme: ColorSchemeOption = .green
    @Published var selectedLightDarkOrSystem: LightDarkOrSystem = .system

    // TODO: Add logic for handling premium upgrade actions
    func handlePremiumUpgrade() {
        // Premium upgrade action here
    }
    
    // TODO: Add logic for importing & integrating data
    func handleImportIntegration() {
        // Import integration logic
    }
}
