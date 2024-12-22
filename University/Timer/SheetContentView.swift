//
//  SheetContentView.swift
//  University
//
//  Created by Ibrahim Abdullah on 15.12.24.
//

// SheetContentView.swift

import SwiftUI

struct SheetContentView: View {
    @Binding var selectedDuration: Double  // Binding to totalTime in seconds
    var resetTimer: () -> Void  // Function to reset the timer

    @State private var customMinutes = 25  // Custom picker value (default 25 minutes)

    let presetDurations = [15, 25, 30, 45, 60]  // Preset timer options in minutes
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var showSheet: Bool


    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            // Preset Timer Options with ScrollView
            VStack(spacing: 15) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(presetDurations, id: \.self) { duration in
                            Button(action: {
                                selectedDuration = Double(duration * 60)
                                resetTimer()
                                dismiss()
                            }) {
                                Text("\(duration):00")
                                    .font(.system(size: 18, weight: .bold))
                                    .frame(width: 80, height: 40)
                                    .background(Color.accentColor.opacity(0.2))
                                    .foregroundColor(Color.accentColor)
                                    .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Custom Picker for Minutes
            HStack {
                Text("Custom Duration")
                    .font(.headline)

                Picker("Minutes", selection: $customMinutes) {
                    ForEach(Array(stride(from: 5, through: 120, by: 5)), id: \.self) { minute in
                        Text("\(minute) min").tag(minute)
                    }
                }
                .pickerStyle(.automatic)
                .frame(height: 120)
                .onChange(of: customMinutes) { oldValue, newValue in
                    selectedDuration = Double(newValue * 60)
                    resetTimer()
                }
            }
            
            // Button to Set Timer
            Button(action: {
                selectedDuration = Double(customMinutes * 60)  // Set custom duration
                resetTimer()
                dismiss()  // Dismiss the sheet
            }) {
                Label {
                    Text("Set Timer")
                        .font(.system(size: 18, weight: .bold))
                } icon: {
                    Image(systemName: "timer") // SF Symbol for timer
                        .font(.system(size: 20))
                }
                .frame(maxWidth: 300, maxHeight: 30)
                .padding()
                .background(Color.accentColor.opacity(0.2))
                .foregroundStyle(Color.accentColor)
                .cornerRadius(15)
            }
        }
    }
}

struct SheetContentView_Previews: PreviewProvider {
    static var previews: some View {
        SheetContentView(selectedDuration: .constant(1500), resetTimer: {}, showSheet: .constant(true))
    }
}
