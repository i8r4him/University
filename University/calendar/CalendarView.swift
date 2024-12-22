//
//  CombinedCalendarView.swift
//  University
//
//  Created by Ibrahim Abdullah on 15.12.24.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    
    @ObservedObject var viewModel = CalendarViewModel()
    @State private var showSheet = false
    @State private var showAddEvent = false
    @State private var editedEvent: Event? = nil
    @State private var selectedEventType: EventType = .lecture
    
    // Use a stable base date (the current week's start) that never changes.
    private let baseDate: Date = {
        Calendar.current.startOfWeek(for: Date()) ?? Date()
    }()
    
    // weeks is derived from a stable base date, not the viewModel.
    var weeks: [Date] {
        let cal = Calendar.current
        return (-2...2).compactMap { offset in
            cal.date(byAdding: .weekOfYear, value: offset, to: baseDate)
        }
    }

    @State private var selectedWeekIndex = 2
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        NavigationStack {
            // Header and date info...
            HStack(alignment: .top) {
                Text(viewModel.selectedDate.weekdaySymbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(y: 19)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(viewModel.selectedDate.monthDay)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.secondary)
                    Text(viewModel.selectedDate.year)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.gray.opacity(0.5))
                }
            }
            .onTapGesture {
                impactFeedback.impactOccurred()
                withAnimation {
                    // Reset to current day & current week visually
                    viewModel.selectedDate = Date()
                    if let startOfWeek = Calendar.current.startOfWeek(for: Date()) {
                        viewModel.currentWeekStart = startOfWeek
                    }
                    // Move the pager back to the middle (current week)
                    selectedWeekIndex = 2
                }
            }
            .padding()
            
            weekPagerSection
                .padding(.vertical, -25)
                .onAppear {
                    viewModel.selectedDate = Date()
                    if let startOfWeek = Calendar.current.startOfWeek(for: Date()) {
                        viewModel.currentWeekStart = startOfWeek
                    }
                    selectedWeekIndex = 2
                }
                .onChange(of: selectedWeekIndex) { oldIndex,newIndex in
                    if weeks.indices.contains(newIndex) {
                        let newWeekStart = weeks[newIndex]
                        // Update the model to the new week.
                        // This does not change 'weeks' because 'weeks' is fixed.
                        viewModel.currentWeekStart = newWeekStart
                        viewModel.selectedDate = newWeekStart
                    }
                }

            // List with morning, day, night sections...
            List {
                VStack(alignment: .leading, spacing: 15) {
                    morningSection
                    Divider()
                    daySection
                    Divider()
                    nightSection
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 20) {
                        Button(action: {
                            editedEvent = nil
                            showAddEvent = true
                        }) {
                            Image(systemName: "calendar")
                                .foregroundColor(Color.accentColor)
                        }
                        .sheet(item: $editedEvent) { event in
                            AddOrEditEventView(event: event) { updatedEvent in
                                viewModel.updateEvent(updatedEvent)
                            }
                        }
                        .sheet(isPresented: $showAddEvent) {
                            AddOrEditEventView { newEvent in
                                viewModel.addEvent(newEvent)
                            }
                        }

                        Menu {
                            Button {
                                showSheet = true
                            } label: {
                                Label("Lecture", systemImage: "inset.filled.rectangle.and.person.filled")
                            }
                            
                            Button {
                                // Add Exam event code
                            } label: {
                                Label("Exam date", systemImage: "pencil.and.list.clipboard")
                            }
                            Button {
                                // Add Homework event code
                            } label: {
                                Label("Homework", systemImage: "pencil.and.ruler")
                            }
                            Button {
                                // Add Task event code
                            } label: {
                                Label("Task", systemImage: "checklist")
                            }
                        } label: {
                            Label("Add New", systemImage: "plus")
                        }
                        .sheet(isPresented: $showSheet) {
                            AddEventSheetView(eventType: selectedEventType)
                                .presentationCornerRadius(10)
                                //.presentationDetents([.height(260)])
                                .presentationDragIndicator(.hidden)
                        }
                    }
                }
            }
        }
    }

    private var weekPagerSection: some View {
        TabView(selection: $selectedWeekIndex) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { index, startOfWeek in
                weekView(for: startOfWeek)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 100)
    }

    private func weekView(for startOfWeek: Date) -> some View {
        let cal = Calendar.current
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }

        return GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let dayWidth = totalWidth / 7

            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    let isSelected = cal.isDate(viewModel.selectedDate, inSameDayAs: day)
                    SelectedDayView(viewModel: viewModel, date: day, isSelected: isSelected)
                        .frame(width: dayWidth, height: dayWidth)
                        .onTapGesture {
                            impactFeedback.impactOccurred()
                            withAnimation {
                                viewModel.selectedDate = day
                            }
                        }
                }
            }
            .frame(width: totalWidth, height: dayWidth)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    // MARK: - Event Sections
    var morningEvents: [Event] {
        eventsForTimeRange(startHour: 0, endHour: 11)
    }
    var dayEvents: [Event] {
        eventsForTimeRange(startHour: 12, endHour: 17)
    }
    var nightEvents: [Event] {
        eventsForTimeRange(startHour: 18, endHour: 23)
    }

    private func eventsForTimeRange(startHour: Int, endHour: Int) -> [Event] {
        let calendar = Calendar.current
        return viewModel.eventsForSelectedDate.filter { event in
            let hour = calendar.component(.hour, from: event.startDate)
            return hour >= startHour && hour <= endHour
        }
    }

    private var morningSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sunrise.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                Text("Morning")
                    .font(.title3)
                    .bold()
            }
            .padding()

            if morningEvents.isEmpty {
                placeholderRow("No morning events")
            } else {
                ForEach(morningEvents) { event in
                    EventRowView(event: event, onEdit: {
                        editedEvent = event
                    }, onDelete: {
                        withAnimation {
                            viewModel.removeEvent(event)
                        }
                    })
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    private var daySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sun.max.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                Text("Day")
                    .font(.title3)
                    .bold()
            }
            .padding()

            if dayEvents.isEmpty {
                placeholderRow("No day events")
            } else {
                ForEach(dayEvents) { event in
                    EventRowView(event: event, onEdit: {
                        editedEvent = event
                    }, onDelete: {
                        withAnimation {
                            viewModel.removeEvent(event)
                        }
                    })
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    private var nightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                Text("Night")
                    .font(.title3)
                    .bold()
            }
            .padding()

            if nightEvents.isEmpty {
                placeholderRow("No night events")
            } else {
                ForEach(nightEvents) { event in
                    EventRowView(event: event, onEdit: {
                        editedEvent = event
                    }, onDelete: {
                        withAnimation {
                            viewModel.removeEvent(event)
                        }
                    })
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    private func placeholderRow(_ text: String) -> some View {
        Text(text)
            .font(.callout)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 100)
    }
}

extension Date {
    var weekdaySymbol: String {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return df.string(from: self)
    }
    
    var monthDay: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d"
        return df.string(from: self)
    }
    
    var year: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        return df.string(from: self)
    }
}

#Preview {
    CalendarView(viewModel: CalendarViewModel())
}
