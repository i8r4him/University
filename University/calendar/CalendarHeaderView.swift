
import SwiftUI

struct CalendarHeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var selectedWeekIndex: Int
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack(alignment: .top) {
            Text(viewModel.selectedDate.weekdaySymbol)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .offset(y: 19)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(viewModel.selectedDate.monthDay)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.secondary)
                Text(viewModel.selectedDate.year)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .onTapGesture {
            impactFeedback.impactOccurred()
            
            // First update the week index
            selectedWeekIndex = 2 // Center week
            
            // Then update the date after a very short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                viewModel.forceUpdateToToday()
            }
        }
        .padding()
    }
}
