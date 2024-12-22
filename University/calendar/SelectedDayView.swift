//
//  SelectedDayView.swift
//  University
//
//  Created by Ibrahim Abdullah on 17.12.24.
//

// SelectedDayView.swift
import SwiftUI

struct SelectedDayView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var date: Date
    var isSelected: Bool
    
    private var dayNumber: String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
    
    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isSelected ? .primary : .gray.opacity(0.5))
            
            Text(weekdayString)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .red : .secondary)
        }
        .frame(width: 50, height: 70)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(weekdayString), \(dayNumber)")
    }
}

#Preview {
    SelectedDayView(viewModel: CalendarViewModel(), date: Date(), isSelected: true)
}
