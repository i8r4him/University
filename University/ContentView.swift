//
//  ContentView.swift
//  University
//
//  Created by Ibrahim Abdullah on 14.12.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var subjectsViewModel = SubjectsViewModel()
    @StateObject var calendarViewModel = CalendarViewModel()
    
    @State private var selection: Tabs = .home
    @AppStorage("CustomTabcustomization") private var customization: TabViewCustomization
    
    // States for the mini timer overlay
    @State private var showMiniTimer: Bool = false
    @State private var isRunning: Bool = false
    @State private var userPickedMinutes: Int = 25
    
    // State for hiding the mini timer
    @State private var hideMiniTimer: Bool = false
    
    enum Tabs: String {
        case home, studyPlan, focus, progress, store, settings, home1, productivity, utilites, store1
        
        var customizationID: String {
            "com.createchsol.myApp.\(rawValue)"
        }
    }
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: Tabs.home) {
                HomeView(subjectsViewModel: subjectsViewModel, calendarViewModel: calendarViewModel)
            }
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)


            TabSection("Utilites") {
                Tab("Study Plan", systemImage: "calendar", value: Tabs.studyPlan) {
                    CalendarView(viewModel: calendarViewModel)
                }
                //.customizationBehavior(.reorderable, for: .sidebar, .tabBar)
                .customizationID(Tabs.studyPlan.customizationID)
                
                
                Tab("Focus", systemImage: "timer", value: Tabs.focus) {
                    NavigationStack {
                        VStack(spacing: 15) {
                            Text("Focus Timer Example")
                                .font(.title2)
                            
                            // Start button
                            Button("Start 25-Minute Timer") {
                                withAnimation(.snappy) {
                                    isRunning = true
                                    showMiniTimer = true
                                }
                            }
                        }
                        .navigationTitle("Home")
                    }
                }
                .customizationID(Tabs.focus.customizationID)
            }
            //.customizationBehavior(.reorderable, for: .sidebar, .tabBar)
            .customizationID("com.createchsol.myApp.mainSection")
            
            TabSection("Productivity") {
                Tab("Progress", systemImage: "sparkles", value: Tabs.progress) {
                    ChartView(viewModel: subjectsViewModel)
                }
                .customizationID(Tabs.progress.customizationID)
            }
            //.customizationBehavior(.reorderable, for: .sidebar, .tabBar)
            //.customizationID(Tabs.productivity.customizationID)
            
            /*
            TabSection("Store") {
                Tab("Store", systemImage: "cart", value: Tabs.store) {
                    StoreView()
                }
                .customizationID(Tabs.store.customizationID)
            }
            //.customizationBehavior(.reorderable, for: .sidebar, .tabBar)
            .customizationID(Tabs.store1.customizationID)
            
            */
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsView()
            }
            .customizationID(Tabs.settings.customizationID)
             

        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($customization)
            .tabViewSidebarHeader {
                Text("Notiva")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .tabViewSidebarBottomBar {
                Label("Enjoy your App", systemImage: "app.gift")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .foregroundStyle(Color.accentColor)
            }

        .universalOverlay(show: $showMiniTimer) {
            ExpandableTimerPlayer(
                show: $showMiniTimer,
                hideMiniTimer: $hideMiniTimer,
                isRunning: $isRunning,
                selectedMinutes: userPickedMinutes
            )
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
