//
//  EventRowView.swift
//  University
//
//  Created by Ibrahim Abdullah on 15.12.24.
//

import SwiftUI

struct EventRowView: View {
    var event: Event
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(timeRange(event))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.secondary)
                Text("\(event.type.rawValue): \(event.title)")
                    .font(.headline)
                if let loc = event.location, !loc.isEmpty {
                    Text("Location: \(loc)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let notes = event.notes, !notes.isEmpty {
                    Text("Notes: \(notes)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Menu {
                Button("Edit", action: onEdit)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(scheme == .dark ? event.color.opacity(0.4) : event.color.opacity(0.2))
        .cornerRadius(15)
        .overlay( // Added overlay for border
            RoundedRectangle(cornerRadius: 15)
                .stroke(borderColor, lineWidth: 2) // Border color and width
        )
    }
    
    // Computed property for border color based on color scheme
    private var borderColor: Color {
        scheme == .dark ? event.color : event.color.opacity(0.7)
    }
    
    func timeRange(_ event: Event) -> String {
        if event.isAllDay {
            return "All Day"
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
        }
    }
}

struct EventRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Lecture Event in Light Mode
            EventRowView(
                event: Event(
                    id: UUID(),
                    title: "Calculus Lecture",
                    type: .lecture,
                    location: "Room 101",
                    notes: "Bring textbook and notebook",
                    isAllDay: false,
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
                    repeatOption: .none,
                    repeatSlots: nil,
                    color: .blue
                ),
                onEdit: {},
                onDelete: {}
            )
            .previewDisplayName("Lecture Event - Light Mode")
            
            // Lecture Event in Dark Mode
            EventRowView(
                event: Event(
                    id: UUID(),
                    title: "Calculus Lecture",
                    type: .lecture,
                    location: "Room 101",
                    notes: "Bring textbook and notebook",
                    isAllDay: false,
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
                    repeatOption: .none,
                    repeatSlots: nil,
                    color: .blue
                ),
                onEdit: {},
                onDelete: {}
            )
            .previewDisplayName("Lecture Event - Dark Mode")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
