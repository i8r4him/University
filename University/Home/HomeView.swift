import SwiftUI
import Charts

struct HomeView: View {
    @ObservedObject var subjectsViewModel: SubjectsViewModel
    @ObservedObject var calendarViewModel: CalendarViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showingTimerSheet = false
    @State private var showingEventSheet = false
    @State private var showingSubjectSheet = false

    var completionRatio: CGFloat {
        guard subjectsViewModel.targetCredits > 0 else { return 0 }
        let total = CGFloat(subjectsViewModel.targetCredits)
        let completed = CGFloat(subjectsViewModel.subjects.reduce(0) { $0 + $1.credits })
        return min(completed / total, 1) // Ensure the ratio doesn't exceed 1
    }

    private var todayEvents: [Event] {
        let today = Date()
        return calendarViewModel.eventsForDate(today) // Ensure that the 'eventsForDate' method returns a [Event].
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                // Conditional grid based on device type
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    horizontalSizeClass == .regular ? GridItem(.flexible()) : nil
                ].compactMap { $0 }, spacing: 24) {
                    // Focus Timer Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "timer")
                                .font(.system(size: horizontalSizeClass == .regular ? 36 : 30))
                                .foregroundColor(.accentColor)
                            Spacer()
                            Button(action: { showingTimerSheet = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: horizontalSizeClass == .regular ? 24 : 20))
                            }
                        }
                        
                        Text("Focus Timer")
                            .font(.system(size: horizontalSizeClass == .regular ? 28 : 24, weight: .semibold))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Focus")
                                .font(.headline)
                            Text("120 minutes")
                                .font(.system(size: horizontalSizeClass == .regular ? 34 : 30, weight: .bold))
                                .foregroundColor(.accentColor)
                        }
                        
                        // Quick Timer Buttons
                        HStack(spacing: 12) {
                            ForEach([25, 45, 60], id: \.self) { minutes in
                                Button(action: {}) {
                                    Text("\(minutes)m")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(horizontalSizeClass == .regular ? 24 : 16)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Today's Events Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: horizontalSizeClass == .regular ? 36 : 30))
                                .foregroundColor(.accentColor)
                            Spacer()
                            Button(action: { showingEventSheet = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: horizontalSizeClass == .regular ? 24 : 20))
                            }
                        }
                        
                        Text("Today's Events")
                            .font(.system(size: horizontalSizeClass == .regular ? 28 : 24, weight: .semibold))
                        
                        if todayEvents.isEmpty {
                            VStack(spacing: 8) {
                                Text("No events today")
                                    .font(.headline)
                                Button("Add Event") {
                                    showingEventSheet = true
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                        } else {
                            ForEach(todayEvents) { event in
                                HStack {
                                    Rectangle()
                                        .fill(event.color)
                                        .frame(width: 4)
                                    VStack(alignment: .leading) {
                                        Text(event.title)
                                            .font(.headline)
                                        Text(formattedTime(event.startDate))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.leading, 8)
                                }
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(horizontalSizeClass == .regular ? 24 : 16)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Progress Chart Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: horizontalSizeClass == .regular ? 36 : 30))
                                .foregroundColor(.accentColor)
                            Spacer()
                            Button(action: { showingSubjectSheet = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: horizontalSizeClass == .regular ? 24 : 20))
                            }
                        }
                        
                        Text("Academic Progress")
                            .font(.system(size: horizontalSizeClass == .regular ? 28 : 24, weight: .semibold))
                        
                        // Progress view
                        ProgressView(value: Double(completionRatio))
                            .accentColor(.green)
                            .scaleEffect(x: 1, y: horizontalSizeClass == .regular ? 6 : 4, anchor: .center)
                            .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
                        
                        HStack {
                            let completedCredits = subjectsViewModel.subjects.reduce(0) { $0 + $1.credits }
                            let toGo = max(subjectsViewModel.targetCredits - completedCredits, 0)
                            
                            Label("\(completedCredits) Completed", systemImage: "checkmark.circle")
                                .font(horizontalSizeClass == .regular ? .callout : .caption)
                            Spacer()
                            Label("\(toGo) To Go", systemImage: "hourglass.bottomhalf.fill")
                                .font(horizontalSizeClass == .regular ? .callout : .caption)
                        }
                        .foregroundColor(.accentColor)
                    }
                    .padding(horizontalSizeClass == .regular ? 24 : 16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    // Make chart card full width only on iPad
                    .gridCellColumns(horizontalSizeClass == .regular ? 2 : 1)
                }
                .padding(horizontalSizeClass == .regular ? 24 : 16)
            }
            .navigationTitle("Home")
        }
        // Sheet modifiers will be added when implementing functionality
    }
    
    @ViewBuilder
    func summaryCard(title: String, systemImage: String, description: String, backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Spacer()
            }

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }

    private var todayEventsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sun.horizon.fill")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Spacer()
            }

            Text("Today's Events")
                .font(.title2)
                .fontWeight(.semibold)

            if todayEvents.isEmpty {
                Text("No events today.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(todayEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.headline)
                        if let location = event.location {
                            Text(location)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Text("\(formattedTime(event.startDate)) - \(formattedTime(event.endDate))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// PREVIEW
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let subjectsViewModel = SubjectsViewModel()
        let calendarViewModel = CalendarViewModel()
        HomeView(subjectsViewModel: subjectsViewModel, calendarViewModel: calendarViewModel)
    }
}
