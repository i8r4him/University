//
//  AddOrEditEventView.swift
//  University
//
//  Created by Ibrahim Abdullah on 15.12.24.
//

import SwiftUI

struct AddOrEditEventView: View {
    var event: Event?
    var onSave: (Event) -> Void
    
    @State private var title: String = ""
    @State private var selectedType: EventType = .lecture
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var isAllDay: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var selectedColor: Color = .blue
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    TextField("Notes", text: $notes)
                    Toggle("All Day", isOn: $isAllDay)
                }
                
                Section(header: Text("Time")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Color")) {
                    ColorPicker("Select Color", selection: $selectedColor)
                }
            }
            .navigationTitle(event == nil ? "Add Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newEvent = Event(
                            id: event?.id ?? UUID(),
                            title: title,
                            type: .lecture,
                            location: location.isEmpty ? nil : location,
                            notes: notes.isEmpty ? nil : notes,
                            isAllDay: isAllDay,
                            startDate: startDate,
                            endDate: endDate,
                            repeatOption: .none,
                            repeatSlots: nil,
                            color: selectedColor
                        )
                        onSave(newEvent)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let event = event {
                    title = event.title
                    selectedType = event.type
                    location = event.location ?? ""
                    notes = event.notes ?? ""
                    isAllDay = event.isAllDay
                    startDate = event.startDate
                    endDate = event.endDate
                    selectedColor = event.color
                }
            }
        }
    }
}

// MARK: - Preview

struct AddOrEditEventView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Add Event - Light Mode
            AddOrEditEventView(event: nil, onSave: { event in
                print("Add Event: \(event.title)")
            })
            .previewDisplayName("Add Event - Light Mode")
            .environment(\.colorScheme, .light)
            
            // Edit Event - Light Mode
            AddOrEditEventView(event: sampleEvent, onSave: { event in
                print("Edit Event: \(event.title)")
            })
            .previewDisplayName("Edit Event - Light Mode")
            .environment(\.colorScheme, .light)
            
            // Add Event - Dark Mode
            AddOrEditEventView(event: nil, onSave: { event in
                print("Add Event: \(event.title)")
            })
            .previewDisplayName("Add Event - Dark Mode")
            .environment(\.colorScheme, .dark)
            
            // Edit Event - Dark Mode
            AddOrEditEventView(event: sampleEvent, onSave: { event in
                print("Edit Event: \(event.title)")
            })
            .previewDisplayName("Edit Event - Dark Mode")
            .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
    
    // Sample Event for Editing Preview
    static var sampleEvent: Event {
        Event(
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
        )
    }
}
