// New file: EventSectionView.swift
import SwiftUI

struct EventSectionView: View {
    let title: String
    let systemImage: String
    let events: [Event]
    let onEdit: (Event) -> Void
    let onDelete: (Event) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                Text(title)
                    .font(.title3)
                    .bold()
            }
            .padding()
            
            if events.isEmpty {
                placeholderRow("No \(title.lowercased()) events")
            } else {
                ForEach(events) { event in
                    EventRowView(event: event, onEdit: {
                        onEdit(event)
                    }, onDelete: {
                        onDelete(event)
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

