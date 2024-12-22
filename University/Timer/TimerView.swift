import SwiftUI
import Combine

struct TimerView: View {
    enum FocusMode: String, CaseIterable {
        case pomodoro = "Pomodoro"
        case `break` = "Break"
        case stopwatch = "Stopwatch"
        
        var icon: String {
            switch self {
            case .pomodoro: return "timer"
            case .break: return "cup.and.saucer.fill"
            case .stopwatch: return "stopwatch.fill"
            }
        }
    }
    
    @StateObject private var stopwatchManager = StopwatchManager()
    @StateObject private var statsVM = FocusStatsViewModel()
    
    @State private var currentMode: TimerMode = .none
    
    // Pomodoro state
    @State private var elapsedTime: Double = 0
    @State private var totalTime: Double = 25 * 60
    @State private var isRunning: Bool = false
    @State private var timerSubscription: AnyCancellable?
    
    // Break state
    @State private var breakElapsed: Double = 0
    @State private var breakTotal: Double = 5 * 60
    @State private var isBreakRunning: Bool = false
    @State private var breakSubscription: AnyCancellable?
    @State private var showBreakDurationPicker = false
    
    @State private var selectedMode: FocusMode = .pomodoro
    @State private var showSheet = false
    @State private var showDurationChangeAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Focus Mode", selection: $selectedMode) {
                    ForEach(FocusMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedMode) {oldValue, newValue in
                    handleModeChange(to: newValue)
                }
                
                Spacer()
                
                Group {
                    switch selectedMode {
                    case .pomodoro:
                        PomodoroView(
                            elapsedTime: $elapsedTime,
                            totalTime: $totalTime,
                            isRunning: $isRunning,
                            startTimer: pomodoroStartTimer,
                            resetTimer: pomodoroResetTimer,
                            pauseTimer: pomodoroPauseTimer,
                            canChangeDuration: !isRunning
                        )
                    case .break:
                        BreakView(
                            breakElapsed: $breakElapsed,
                            breakTotal: $breakTotal,
                            isBreakRunning: $isBreakRunning,
                            startBreak: startBreak,
                            pauseBreak: pauseBreak,
                            resetBreak: resetBreak,
                            showDurationPicker: $showBreakDurationPicker
                        )
                    case .stopwatch:
                        StopwatchView(manager: stopwatchManager)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
            }
            .navigationTitle("Focus")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Placeholder for sound toggle or something similar
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .imageScale(.large)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FocusStatsView(viewModel: statsVM)) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle")
                            .imageScale(.large)
                    }
                }
            }
            .alert(isPresented: $showDurationChangeAlert) {
                Alert(
                    title: Text("Cannot Change Duration"),
                    message: Text("Please stop the current timer before changing the duration."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showSheet) {
                if selectedMode == .pomodoro {
                    // Only show sheet if canChangeDuration is true
                    SheetContentView(selectedDuration: $totalTime, resetTimer: pomodoroResetTimer, showSheet: $showSheet)
                }
            }
            .sheet(isPresented: $showBreakDurationPicker) {
                BreakDurationPickerView(breakTotal: $breakTotal, showPicker: $showBreakDurationPicker)
            }
        }
    }
    
    private func handleModeChange(to newValue: FocusMode) {
        // Stop other timers if running and switch mode
        switch newValue {
        case .pomodoro:
            if currentMode == .breakTime && isBreakRunning {
                // Stop break
                completeBreakSession()
            } else if currentMode == .stopwatch && stopwatchManager.isRunning {
                stopwatchManager.pause()
            }
            currentMode = .pomodoro
        case .break:
            if currentMode == .pomodoro && isRunning {
                completePomodoroSession()
            } else if currentMode == .stopwatch && stopwatchManager.isRunning {
                stopwatchManager.pause()
            }
            currentMode = .breakTime
        case .stopwatch:
            if currentMode == .pomodoro && isRunning {
                completePomodoroSession()
            } else if currentMode == .breakTime && isBreakRunning {
                completeBreakSession()
            }
            currentMode = .stopwatch
        }
    }
    
    // MARK: - Pomodoro Functions
    private func pomodoroStartTimer() {
        guard !isRunning else { return }
        // If another timer is running, stop it first
        if currentMode != .pomodoro && currentMode != .none { handleModeChange(to: .pomodoro) }
        currentMode = .pomodoro
        isRunning = true
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if elapsedTime < totalTime {
                    elapsedTime += 1
                } else {
                    // Timer complete
                    completePomodoroSession()
                }
            }
    }
    
    private func pomodoroPauseTimer() {
        isRunning = false
        timerSubscription?.cancel()
    }
    
    private func pomodoroResetTimer() {
        pomodoroPauseTimer()
        elapsedTime = 0
    }
    
    private func completePomodoroSession() {
        pomodoroPauseTimer()
        elapsedTime = totalTime // ensure it shows 00:00 since counting down is totalTime - elapsedTime
        isRunning = false
        // Record session
        statsVM.addSession(.focus, duration: Int(totalTime))
        // Reset after a short delay so user can see 00:00
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.elapsedTime = 0
        }
        currentMode = .none
    }
    
    // MARK: - Break Functions
    private func startBreak() {
        guard !isBreakRunning else { return }
        if currentMode != .breakTime && currentMode != .none { handleModeChange(to: .break) }
        currentMode = .breakTime
        isBreakRunning = true
        breakSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if breakElapsed < breakTotal {
                    breakElapsed += 1
                } else {
                    completeBreakSession()
                }
            }
    }
    
    private func pauseBreak() {
        isBreakRunning = false
        breakSubscription?.cancel()
    }
    
    private func resetBreak() {
        pauseBreak()
        breakElapsed = 0
    }
    
    private func completeBreakSession() {
        pauseBreak()
        breakElapsed = breakTotal
        isBreakRunning = false
        // Record session
        statsVM.addSession(.break, duration: Int(breakTotal))
        // Reset after showing 00:00 for a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.breakElapsed = 0
        }
        currentMode = .none
    }
}
