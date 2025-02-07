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
    
    // Add property for sidebar collapse state
    @State private var isSidebarCollapsed = false
    
    // Add property for active tab highlight
    @State private var activeTabColor = Color.accentColor.opacity(0.1)
    
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


            TabSection("Utilities") {
                Tab("Study Plan", systemImage: "calendar.badge.clock", value: Tabs.studyPlan) {
                    CalendarView(viewModel: calendarViewModel)
                }
               
                .customizationID(Tabs.studyPlan.customizationID)
                /*
                Tab("Focus", systemImage: "timer.circle.fill", value: Tabs.focus) {
                    FocusView()
                        .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                }
                .customizationID(Tabs.focus.customizationID)
                */
            }
            .customizationID("com.createchsol.myApp.mainSection")
            
            TabSection("Productivity") {
                Tab("Progress", systemImage: "chart.bar.xaxis.ascending", value: Tabs.progress) {
                    ChartView(viewModel: subjectsViewModel)
                }
                .customizationID(Tabs.progress.customizationID)
            }
            
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsView(viewModel: SettingsViewModel())
            }
            .customizationID(Tabs.settings.customizationID)
             

        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($customization)
            .tabViewSidebarHeader {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Notiva")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: { isSidebarCollapsed.toggle() }) {
                            Image(systemName: "sidebar.left")
                                .rotationEffect(.degrees(isSidebarCollapsed ? 180 : 0))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Text("Study Better")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .tabViewSidebarBottomBar {
                VStack(spacing: 8) {
                    Divider()
                    Label("Keep Learning!", systemImage: "lightbulb.fill")
                        .font(.footnote)
                        .foregroundStyle(Color.accentColor)
                    Text("Version 1.0")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
    }
}

#Preview {
    ContentView()
}
