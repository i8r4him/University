//
//  AppearanceView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah on 31.12.24.
//

import SwiftUI

struct AppearanceView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            // Add header section with icon
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)
                        .shadow(radius: 2)
                    
                    Text("Customize Look & Feel")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("Make Notiva truly yours with custom themes and colors")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text("Display Mode")) {
                Picker("Mode",systemImage: "paintpalette.fill", selection: $viewModel.selectedLightDarkOrSystem) {
                    ForEach(LightDarkOrSystem.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }
            
            Section(header: Text("Main Color")) {
                Picker("Main Color",systemImage: "pencil.and.outline", selection: $viewModel.selectedColorScheme) {
                    ForEach(ColorSchemeOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }
            
            Section(header: Text("Icon appearance")) {
                NavigationLink(destination: Text("icon")) {
                    Label("Icon", systemImage: "square.dashed")
                }
            }
        }
        .navigationTitle("Appearance")
        .environment(\.symbolRenderingMode, .hierarchical)
    }
}

#Preview {
    AppearanceView(viewModel: SettingsViewModel())
}
