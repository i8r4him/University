// StopwatchManager.swift

import SwiftUI
import Combine
import UserNotifications

class StopwatchManager: ObservableObject {
    @Published var elapsedTime: Double = 0
    @Published var isRunning: Bool = false
    
    private var startTime: Date?
    private var pauseTime: Date?
    
    private var timerSubscription: AnyCancellable?
    
    init() {
        requestNotificationPermission()
    }
    
    // Start the stopwatch
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        if let pauseTime = pauseTime, let startTime = startTime {
            // Adjust the start time based on pause duration
            let pauseDuration = Date().timeIntervalSince(pauseTime)
            self.startTime = startTime.addingTimeInterval(pauseDuration)
        } else {
            // Initial start
            startTime = Date()
        }
        
        pauseTime = nil
        
        // Start a Timer publisher to update elapsedTime every second
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateElapsedTime()
            }
        
        // Schedule a notification for a milestone (e.g., every 10 minutes)
        scheduleMilestoneNotifications()
    }
    
    // Pause the stopwatch
    func pause() {
        guard isRunning else { return }
        isRunning = false
        pauseTime = Date()
        timerSubscription?.cancel()
        timerSubscription = nil
        cancelMilestoneNotifications()
    }
    
    // Reset the stopwatch
    func reset() {
        isRunning = false
        startTime = nil
        pauseTime = nil
        elapsedTime = 0
        timerSubscription?.cancel()
        timerSubscription = nil
        cancelMilestoneNotifications()
    }
    
    // Update elapsed time based on current time and start time
    func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
    
    // Request notification permissions
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    // Schedule milestone notifications (e.g., every 10 minutes)
    private func scheduleMilestoneNotifications() {
        cancelMilestoneNotifications() // Ensure no duplicate notifications
        
        let milestoneInterval: TimeInterval = 600 // 10 minutes in seconds
        let numberOfMilestones = 6 // Up to 1 hour
        
        for i in 1...numberOfMilestones {
            let content = UNMutableNotificationContent()
            content.title = "Stopwatch Milestone"
            content.body = "You've reached \(i * 10) minutes!"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: milestoneInterval * Double(i), repeats: false)
            let request = UNNotificationRequest(identifier: "milestone_\(i)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    // Cancel milestone notifications
    private func cancelMilestoneNotifications() {
        for i in 1...6 {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["milestone_\(i)"])
        }
    }
}
