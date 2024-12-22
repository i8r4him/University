import SwiftUI
import Combine

struct BreakView: View {
    @Binding var breakElapsed: Double
    @Binding var breakTotal: Double
    @Binding var isBreakRunning: Bool
    var startBreak: () -> Void
    var pauseBreak: () -> Void
    var resetBreak: () -> Void
    @Binding var showDurationPicker: Bool
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Take a Break")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Change Break Duration") {
                if !isBreakRunning {
                    showDurationPicker = true
                }
            }
            .font(.headline)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)

            Text(timeString(from: breakTotal - breakElapsed))
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            if !isBreakRunning && breakElapsed > 0 && breakElapsed < breakTotal {
                Text("Paused")
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 30) {
                Button(action: {
                    isBreakRunning ? pauseBreak() : startBreak()
                }) {
                    Label(isBreakRunning ? "Pause" : "Start", systemImage: isBreakRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .frame(width: 120, height: 50)
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                }
                
                Button(action: resetBreak) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 120, height: 50)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                }
            }
        }
        .padding()
    }
    
    private func timeString(from seconds: Double) -> String {
        let clampedSeconds = max(0, seconds)
        let totalSeconds = Int(clampedSeconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
