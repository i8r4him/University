//
//  UniversityApp.swift
//  University
//
//  Created by Ibrahim Abdullah on 14.12.24.
//

import SwiftUI
import UserNotifications

@main
struct UniversityApp: App {
    @StateObject var stopwatchManager = StopwatchManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(stopwatchManager)
        }
    }
}
