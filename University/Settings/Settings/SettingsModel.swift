//
//  SettingsModel.swift
//  Notiva
//
//  Created by Ibrahim Abdullah on 31.12.24.
//

import SwiftUI

// Enums for Color Scheme and Display Mode
enum ColorSchemeOption: String, CaseIterable, Identifiable {
    case green = "Green"
    case purple = "Purple"
    case pink   = "Pink"
    
    var id: String { self.rawValue }
}

enum LightDarkOrSystem: String, CaseIterable, Identifiable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"
    
    var id: String { self.rawValue }
}

// Tip Option Model
struct TipOption: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let color: Color
}
