import SwiftUI
import Charts

struct HomeView: View {
    @ObservedObject var subjectsViewModel: SubjectsViewModel
    @ObservedObject var calendarViewModel: CalendarViewModel

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
                VStack(spacing: 20) {
                    Text("Welcome Back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)

                    Text("Here’s a quick overview of your academic tools:")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    summaryCard(
                        title: "Focus Timer",
                        systemImage: "timer",
                        description: "Improve productivity with timed focus sessions.",
                        backgroundColor: Color.blue.opacity(0.1)
                    )
                    
                    todayEventsCard

                    // Charts Card now uses SubjectsViewModel data
                    let completedCredits = subjectsViewModel.subjects.reduce(0) { $0 + $1.credits }
                    let toGo = max(subjectsViewModel.targetCredits - completedCredits, 0) // Prevent negative values

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .font(.largeTitle)
                                //.symbolRenderingMode(.palette)
                                .foregroundColor(.accentColor)
                            Spacer()
                        }

                        Text("Charts")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Track how close you are to your credit goals.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ProgressView(value: Double(completionRatio))
                            .accentColor(.green)
                            .scaleEffect(x: 1, y: 4, anchor: .center) // Increase height
                            .padding(.vertical, 8)

                        HStack {
                            Label("\(completedCredits) Completed", systemImage: "checkmark.circle")
                                .font(.footnote)
                                .foregroundColor(Color.accentColor)
                            Spacer()
                            Label("\(toGo) To Go", systemImage: "hourglass.bottomhalf.fill")
                                .font(.footnote)
                                .foregroundColor(Color.accentColor)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Home")
        }
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
