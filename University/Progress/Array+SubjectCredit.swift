//
//  Array+SubjectCredit.swift
//  University
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import Foundation
import SwiftUI

extension Array where Element == SubjectCredit {
    func findCredits(_ subject: String) -> Int? {
        return self.first(where: { $0.subjectName == subject })?.credits
    }
    
    func index(of subject: String) -> Int? {
        return self.firstIndex(where: { $0.subjectName == subject })
    }
}
