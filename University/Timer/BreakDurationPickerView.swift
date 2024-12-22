import SwiftUI

struct BreakDurationPickerView: View {
    @Binding var breakTotal: Double
    @Binding var showPicker: Bool
    
    let options: [Int] = [5, 10, 15, 25, 45, 60]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(options, id: \.self) { minutes in
                    Button(action: {
                        breakTotal = Double(minutes * 60)
                        showPicker = false
                    }) {
                        Text("\(minutes) min")
                    }
                }
            }
            .navigationTitle("Select Break Duration")
            .navigationBarItems(trailing:
                Button("Done") {
                    showPicker = false
                }
            )
        }
    }
}
