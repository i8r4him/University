//
//  SubjectCredit.swift
//  University
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import Foundation
import SwiftUI

struct SubjectCredit: Identifiable, Equatable {
    var id: UUID = UUID()
    var subjectName: String
    var credits: Int
    var color: Color
    var type: String
}
