//
//  UniversityApp.swift
//  University
//
//  Created by Ibrahim Abdullah on 14.12.24.
//

import SwiftUI
import UserNotifications
import CoreData

@main
struct UniversityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
    }
}
