// New file: WeekView.swift
import SwiftUI

struct WeekView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let startOfWeek: Date
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        GeometryReader { geometry in
            let cal = Calendar.current
            let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
            let totalWidth = geometry.size.width
            let dayWidth = (totalWidth - 40) / 7
            
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    let isSelected = cal.isDate(viewModel.selectedDate, inSameDayAs: day)
                    SelectedDayView(viewModel: viewModel, date: day, isSelected: isSelected)
                        .frame(width: dayWidth, height: dayWidth)
                        .onTapGesture {
                            impactFeedback.impactOccurred()
                            withAnimation {
                                viewModel.selectedDate = day
                            }
                        }
                }
            }
            .frame(width: totalWidth - 40)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}

// MARK: - Preview
#Preview {
    WeekView(
        viewModel: CalendarViewModel(),
        startOfWeek: Date()
    )
}
