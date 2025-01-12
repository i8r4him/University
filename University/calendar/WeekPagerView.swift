// New file: WeekPagerView.swift
import SwiftUI

struct WeekPagerView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedWeekIndex: Int
    let weeks: [Date]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        TabView(selection: $selectedWeekIndex) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { index, startOfWeek in
                WeekView(viewModel: viewModel, startOfWeek: startOfWeek)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: horizontalSizeClass == .compact ? 100 : 170)
        .onChange(of: selectedWeekIndex) { oldIndex, newIndex in
            if weeks.indices.contains(newIndex) {
                let calendar = Calendar.current
                let oldWeekStart = weeks[oldIndex]
                let newWeekStart = weeks[newIndex]
                
                // Calculate days difference between weeks
                let weeksDiff = calendar.dateComponents([.weekOfYear], 
                    from: oldWeekStart, 
                    to: newWeekStart).weekOfYear ?? 0
                
                // Apply the same difference to the selected date
                if let newDate = calendar.date(byAdding: .weekOfYear, 
                    value: weeksDiff, 
                    to: viewModel.selectedDate) {
                    viewModel.selectedDate = newDate
                    viewModel.currentWeekStart = newWeekStart
                }
            }
        }
    }
}

// MARK: - Preview
struct WeekPagerView_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample data
        let viewModel = CalendarViewModel()
        let baseDate = Calendar.current.startOfWeek(for: Date()) ?? Date()
        let weeks = (-2...2).compactMap { offset in
            Calendar.current.date(byAdding: .weekOfYear, value: offset, to: baseDate)
        }
        
        // Preview with StateObject for binding
        WeekPagerPreview(weeks: weeks)
    }
}

// Preview helper view
private struct WeekPagerPreview: View {
    let weeks: [Date]
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedIndex = 2
    
    var body: some View {
        WeekPagerView(
            viewModel: viewModel,
            selectedWeekIndex: $selectedIndex,
            weeks: weeks
        )
    }
}
