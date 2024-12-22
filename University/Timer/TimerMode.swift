import Foundation


enum TimerMode {
    case none
    case pomodoro
    case breakTime
    case stopwatch
}

enum SessionType {
    case focus
    case `break`
}


struct CompletedSession: Identifiable {
    let id = UUID()
    let type: SessionType
    let duration: Int // in seconds
    let date: Date
}
