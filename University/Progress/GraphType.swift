//
//  GraphType.swift
//  University
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import Foundation

enum GraphType {
    case pie, donut
    
    var iconName: String {
        switch self {
        case .pie: return "chart.pie"
        case .donut: return "chart.pie.fill"
        }
    }

    
    var next: GraphType {
        self == .pie ? .donut : .pie
    }
}
