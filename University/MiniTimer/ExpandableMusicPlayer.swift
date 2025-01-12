import SwiftUI

struct ExpandableTimerPlayer: View {
    @Binding var show: Bool          // Controls showing/hiding the overlay
    @Binding var hideMiniTimer: Bool // External logic to hide the mini timer
    @Binding var isRunning: Bool     // Tracks if timer is running
    
    // If you want the user to pick a custom duration, pass it here from FocusView
    var selectedMinutes: Int = 25
    
    // MARK: - Window/Animation
    @State private var expandTimer: Bool = false
    @State private var offsetY: CGFloat = 0
    @State private var mainWindow: UIWindow?
    @State private var windowProgress: CGFloat = 0
    
    // MARK: - Countdown Logic
    @State private var totalSeconds: Int = 0
    @State private var remainingSeconds: Int = 0
    
    // Alert to confirm cancel
    @State private var showCancelAlert: Bool = false
    
    // Publishes a tick every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Progress from 0..1
    private var progress: Double {
        // Avoid division by zero
        guard totalSeconds > 0 else { return 0 }
        return 1 - (Double(remainingSeconds) / Double(totalSeconds))
    }
    
    // Matched geometry for artwork transitions (if needed)
    @Namespace private var animation
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeArea = proxy.safeAreaInsets
            
            ZStack(alignment: .top) {
                // MARK: - Plain Background
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .frame(height: expandTimer ? nil : 55)
                
                // MINI TIMER
                MiniTimerView(safeArea: safeArea)
                    .opacity(expandTimer ? 0 : 1)
                
                // EXPANDED TIMER
                ExpandedTimerView(safeArea: safeArea)
                    .opacity(expandTimer ? 1 : 0)
            }
            // Collapsed height = 55
            .frame(height: expandTimer ? nil : 55, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            // Extra bottom padding in mini mode
            .padding(.bottom, expandTimer ? 0 : safeArea.bottom + 55)
            // Horizontal padding in mini mode
            .padding(.horizontal, expandTimer ? 0 : 15)
            // Let user swipe the expanded view down
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard expandTimer else { return }
                        let translation = max(value.translation.height, 0)
                        offsetY = translation
                        windowProgress = max(min(translation / size.height, 1), 0) * 0.1
                        resizeWindow(0.1 - windowProgress)
                    }
                    .onEnded { value in
                        guard expandTimer else { return }
                        let translation = max(value.translation.height, 0)
                        let velocity = value.velocity.height / 5
                        
                        withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                            // If user swipes down enough, close
                            if (translation + velocity) > (size.height * 0.5) {
                                expandTimer = false
                                windowProgress = 0
                                resetWindowWithAnimation()
                            } else {
                                UIView.animate(withDuration: 0.3) {
                                    resizeWindow(0.1)
                                }
                            }
                            offsetY = 0
                        }
                    }
            )
            // If external logic wants to hide the mini timer
            .offset(y: hideMiniTimer && !expandTimer ? safeArea.bottom + 200 : 0)
            .ignoresSafeArea()
            
            // MARK: - Timer Counting Down
            .onReceive(timer) { _ in
                guard isRunning else { return }
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    // Time's up
                    isRunning = false
                    show = false
                }
            }
            // If show is toggled off externally, reset
            .onChange(of: show) { _, newValue in
                if !newValue {
                    remainingSeconds = totalSeconds
                    isRunning = false
                }
            }
        }
        .onAppear {
            // 1) Set up the total/remaining from chosen minutes
            totalSeconds = selectedMinutes * 60
            remainingSeconds = totalSeconds
            
            // 2) Grab the main window (for the scaling effect)
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow,
               mainWindow == nil {
                mainWindow = window
            }
        }
    }
    
    // MARK: - MINI TIMER
    @ViewBuilder
    func MiniTimerView(safeArea: EdgeInsets) -> some View {
        HStack(spacing: 12) {
            // Circle progress
            ZStack {
                Circle()
                    .stroke(
                        Color.gray.opacity(0.3),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 30, height: 30)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)
            }
            .frame(width: 45, height: 45)
            .matchedGeometryEffect(id: "TimerIcon", in: animation)
            
            // Remaining time
            Text(formatSeconds(remainingSeconds))
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            
            Spacer(minLength: 0)
            
            // Pause Button
            Button {
                isRunning.toggle()
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            
            // Cancel Button
            Button {
                // Present the "are you sure?" alert
                isRunning = false
                 show = false
                 showCancelAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .frame(height: 55)
        // Background
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 6)
        // Swipe up to expand
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                            expandTimer = true
                        }
                        UIView.animate(withDuration: 0.3) {
                            resizeWindow(0.1)
                        }
                    }
                }
        )
        // Tap to expand
        .onTapGesture {
            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                expandTimer = true
            }
            UIView.animate(withDuration: 0.3) {
                resizeWindow(0.1)
            }
        }
    }
    
    // MARK: - EXPANDED TIMER
    @ViewBuilder
    func ExpandedTimerView(safeArea: EdgeInsets) -> some View {
        VStack(spacing: 0) {
            // Swipe Indicator at the Top
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.top, 75)    // Enough top spacing for notch
                .padding(.bottom, 12)
            
            Spacer()
            
            // Large circle in the center
            ZStack {
                Circle()
                    .stroke(
                        Color.gray.opacity(0.3),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 350, height: 350)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 350, height: 350)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)
                
                Text(formatSeconds(remainingSeconds))
                    .font(.system(size: 50, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Window Resizing
    func resizeWindow(_ progress: CGFloat) {
        if let mainWindow = mainWindow?.subviews.first {
            let offsetY = (mainWindow.frame.height * progress) / 2
            mainWindow.layer.cornerRadius = (progress / 0.1) * 30
            mainWindow.layer.masksToBounds = true
            
            mainWindow.transform = .identity
                .scaledBy(x: 1 - progress, y: 1 - progress)
                .translatedBy(x: 0, y: offsetY)
        }
    }
    
    func resetWindowWithAnimation() {
        if let mainWindow = mainWindow?.subviews.first {
            UIView.animate(withDuration: 0.3) {
                mainWindow.layer.cornerRadius = 0
                mainWindow.transform = .identity
            }
        }
    }
    
    // MARK: - Helper
    func formatSeconds(_ totalSeconds: Int) -> String {
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ExpandableTimerPlayer(show: .constant(true), hideMiniTimer: .constant(false), isRunning: .constant(true))
}
