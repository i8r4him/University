import SwiftUI
import Combine

struct StopwatchView: View {
    @ObservedObject var manager: StopwatchManager
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(spacing: 40) {
            Text(timeString(from: manager.elapsedTime))
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            if !manager.isRunning && manager.elapsedTime != 0 {
                Text("Paused")
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 30) {
                Button(action: {
                    manager.isRunning ? manager.pause() : manager.start()
                }) {
                    Label(manager.isRunning ? "Pause" : "Start", systemImage: manager.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .frame(width: 120, height: 50)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                }
                
                Button(action: manager.reset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 120, height: 50)
                        .background(scheme == .dark ? Color.gray : Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                }
            }
        }
        .padding()
    }
    
    private func timeString(from seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchView(manager: StopwatchManager())
    }
}
