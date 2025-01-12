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
    @State private var forceRefresh: Bool = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
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
            CalendarHeaderView(viewModel: viewModel, selectedWeekIndex: $selectedWeekIndex)
            
            WeekPagerView(viewModel: viewModel, selectedWeekIndex: $selectedWeekIndex, weeks: weeks)
                .padding(.vertical, -25)
                .onAppear {
                    let today = Date()
                    selectedWeekIndex = 2
                    viewModel.selectedDate = today
                    if let startOfWeek = Calendar.current.startOfWeek(for: today) {
                        viewModel.currentWeekStart = startOfWeek
                    }
                }

            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                let sectionHeight = screenHeight / 3 // Divide screen into three equal parts
                
                List {
                    VStack(alignment: .leading, spacing: 15) {
                        EventSectionView(title: "Morning", systemImage: "sunrise.fill",
                            events: eventsForTimeRange(startHour: 0, endHour: 11), onEdit: { editedEvent = $0 },
                            onDelete: { viewModel.removeEvent($0) })
                            .frame(height: sectionHeight)
                        
                        Divider()
                        
                        EventSectionView(title: "Day", systemImage: "sun.max.fill",
                            events: eventsForTimeRange(startHour: 12, endHour: 17), onEdit: { editedEvent = $0 },
                            onDelete: { viewModel.removeEvent($0) })
                            .frame(height: sectionHeight)
                        
                        Divider()
                        
                        EventSectionView(title: "Night", systemImage: "moon.stars.fill",
                            events: eventsForTimeRange(startHour: 18, endHour: 23), onEdit: { editedEvent = $0 },
                            onDelete: { viewModel.removeEvent($0) })
                            .frame(height: sectionHeight)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            
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

    private func eventsForTimeRange(startHour: Int, endHour: Int) -> [Event] {
        let calendar = Calendar.current
        return viewModel.eventsForSelectedDate.filter { event in
            let hour = calendar.component(.hour, from: event.startDate)
            return hour >= startHour && hour <= endHour
        }
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

    private var headerSection: some View {
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
            let today = Date()
            withAnimation {
                selectedWeekIndex = 2
                viewModel.selectedDate = today
                if let startOfWeek = Calendar.current.startOfWeek(for: today) {
                    viewModel.currentWeekStart = startOfWeek
                }
            }
        }
        .padding()
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
