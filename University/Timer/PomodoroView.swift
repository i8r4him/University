import SwiftUI

struct PomodoroView: View {
    @Binding var elapsedTime: Double
    @Binding var totalTime: Double
    @Binding var isRunning: Bool
    var startTimer: () -> Void
    var resetTimer: () -> Void
    var pauseTimer: () -> Void
    var canChangeDuration: Bool
    
    @Environment(\.colorScheme) var scheme

    var body: some View {
        VStack(spacing: 100) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 350, height: 350)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(elapsedTime / totalTime))
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear(duration: 1), value: elapsedTime)
                    .frame(width: 350, height: 350)
                
                Button(action: {
                    if canChangeDuration {
                        // Show sheet to change duration
                        // Handled by parent via showSheet binding in TimerView
                        NotificationCenter.default.post(name: NSNotification.Name("ShowPomodoroSheet"), object: nil)
                    } else {
                        // Show alert in parent or just do nothing
                        NotificationCenter.default.post(name: NSNotification.Name("ShowDurationChangeAlert"), object: nil)
                    }
                }) {
                    VStack {
                        Text(timeString(from: totalTime - elapsedTime))
                            .font(.system(size: 65, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    
                        if !isRunning && elapsedTime != 0 && elapsedTime < totalTime {
                            Text("Stopped")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    isRunning ? pauseTimer() : startTimer()
                }) {
                    Label(isRunning ? "Pause" : "Start", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .frame(width: 120, height: 50)
                        .background(Color.accentColor.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(radius: 4)
                }

                Button(action: resetTimer) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 120, height: 50)
                        .background(scheme == .dark ? Color.gray : Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(25)
                        .shadow(radius: 4)
                }
            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowPomodoroSheet"))) { _ in
            // If canChangeDuration is true, show sheet in parent.
            if canChangeDuration {
                // The parent is TimerView which uses showSheet binding
                // We'll do a trick: you can use a preference or just directly access environmentObject
                // For brevity, assume TimerView listens to this notification to show the sheet.
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowDurationChangeAlert"))) { _ in
            // Show alert handled by TimerView
        }
    }

    private func timeString(from seconds: Double) -> String {
        let clampedSeconds = max(0, seconds)
        let totalSeconds = Int(clampedSeconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
