import Foundation

class WhatsNewViewModel: ObservableObject {
    @Published var updates: [UpdateItem] = [
        UpdateItem(
            version: "1.0.0",
            date: "January 2024",
            features: [
                "Initial release of Notiva",
                "Smart note-taking with rich text support",
                "Calendar integration for better organization",
                "Focus mode for distraction-free work",
                "Progress tracking and insights",
                "Customizable app themes and appearance",
                "Cloud sync and backup"
            ]
        )
    ]
    
    func toggleExpansion(for index: Int) {
        guard index < updates.count else { return }
        updates[index].isExpanded.toggle()
    }
}

