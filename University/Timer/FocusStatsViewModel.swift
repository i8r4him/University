import SwiftUI

class FocusStatsViewModel: ObservableObject {
    @Published var sessions: [CompletedSession] = []
    
    enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    @Published var selectedPeriod: Period = .week
    
    // Computed properties based on selected period
    var filteredSessions: [CompletedSession] {
        let now = Date()
        switch selectedPeriod {
        case .week:
            // Last 7 days including today
            return sessions.filter { $0.date > now.addingTimeInterval(-7*24*60*60) }
        case .month:
            // Last 30 days
            return sessions.filter { $0.date > now.addingTimeInterval(-30*24*60*60) }
        case .year:
            // Last 365 days
            return sessions.filter { $0.date > now.addingTimeInterval(-365*24*60*60) }
        }
    }
    
    // Totals
    var totalFocus: Int {
        filteredSessions.filter { $0.type == .focus }.reduce(0) { $0 + $1.duration }
    }
    var totalBreak: Int {
        filteredSessions.filter { $0.type == .break }.reduce(0) { $0 + $1.duration }
    }
    
    // Averages per day
    var averageFocusPerDay: Int {
        let days = daysInPeriod()
        return days > 0 ? totalFocus / days : 0
    }
    var averageBreakPerDay: Int {
        let days = daysInPeriod()
        return days > 0 ? totalBreak / days : 0
    }
    
    func addSession(_ type: SessionType, duration: Int) {
        sessions.append(CompletedSession(type: type, duration: duration, date: Date()))
    }
    
    private func daysInPeriod() -> Int {
        switch selectedPeriod {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}
