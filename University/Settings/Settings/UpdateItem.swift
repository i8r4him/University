import Foundation

struct UpdateItem: Identifiable {
    let id = UUID()
    let version: String
    let date: String
    let features: [String]
    var isExpanded: Bool = true
}

