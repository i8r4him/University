//
//
//  CloudBackupView.swift
//  Notiva
//
//  Created by Ibrahim Abdullah
//

import SwiftUI
import CloudKit

struct CloudBackupView: View {
    @State private var iCloudEnabled = false
    @State private var isChecking = true
    @State private var lastBackupDate: Date? = nil
    @State private var isBackingUp = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                        .shadow(radius: 5)
                    
                    Text("Cloud Backup")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("Keep your data safe and sync across devices")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text("iCloud Sync")) {
                HStack {
                    Label("iCloud Sync", systemImage: "icloud")
                    Spacer()
                    if isChecking {
                        LoadingIndicator()
                            .transition(.scale)
                    } else {
                        HStack(spacing: 4) {
                            if iCloudEnabled {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .transition(.scale)
                            }
                            Text(iCloudEnabled ? "Connected" : "Not Connected")
                                .foregroundColor(iCloudEnabled ? .green : .secondary)
                        }
                    }
                }
                
                if let lastBackup = lastBackupDate {
                    HStack {
                        Label("Last Backup", systemImage: "clock")
                        Spacer()
                        Text(lastBackup, style: .relative)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if iCloudEnabled {
                Section(header: Text("Backup Options")) {
                    Button(action: performBackup) {
                        HStack {
                            Label("Backup Now", systemImage: "arrow.clockwise.icloud.fill")
                            Spacer()
                            if isBackingUp {
                                LoadingIndicator()
                                    .transition(.scale)
                            }
                        }
                    }
                    .disabled(isBackingUp)
                    
                    NavigationLink(destination: Text("Backup History")) {
                        Label("Backup History", systemImage: "clock.arrow.circlepath")
                    }
                }
                
                Section(header: Text("Advanced")) {
                    NavigationLink(destination: Text("Backup Settings")) {
                        Label("Backup Settings", systemImage: "gearshape")
                    }
                    
                    Button(action: restoreFromBackup) {
                        Label("Restore from Backup", systemImage: "arrow.counterclockwise.icloud.fill")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Cloud & Backup")
        .symbolRenderingMode(.hierarchical)
        .listStyle(.insetGrouped)
        .alert("Backup Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkiCloudStatus()
        }
    }
    
    private func checkiCloudStatus() {
        isChecking = true
        // Simulate iCloud status check
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                iCloudEnabled = true
                isChecking = false
                lastBackupDate = Date().addingTimeInterval(-86400) // 24 hours ago
            }
        }
    }
    
    private func performBackup() {
        guard !isBackingUp else { return }
        
        withAnimation {
            isBackingUp = true
        }
        
        // Simulate backup process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isBackingUp = false
                lastBackupDate = Date()
                alertMessage = "Backup completed successfully!"
                showAlert = true
            }
        }
    }
    
    private func restoreFromBackup() {
        alertMessage = "Are you sure you want to restore from backup? This will replace all current data."
        showAlert = true
    }
}

#Preview {
    NavigationStack {
        CloudBackupView()
    }
}

