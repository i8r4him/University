//
//  ContentView.swift
//  University
//
//  Created by Ibrahim Abdullah on 14.12.24.
//

import SwiftUI

// MARK: - Enums for Sidebar Sections and Items

/// Represents the sections in the sidebar.
enum SidebarSection: String, CaseIterable, Identifiable {
    case main = "Main"
    case tools = "Tools"
    case settings = "Settings"
    
    var id: String { self.rawValue }
}

/// Represents the items in the sidebar.
enum SidebarItem: Hashable, Identifiable {
    case home
    case studyPlan
    case focus
    case achievements
    case settings
    
    var id: Self { self }
    
    /// The display title for the sidebar item.
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .studyPlan:
            return "Study Plan"
        case .focus:
            return "Focus"
        case .achievements:
            return "Achievements"
        case .settings:
            return "Settings"
        }
    }
    
    /// The system image name for the sidebar item.
    var systemImage: String {
        switch self {
        case .home:
            return "house"
        case .studyPlan:
            return "calendar"
        case .focus:
            return "timer"
        case .achievements:
            return "flame"
        case .settings:
            return "gearshape"
        }
    }
    
    /// The section to which the sidebar item belongs.
    var section: SidebarSection {
        switch self {
        case .home, .studyPlan:
            return .main
        case .focus, .achievements:
            return .tools
        case .settings:
            return .settings
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @StateObject var subjectsViewModel = SubjectsViewModel()
    @StateObject var calendarViewModel = CalendarViewModel()
    
    // Detect the horizontal size class to determine device type
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // State to manage the currently selected sidebar item
    @State private var selectedItem: SidebarItem? = .home
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                // TabView for iPhone (Compact Width)
                TabView(selection: $selectedItem) {
                    HomeView(subjectsViewModel: subjectsViewModel, calendarViewModel: calendarViewModel)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(SidebarItem.home)
                    
                    CalendarView(viewModel: calendarViewModel)
                        .tabItem {
                            Label("Study Plan", systemImage: "calendar")
                        }
                        .tag(SidebarItem.studyPlan)
                    
                    TimerView()
                        .tabItem {
                            Label("Focus", systemImage: "timer")
                        }
                        .tag(SidebarItem.focus)
                    
                    ChartView(viewModel: subjectsViewModel)
                        .tabItem {
                            Label("Achievements", systemImage: "flame")
                        }
                        .tag(SidebarItem.achievements)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(SidebarItem.settings)
                }
            } else {
                // NavigationSplitView for iPad (Regular Width)
                NavigationSplitView {
                    // Sidebar with three sections
                    List(selection: $selectedItem) {
                        // Iterate through each section
                        ForEach(SidebarSection.allCases) { section in
                            Section(header: Text(section.rawValue)) {
                                // Filter items belonging to the current section
                                ForEach(items(for: section)) { item in
                                    NavigationLink(value: item) {
                                        Label(item.title, systemImage: item.systemImage)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(SidebarListStyle())
                    .navigationTitle("Notiva")
                    
                } detail: {
                    // Detail View based on selection
                    if let selectedItem = selectedItem {
                        destinationView(for: selectedItem)
                            .navigationTitle(selectedItem.title)
                    } else {
                        Text("Select an item from the sidebar")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            if horizontalSizeClass == .regular {
                // Set default selection for iPad if needed
                selectedItem = .home
            }
        }
    }
    
    /// Returns the sidebar items for a given section.
    /// - Parameter section: The sidebar section.
    /// - Returns: An array of `SidebarItem` belonging to the section.
    func items(for section: SidebarSection) -> [SidebarItem] {
        SidebarItem.allCases.filter { $0.section == section }
    }
    
    /// Returns the appropriate destination view for a given sidebar item.
    /// - Parameter item: The selected sidebar item.
    /// - Returns: The corresponding SwiftUI view.
    @ViewBuilder
    private func destinationView(for item: SidebarItem) -> some View {
        switch item {
        case .home:
            HomeView(subjectsViewModel: subjectsViewModel, calendarViewModel: calendarViewModel)
        case .studyPlan:
            CalendarView(viewModel: calendarViewModel)
        case .focus:
            TimerView()
        case .achievements:
            ChartView(viewModel: subjectsViewModel)
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Extension to make SidebarItem conform to CaseIterable
extension SidebarItem: CaseIterable {
    static var allCases: [SidebarItem] {
        return [.home, .studyPlan, .focus, .achievements, .settings]
    }
}


#Preview {
    ContentView()
}
