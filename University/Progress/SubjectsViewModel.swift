//
//  SubjectsViewModel.swift
//  University
//
//  Created by Ibrahim Abdullah on 17.12.24.
//

import CoreData
import SwiftUI

class SubjectsViewModel: ObservableObject {
    @Published var subjects: [SubjectCredit] = []
    @Published var major: String = ""
    @Published var targetCredits: Int = 0
    @Published var graphType: GraphType = .donut

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
        loadSubjects()
        loadSettings()
    }

    func loadSubjects() {
        let request: NSFetchRequest<SubjectEntity> = SubjectEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            self.subjects = entities.map { entity in
                SubjectCredit(
                    id: entity.id ?? UUID(),
                    subjectName: entity.subjectName ?? "Unknown",
                    credits: Int(entity.credits),
                    color: Color.fromHexString(entity.colorHex ?? "#000000"),
                    type: entity.type ?? "Unknown"
                )
            }
        } catch {
            print("Error fetching subjects: \(error)")
        }
    }

    func saveSubject(_ subject: SubjectCredit) {
        // If the subject already exists in self.subjects, update it.
        // Else create a new one.
        let request: NSFetchRequest<SubjectEntity> = SubjectEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", subject.id as CVarArg)
        do {
            let result = try context.fetch(request)
            let entity: SubjectEntity
            if let existing = result.first {
                entity = existing
            } else {
                entity = SubjectEntity(context: context)
                entity.id = subject.id
            }
            entity.subjectName = subject.subjectName
            entity.credits = Int16(subject.credits)
            entity.type = subject.type
            entity.colorHex = subject.color.toHexString()
            try context.save()
            loadSubjects()
        } catch {
            print("Error saving subject: \(error)")
        }
    }

    func deleteSubject(_ subject: SubjectCredit) {
        let request: NSFetchRequest<SubjectEntity> = SubjectEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", subject.id as CVarArg)
        do {
            let result = try context.fetch(request)
            if let entity = result.first {
                context.delete(entity)
                try context.save()
                loadSubjects()
            }
        } catch {
            print("Error deleting subject: \(error)")
        }
    }

    // UserDefaults for major and target credits
    func loadSettings() {
        major = UserDefaults.standard.string(forKey: "major") ?? ""
        targetCredits = UserDefaults.standard.integer(forKey: "targetCredits")
    }

    func saveSettings(major: String, targetCredits: Int) {
        self.major = major
        self.targetCredits = targetCredits
        UserDefaults.standard.set(major, forKey: "major")
        UserDefaults.standard.set(targetCredits, forKey: "targetCredits")
    }
}
