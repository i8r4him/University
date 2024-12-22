//
//  calendarinfo.swift
//  University
//
//  Created by Ibrahim Abdullah on 15.12.24.
//

import SwiftUI

enum EventType: String, CaseIterable, Identifiable {
    case lecture = "Lecture"
    case exam = "Exam Date"
    case homework = "Homework"
    case task = "Task"
    
    var id: String { self.rawValue } // Make EventType identifiable
}

enum RepeatOption: String, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case custom = "Custom"
}

struct Event: Identifiable {
    let id: UUID
    var title: String
    var type: EventType
    var location: String?
    var notes: String?
    var isAllDay: Bool
    var startDate: Date
    var endDate: Date
    var repeatOption: RepeatOption
    var repeatSlots: [(dayOfWeek: Int, startTime: Date, endTime: Date)]?
    var color: Color
}

