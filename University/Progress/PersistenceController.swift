//
//  PersistenceController.swift
//  University
//
//  Created by Ibrahim Abdullah on 17.12.24.
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "University") // matches your xcdatamodeld name
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Create sample subjects
        let subjects = [
            SubjectEntity(context: viewContext),
            SubjectEntity(context: viewContext),
            SubjectEntity(context: viewContext),
            SubjectEntity(context: viewContext),
            SubjectEntity(context: viewContext)
        ]

        subjects[0].id = UUID()
        subjects[0].subjectName = "Mathematics"
        subjects[0].credits = 30
        subjects[0].type = "Core"
        subjects[0].colorHex = "#1E90FF" // Dodger Blue

        subjects[1].id = UUID()
        subjects[1].subjectName = "Physics"
        subjects[1].credits = 25
        subjects[1].type = "Elective"
        subjects[1].colorHex = "#32CD32" // Lime Green

        subjects[2].id = UUID()
        subjects[2].subjectName = "Computer Programming"
        subjects[2].credits = 40
        subjects[2].type = "Core"
        subjects[2].colorHex = "#FF4500" // Orange Red

        subjects[3].id = UUID()
        subjects[3].subjectName = "History"
        subjects[3].credits = 20
        subjects[3].type = "Elective"
        subjects[3].colorHex = "#FFA500" // Orange

        subjects[4].id = UUID()
        subjects[4].subjectName = "Chemistry"
        subjects[4].credits = 35
        subjects[4].type = "Core"
        subjects[4].colorHex = "#800080" // Purple

        // Save the context
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        // Set UserDefaults for major and targetCredits
        UserDefaults.standard.set("Computer Science", forKey: "major")
        UserDefaults.standard.set(180, forKey: "targetCredits")

        return controller
    }()
}
