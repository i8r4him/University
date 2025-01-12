//
//  CalendarViewModel.swift
//  University
//
//  Created by Ibrahim Abdullah on 15.12.24.
//

import SwiftUI
import CoreData


class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedDate: Date = Date()
    @Published var currentWeekStart: Date = Calendar.current.startOfWeek(for: Date())!

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
        loadEvents()
    }

    func loadEvents() {
        let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            self.events = entities.map { entity in
                Event(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    type: EventType(rawValue: entity.type ?? "Lecture") ?? .lecture,
                    location: entity.location,
                    notes: entity.notes,
                    isAllDay: entity.isAllDay,
                    startDate: entity.startDate ?? Date(),
                    endDate: entity.endDate ?? Date().addingTimeInterval(3600),
                    repeatOption: RepeatOption(rawValue: entity.repeatOption ?? "None") ?? .none,
                    repeatSlots: nil, // Handle if needed
                    color: Color.fromHexString(entity.colorHex ?? "#000000")
                )
            }
        } catch {
            print("Error loading events: \(error)")
        }
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    func addEvent(_ event: Event) {
        let entity = EventEntity(context: context)
        entity.id = event.id
        entity.title = event.title
        entity.type = event.type.rawValue
        entity.location = event.location
        entity.notes = event.notes
        entity.isAllDay = event.isAllDay
        entity.startDate = event.startDate
        entity.endDate = event.endDate
        entity.repeatOption = event.repeatOption.rawValue
        entity.colorHex = event.color.toHexString()
        // repeatSlots if needed
        saveContext()
        loadEvents()
    }

    func updateEvent(_ event: Event) {
        let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", event.id as CVarArg)
        do {
            let result = try context.fetch(request)
            if let entity = result.first {
                entity.title = event.title
                entity.type = event.type.rawValue
                entity.location = event.location
                entity.notes = event.notes
                entity.isAllDay = event.isAllDay
                entity.startDate = event.startDate
                entity.endDate = event.endDate
                entity.repeatOption = event.repeatOption.rawValue
                entity.colorHex = event.color.toHexString()
                // update repeatSlots if used
                saveContext()
                loadEvents()
            }
        } catch {
            print("Error updating event: \(error)")
        }
    }

    func removeEvent(_ event: Event) {
        let request: NSFetchRequest<EventEntity> = EventEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", event.id as CVarArg)
        do {
            let result = try context.fetch(request)
            if let entity = result.first {
                context.delete(entity)
                saveContext()
                loadEvents()
            }
        } catch {
            print("Error removing event: \(error)")
        }
    }

    func forceUpdateToToday() {
        let today = Date()
        let calendar = Calendar.current
        
        withAnimation {
            // First update currentWeekStart to ensure proper week alignment
            if let newWeekStart = calendar.startOfWeek(for: today) {
                currentWeekStart = newWeekStart
            }
            
            // Then update selectedDate after week is aligned
            selectedDate = today
        }
    }

    func fetchEvents(for date: Date) -> [Event] {
        // Pre-fetch events for the current week
        // Implement logic to fetch events for the current week
        return []
    }
}

// Helper to find startOfWeek:
extension Calendar {
    func startOfWeek(for date: Date) -> Date? {
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)
    }
}
 

extension CalendarViewModel {
    var eventsForSelectedDate: [Event] {
        var result: [Event] = []
        let calendar = Calendar.current

        // Determine today's weekday, converting it to 0-based if needed.
        let weekday = calendar.component(.weekday, from: selectedDate)
        let adjustedWeekday = (weekday - 1) % 7 // Sunday=0, Monday=1,...Saturday=6

        for event in events {
            switch event.repeatOption {
            case .none:
                // Only show if event's actual date is today's date
                if calendar.isDate(event.startDate, inSameDayAs: selectedDate) {
                    result.append(event)
                }

            case .daily:
                // Show the event every day. Create a virtual occurrence for today.
                let dailyEvent = createVirtualOccurrence(from: event, on: selectedDate)
                result.append(dailyEvent)

            case .weekly:
                // Check if any slot matches today's weekday
                if let slots = event.repeatSlots {
                    for slot in slots {
                        if slot.dayOfWeek == adjustedWeekday {
                            // Create a virtual occurrence using slot times
                            let weeklyEvent = createVirtualOccurrence(from: event, on: selectedDate, slot: slot)
                            result.append(weeklyEvent)
                        }
                    }
                }

            case .custom:
                // Handle custom repeats if needed
                // For now, not shown. Implement similar logic as weekly if custom logic applies.
                break
            }
        }

        return result.sorted(by: { $0.startDate < $1.startDate })
    }

    private func createVirtualOccurrence(from event: Event, on date: Date, slot: (dayOfWeek: Int, startTime: Date, endTime: Date)? = nil) -> Event {
        let calendar = Calendar.current

        // Extract hours/minutes from either slot times or original event times
        let startComponents = calendar.dateComponents([.hour, .minute], from: slot?.startTime ?? event.startDate)
        let endComponents = calendar.dateComponents([.hour, .minute], from: slot?.endTime ?? event.endDate)
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: date)

        var finalStartComps = startComponents
        finalStartComps.year = dayComponents.year
        finalStartComps.month = dayComponents.month
        finalStartComps.day = dayComponents.day

        var finalEndComps = endComponents
        finalEndComps.year = dayComponents.year
        finalEndComps.month = dayComponents.month
        finalEndComps.day = dayComponents.day

        let start = calendar.date(from: finalStartComps) ?? date
        let end = calendar.date(from: finalEndComps) ?? date.addingTimeInterval(3600)

        return Event(
            id: event.id,
            title: event.title,
            type: event.type,
            location: event.location,
            notes: event.notes,
            isAllDay: event.isAllDay,
            startDate: start,
            endDate: end,
            repeatOption: event.repeatOption,
            repeatSlots: event.repeatSlots,
            color: event.color
        )
    }
}

extension CalendarViewModel {
    func eventsForDate(_ date: Date) -> [Event] {
        // Instead of changing selectedDate, directly filter events for 'date'.
        // Use similar logic as eventsForSelectedDate, but with 'date' instead of 'selectedDate'.

        let calendar = Calendar.current
        return events.filter { event in
            switch event.repeatOption {
            case .none:
                return calendar.isDate(event.startDate, inSameDayAs: date)
            case .daily:
                return true // daily repeats every day
            case .weekly:
                if let slots = event.repeatSlots {
                    // Determine adjustedWeekday from 'date'
                    let weekday = calendar.component(.weekday, from: date)
                    let adjustedWeekday = (weekday - 1) % 7
                    return slots.contains(where: { $0.dayOfWeek == adjustedWeekday })
                }
                return false
            case .custom:
                // Handle custom repeat if needed.
                return false
            }
        }
        .sorted(by: { $0.startDate < $1.startDate })
    }
}
