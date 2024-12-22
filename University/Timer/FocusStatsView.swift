import SwiftUI

struct FocusStatsView: View {
    @ObservedObject var viewModel: FocusStatsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Productivity")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                // Period Selector
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(FocusStatsViewModel.Period.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                statsCard(
                    title: "Focus Time",
                    total: viewModel.totalFocus,
                    average: viewModel.averageFocusPerDay,
                    accentColor: .yellow
                )
                
                if viewModel.totalFocus == 0 {
                    noDataView()
                } else {
                    dayBreakdownView(for: .focus)
                }
                
                statsCard(
                    title: "Break Time",
                    total: viewModel.totalBreak,
                    average: viewModel.averageBreakPerDay,
                    accentColor: .green
                )
                
                if viewModel.totalBreak == 0 {
                    noDataView()
                } else {
                    dayBreakdownView(for: .break)
                }
                
                Spacer(minLength: 40)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func statsCard(title: String, total: Int, average: Int, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: title.contains("Focus") ? "figure.run" : "cup.and.saucer.fill")
                    .font(.headline)
                    .foregroundColor(accentColor)
                Spacer()
                Text(viewModel.selectedPeriod.rawValue)
                    .font(.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            HStack(spacing: 40) {
                VStack(alignment: .leading) {
                    Text("Total")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text("\(total/60)min")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading) {
                    Text("Average")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text("\(average/60)min / day")
                        .font(.headline)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func noDataView() -> some View {
        Text("No recorded time for this period.")
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)
        
        dayLabelsView()
    }
    
    @ViewBuilder
    private func dayBreakdownView(for type: SessionType) -> some View {
        // Simple placeholder: Just show day labels and pretend some bars or data
        // In a real app, you'd map filteredSessions by day and show totals.
        
        // For simplicity, just show day labels:
        Text("Daily Breakdown (Not fully implemented)")
            .font(.footnote)
            .foregroundColor(.gray)
            .padding(.horizontal)
        
        dayLabelsView()
    }
    
    @ViewBuilder
    private func dayLabelsView() -> some View {
        HStack {
            ForEach(["Wed", "Thu", "Fri", "Sat", "Sun", "Mon", "Tue"], id: \.self) { day in
                Text(day)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}
