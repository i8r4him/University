import SwiftUI

struct AddEventSheetView: View {
    // MARK: - State Properties
    
    @State private var eventTitle: String = ""
    @State private var eventLocation: String = ""
    @State private var eventNotes: String = ""
    @State private var isAllDay: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600) // Default 1 hour later
    @State private var repeatOption: RepeatOption = .none
    @State private var customRepeatDays: [Int] = [] // Days of the week (1 = Sunday, 7 = Saturday)
    @State private var reminderTime: ReminderTime = .tenMinutesBefore
    @State private var selectedColor: Color = .blue
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showNotificationsToggle: Bool = false
    @State private var weeklyRepeatEndTime: Date = Date().addingTimeInterval(3600)
    
    // Repeat Specific Times
    @State private var dailyRepeatTime: Date = Date()
    @State private var weeklyRepeatTime: Date = Date()
    
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    // MARK: - Event Type (Set Automatically)
    var eventType: EventType
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $eventTitle)
                    TextField("Notes", text: $eventNotes)
                    TextField("location", text: $eventLocation)
                }
                
                Section(header: Text("we")) {
                    Toggle(isOn: $isAllDay) {
                        Label("All-Day Event", systemImage: "clock.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                    dateTimeSection

                    // Repeat Options Section
                    repeatOptionsSection
                
                    // Notifications Toggle
                    notificationsToggle
                    
                    // Color Picker Section
                    colorPickerSection
                
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Invalid Input"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
            }
            
            .toolbar {
                // Add Button
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        addEvent()
                        dismiss()
                    }) {
                        Text("Add")
                            .bold()
                    }
                    .disabled(eventTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                // Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add \(eventType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Helper function to format Date to Time string
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short // e.g., "3:00 PM"
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    // Helper Arrays
    let months = Calendar.current.monthSymbols
    let days = Array(1...31)

    // Helper Functions
    private func constructDate(month: Int, day: Int, hour: Int, minute: Int) -> Date? {
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: Date()) // Current Year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }

    private func formattedDisplayDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MMM HH:mm" // e.g., "18.Dec 15:00"
        return formatter.string(from: date)
    }
    
    // Event Details Section
    private var eventDetailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                
                // Start Date and Time or Date Only
                Text("\(formattedDate(startDate))")
                    .foregroundColor(.secondary)
                
                // Conditionally show the arrow and end time only if it's not an all-day event
                if !isAllDay {
                    Text("->")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    Text("\(formattedTime(endDate))")
                        .foregroundColor(.secondary)
                }
            }
            //.frame(maxWidth: .infinity, alignment: .leading)
        }
        //.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Event Information Section
    private var eventInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Event Title
            
            // Event Location
            VStack(alignment: .leading, spacing: 8) {
                Text("Location")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                TextField("Enter location...", text: $eventLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Event Location")
            }
            
            // Event Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                TextField("Enter Notes...", text: $eventNotes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Event Notes")
            }
            
            // All-Day Event Toggle
            
            .accessibilityLabel("All-Day Event Toggle")
        }
    }
    
    // Date and Time Section
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 4) {
                Text("Date")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .frame(width: 50, alignment: .leading) // Fixed width for labels
                Spacer(minLength: 0)
                
                // Start Date Picker
                DatePicker(
                    "",
                    selection: $startDate,
                    displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.automatic)
                //.frame(width: 200) // Adjust width as needed
                .onChange(of: startDate) { oldVlaue, newValue in
                    // Ensure endDate is always after startDate
                    if !isAllDay && endDate < startDate {
                        endDate = startDate.addingTimeInterval(3600) // Add 1 hour by default
                    } else if isAllDay && endDate < startDate {
                        endDate = startDate // For all-day events, set endDate to startDate
                    }
                }
                .accessibilityLabel("Start Date Picker")
                
                // Conditionally show the arrow and end date picker only if it's not an all-day event
                if !isAllDay {
                    // Arrow Separator
                    Text("->")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // End Time Picker
                    DatePicker(
                        "",
                        selection: $endDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                    .datePickerStyle(.automatic)
                    //.frame(width: 100) // Adjust width as needed
                    .onChange(of: endDate) { oldValue, newEndTime in
                        // Combine startDate's date with endDate's time
                        let calendar = Calendar.current
                        let startDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
                        let endTimeComponents = calendar.dateComponents([.hour, .minute], from: newEndTime)
                        
                        if let combinedDate = calendar.date(from: DateComponents(
                            year: startDateComponents.year,
                            month: startDateComponents.month,
                            day: startDateComponents.day,
                            hour: endTimeComponents.hour,
                            minute: endTimeComponents.minute
                        )) {
                            // Ensure endDate is after startDate
                            if combinedDate <= startDate {
                                // Set to startDate plus 1 hour or same date if all-day
                                endDate = isAllDay ? startDate : startDate.addingTimeInterval(3600)
                            } else {
                                endDate = combinedDate
                            }
                        }
                    }
                    .accessibilityLabel("End Time Picker")
                }
            }
        }
    }
    
    // Repeat Options Section
    private var repeatOptionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repeat")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Picker("", selection: $repeatOption) {
                ForEach(RepeatOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .accessibilityLabel("Repeat Option Picker")
            
            // Additional options based on repeat selection
            switch repeatOption {
            case .daily:
                dailyRepeatSection
            case .weekly:
                weeklyRepeatSection
            case .custom:
                customRepeatOptions
            case .none:
                EmptyView()
            }
        }
    }
    
    // Daily Repeat Section
    private var dailyRepeatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            DatePicker(
                "Select Time for Daily Repeat",
                selection: $dailyRepeatTime,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.automatic)
            .labelsHidden()
            .accessibilityLabel("Daily Repeat Time Picker")
        }
    }
    
    // Weekly Repeat Section
    private var weeklyRepeatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Day and Time for Weekly Repeat")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            // Day of the Week Selection (Single Selection)
            HStack {
                ForEach(1...7, id: \.self) { day in
                    Button(action: {
                        if customRepeatDays.contains(day) {
                            // Deselect if already selected
                            customRepeatDays.removeAll()
                        } else {
                            // Select only the tapped day
                            customRepeatDays = [day]
                        }
                    }) {
                        Text(shortDayName(from: day))
                            .font(.caption)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(customRepeatDays.contains(day) ? Color.accentColor : Color.gray.opacity(0.2))
                            .foregroundColor(customRepeatDays.contains(day) ? .white : .primary)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("\(fullDayName(from: day))")
                }
            }
            
            // Repeat Time Section with Start and End Time
            VStack(alignment: .leading, spacing: 8) {
                Text("Start Time")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                DatePicker(
                    "Select Start Time for Weekly Repeat",
                    selection: $weeklyRepeatTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .accessibilityLabel("Weekly Repeat Start Time Picker")
                
                Text("End Time")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                DatePicker(
                    "Select End Time for Weekly Repeat",
                    selection: $weeklyRepeatEndTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .accessibilityLabel("Weekly Repeat End Time Picker")
            }
        }
    }
    
    // Custom Repeat Options View
    private var customRepeatOptions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Days of the Week")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            // Days of the Week Buttons
            HStack {
                ForEach(1...7, id: \.self) { day in
                    Button(action: {
                        toggleDaySelection(day)
                    }) {
                        Text(shortDayName(from: day))
                            .font(.caption)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(customRepeatDays.contains(day) ? Color.accentColor : Color.gray.opacity(0.2))
                            .foregroundColor(customRepeatDays.contains(day) ? .white : .primary)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("\(fullDayName(from: day))")
                }
            }
            
            // Repeat Time
            VStack(alignment: .leading, spacing: 8) {
                Text("Repeat Time")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                DatePicker(
                    "Select Time for Custom Repeat",
                    selection: $weeklyRepeatTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.automatic)
                .labelsHidden()
                .accessibilityLabel("Custom Repeat Time Picker")
            }
        }
    }
    
    // Notifications Toggle
    private var notificationsToggle: some View {
        VStack {
            Toggle(isOn: $showNotificationsToggle) {
                Label("Enable Notifications", systemImage: "bell.fill")
                    .foregroundColor(.accentColor)
            }
        
            HStack(alignment: .center, spacing: 8) {
                Text("Alert")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                
                Picker("", selection: $reminderTime) {
                    ForEach(ReminderTime.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.automatic)
                .disabled(!showNotificationsToggle)
                .accessibilityLabel("Reminder Time Picker")
            }
        }
    }
    
    // Color Picker Section
    private var colorPickerSection: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("Lecture Color")
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            
            ColorPicker("Choose a color", selection: $selectedColor)
                .labelsHidden()
                .accessibilityLabel("Event Color Picker")
        }
    }
    
    // MARK: - Helper Methods
    
    // Formats the date for display
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = isAllDay ? .none : .short
        return formatter.string(from: date)
    }
    
    // Returns full day name from integer (1 = Sunday, 7 = Saturday)
    private func fullDayName(from day: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[day - 1]
    }
    
    // Returns short day name from integer (1 = Sunday, 7 = Saturday)
    private func shortDayName(from day: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols[day - 1].uppercased()
    }
    
    // Adds or removes a day from the custom repeat days
    private func toggleDaySelection(_ day: Int) {
        if let index = customRepeatDays.firstIndex(of: day) {
            customRepeatDays.remove(at: index)
        } else {
            customRepeatDays.append(day)
        }
    }
    
    // Generates repeatSlots based on selected days
    private func customRepeatSlots() -> [(dayOfWeek: Int, startTime: Date, endTime: Date)] {
        customRepeatDays.map { day in
            // Extract the time components from dailyRepeatTime and weeklyRepeatTime
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.hour, .minute], from: isAllDay ? startDate : dailyRepeatTime)
            let endComponents = calendar.dateComponents([.hour, .minute], from: isAllDay ? endDate : weeklyRepeatTime)
            
            // Create new Date objects for the specific day with the same time
            var startTimeComponents = DateComponents()
            startTimeComponents.weekday = day
            if !isAllDay {
                startTimeComponents.hour = startComponents.hour
                startTimeComponents.minute = startComponents.minute
            }
            let startTime = calendar.nextDate(after: Date(), matching: startTimeComponents, matchingPolicy: .nextTimePreservingSmallerComponents) ?? startDate
            
            var endTimeComponents = DateComponents()
            endTimeComponents.weekday = day
            if !isAllDay {
                endTimeComponents.hour = endComponents.hour
                endTimeComponents.minute = endComponents.minute
            }
            let endTime = calendar.nextDate(after: Date(), matching: endTimeComponents, matchingPolicy: .nextTimePreservingSmallerComponents) ?? endDate
            
            return (dayOfWeek: day, startTime: startTime, endTime: endTime)
        }
    }
    
    // Adds the event to the data source
    private func addEvent() {
        // Validate inputs
        guard !eventTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter a title for the event."
            showAlert = true
            return
        }
        
        // Validate date and time
        guard endDate > startDate else {
            alertMessage = "End date and time must be after the start date and time."
            showAlert = true
            return
        }
        
        // If repeat is custom or weekly, ensure at least one day is selected
        if (repeatOption == .custom || repeatOption == .weekly) && customRepeatDays.isEmpty {
            alertMessage = "Please select at least one day for repeat."
            showAlert = true
            return
        }
        
        // If repeat is daily or weekly, ensure repeat times are set
        if repeatOption == .daily && isAllDay == false {
            // Ensure dailyRepeatTime is set (already handled by binding)
        }
        
        if repeatOption == .weekly && isAllDay == false {
            // Ensure weeklyRepeatTime is set (already handled by binding)
        }
        
        // Create the event
        let newEvent = Event(
            id: UUID(),
            title: eventTitle,
            type: eventType,
            location: eventLocation.isEmpty ? nil : eventLocation,
            notes: eventNotes.isEmpty ? nil : eventNotes,
            isAllDay: isAllDay,
            startDate: startDate,
            endDate: endDate,
            repeatOption: repeatOption,
            repeatSlots: (repeatOption == .custom || repeatOption == .weekly || repeatOption == .daily) ? customRepeatSlots() : nil,
            color: selectedColor
        )
        
        // Add the event to your data source
        calendarViewModel.addEvent(newEvent)
        
        // Optionally, set up notifications here based on reminder settings
        
        // Dismiss the sheet
        dismiss()
    }
}

enum ReminderTime: String, CaseIterable {
    case atTime = "At Time"
    case tenMinutesBefore = "10 Minutes Before"
    case thirtyMinutesBefore = "30 Minutes Before"
    case oneHourBefore = "1 Hour Before"
    case oneDayBefore = "1 Day Before"
}

// MARK: - Preview

struct AddEventSheetView_Previews: PreviewProvider {
    static var previews: some View {
        // Example: Preview for Lecture
        AddEventSheetView(eventType: .lecture)
            .environmentObject(CalendarViewModel())
        
        // Example: Preview for Exam
        AddEventSheetView(eventType: .exam)
            .environmentObject(CalendarViewModel())
        
        AddEventSheetView(eventType: .task)
            .environmentObject(CalendarViewModel())
        
        AddEventSheetView(eventType: .homework)
            .environmentObject(CalendarViewModel())
    }
}
