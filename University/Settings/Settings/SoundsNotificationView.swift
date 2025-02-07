//
//  SoundsNotificationView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah
//

import SwiftUI
import UserNotifications

struct SoundsNotificationView: View {
    @State private var notificationsEnabled = false
    @State private var isCheckingPermissions = true
    @State private var soundEnabled = true
    @State private var hapticEnabled = true
    @State private var reminderTime = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.red)
                    
                    Text("Notifications & Sound")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("Stay updated with important reminders and alerts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text("Notifications")) {
                HStack {
                    Label("Push Notifications", systemImage: "bell.badge")
                    Spacer()
                    if isCheckingPermissions {
                        LoadingIndicator()
                            .transition(.scale)
                    } else {
                        Toggle("", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { oldValue, newValue in
                                if newValue {
                                    requestNotificationPermission()
                                } else {
                                    openSettings()
                                }
                            }
                    }
                }
                
                if notificationsEnabled {
                    NavigationLink(destination: Text("Notification Categories")) {
                        Label("Categories", systemImage: "list.bullet")
                    }
                    
                    DatePicker("Daily Reminder", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            
            Section(header: Text("Sound & Haptics")) {
                Toggle("Sound Effects", isOn: $soundEnabled)
                Toggle("Haptic Feedback", isOn: $hapticEnabled)
                
                if soundEnabled {
                    NavigationLink(destination: Text("Sound Settings")) {
                        Label("Sound Settings", systemImage: "speaker.wave.2.fill")
                    }
                }
            }
            
            Section(header: Text("Debug")) {
                Button(action: {
                    // Test notification
                    scheduleTestNotification()
                }) {
                    Label("Send Test Notification", systemImage: "bell.badge.fill")
                }
            }
        }
        .navigationTitle("Sounds & Notifications")
        .listStyle(.insetGrouped)
        .alert("Notification Settings", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkNotificationPermissions()
        }
    }
    
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                withAnimation {
                    notificationsEnabled = settings.authorizationStatus == .authorized
                    isCheckingPermissions = false
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    notificationsEnabled = true
                } else {
                    notificationsEnabled = false
                    alertMessage = "Please enable notifications in Settings to receive reminders."
                    showAlert = true
                }
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from Notiva"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    alertMessage = "Test notification scheduled (5 seconds)"
                } else {
                    alertMessage = "Failed to schedule notification"
                }
                showAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SoundsNotificationView()
    }
}

