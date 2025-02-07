//
//  DateTimeView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah
//

import SwiftUI

struct DateTimeView: View {
    @State private var timeFormat = TimeFormat.twelveHour
    @State private var weekStart = WeekStart.sunday
    
    enum TimeFormat: String, CaseIterable {
        case twelveHour = "12-hour"
        case twentyFourHour = "24-hour"
    }
    
    enum WeekStart: String, CaseIterable {
        case sunday = "Sunday"
        case monday = "Monday"
        case saturday = "Saturday"
    }
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                        .padding(.top, 20)
                    
                    Text("Date & Time")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("Customize how dates and times are displayed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text("Time Format")) {
                Picker("Time Format", selection: $timeFormat) {
                    ForEach(TimeFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                
                if timeFormat == .twelveHour {
                    Text("Example: 2:30 PM")
                        .foregroundColor(.secondary)
                } else {
                    Text("Example: 14:30")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Week Starts On")) {
                Picker("First Day of Week", selection: $weekStart) {
                    ForEach(WeekStart.allCases, id: \.self) { day in
                        Text(day.rawValue).tag(day)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        }
        .navigationTitle("Date & Time")
        .listStyle(.insetGrouped)
    }
}

#Preview {
    NavigationStack {
        DateTimeView()
    }
}

