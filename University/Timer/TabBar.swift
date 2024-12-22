//
//  TabBar.swift
//  University
//
//  Created by Ibrahim Abdullah on 15.12.24.
//

import SwiftUI

struct TabBar: View {
    let tabs: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        GeometryReader { geometry in
            let tabWidth = max(0, geometry.size.width / CGFloat(max(tabs.count, 1)))
            
            ZStack(alignment: .leading) {
                // Sliding Background
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: tabWidth - 10, height: 40)
                    .offset(x: CGFloat(selectedIndex) * tabWidth + 5)
                    .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                
                // Tab Buttons
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                selectedIndex = index
                            }
                        }) {
                            Text(tabs[index])
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(selectedIndex == index ? Color.accentColor : Color.primary)
                                .frame(width: tabWidth, height: 40)
                        }
                    }
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 10)
    }
}

struct TabBar_Previews: PreviewProvider {
    @State static var selectedIndex = 0
    
    static var previews: some View {
        TabBar(tabs: ["Pomodoro 🍅", "Break ☕️", "Stopwatch 🕒"], selectedIndex: $selectedIndex)
            .previewLayout(.sizeThatFits)
    }
}
