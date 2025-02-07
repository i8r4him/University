//
//  ImportIntegrationView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah
//

import SwiftUI
import EventKit

struct ImportIntegrationView: View {
    @State private var calendarAccess = false
    @State private var reminderAccess = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var calendarConnecting = false
    @State private var reminderConnecting = false
    
    var body: some View {
        Form {
            // Header section remains the same
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "arrow.triangle.merge")
                        .font(.system(size: 60))
                        .foregroundStyle(.purple)
                    
                    Text("Import Your Data")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("Connect your calendars and reminders to enhance your Notiva experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text("Apple Calendar")) {
                HStack {
                    Label("Import Calendar Events", systemImage: "calendar")
                    Spacer()
                    if calendarConnecting {
                        ProgressView()
                            .transition(.scale)
                    } else {
                        HStack(spacing: 4) {
                            if calendarAccess {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .transition(.scale)
                            }
                            Button(calendarAccess ? "Connected" : "Connect") {
                                withAnimation {
                                    calendarConnecting = true
                                    requestCalendarAccess()
                                }
                            }
                            .foregroundColor(calendarAccess ? .green : .accentColor)
                        }
                    }
                }
            }
            
            Section(header: Text("Apple Reminders")) {
                HStack {
                    Label("Import Reminders", systemImage: "list.bullet.clipboard")
                    Spacer()
                    if reminderConnecting {
                        ProgressView()
                            .transition(.scale)
                    } else {
                        HStack(spacing: 4) {
                            if reminderAccess {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .transition(.scale)
                            }
                            Button(reminderAccess ? "Connected" : "Connect") {
                                withAnimation {
                                    reminderConnecting = true
                                    requestReminderAccess()
                                }
                            }
                            .foregroundColor(reminderAccess ? .green : .accentColor)
                        }
                    }
                }
            }
            
            // Actions section remains the same
            if calendarAccess || reminderAccess {
                Section(header: Text("Actions")) {
                    Button(action: startImport) {
                        Label("Start Import", systemImage: "arrow.down.circle.fill")
                    }
                }
            }
        }
        .navigationTitle("Import & Integration")
        .listStyle(.insetGrouped)
        .alert("Import Status", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkPermissions()
        }
    }
    
    private func checkPermissions() {
        _ = EKEventStore()
        
        // Check calendar access
        calendarAccess = EKEventStore.authorizationStatus(for: .event) == .fullAccess
        
        // Check reminder access
        reminderAccess = EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
    }
    
    private func requestCalendarAccess() {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                withAnimation {
                    calendarConnecting = false
                    calendarAccess = granted
                    if !granted {
                        alertMessage = "Please enable Calendar access in Settings to import events."
                        showingAlert = true
                    }
                }
            }
        }
    }
    
    private func requestReminderAccess() {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToReminders { granted, error in
            DispatchQueue.main.async {
                withAnimation {
                    reminderConnecting = false
                    reminderAccess = granted
                    if !granted {
                        alertMessage = "Please enable Reminders access in Settings to import tasks."
                        showingAlert = true
                    }
                }
            }
        }
    }
    
    private func startImport() {
        // TODO: Implement actual import logic
        alertMessage = "Import started! Your data will be available soon."
        showingAlert = true
    }
}

#Preview {
    NavigationStack {
        ImportIntegrationView()
    }
}
