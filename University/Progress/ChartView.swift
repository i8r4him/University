//
//  ChartView.swift
//  University
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import SwiftUI
import Charts

struct ChartView: View {
    
    @ObservedObject var viewModel: SubjectsViewModel
    @State private var isAdding = false
    @State private var isEditing = false
    @State private var selectedSubject: SubjectCredit?
    @State private var showingSettings = false
    
    // New State Variables for Menu Actions
    @State private var showingRateAlert = false
    @State private var showingRateAchievements = false
    @State private var showingFileImporter = false
    @State private var uploadedFileURL: URL?
    @State private var showingProgressRating = false
    
    @Environment(\.dismiss) var dismiss

    private var chartData: [SubjectCredit] {
        let totalCredits = viewModel.subjects.reduce(0) { $0 + $1.credits }
        if viewModel.targetCredits > 0 && totalCredits < viewModel.targetCredits {
            let missingCredits = viewModel.targetCredits - totalCredits
            return viewModel.subjects + [SubjectCredit(subjectName: "Remaining", credits: missingCredits, color: .gray, type: "Sonstiges")]
        } else {
            return viewModel.subjects
        }
    }

    private var remainingCredits: Int {
        guard viewModel.targetCredits > 0 else { return 0 }
        let totalCredits = viewModel.subjects.reduce(0) { $0 + $1.credits }
        return max(0, viewModel.targetCredits - totalCredits)
    }

    private var completedCredits: Int {
        viewModel.subjects.reduce(0) { $0 + $1.credits }
    }

    @State private var selectedType: String?
    @State private var searchText = ""
    
    private var filteredSubjects: [SubjectCredit] {
        let subjects = viewModel.subjects
        let filteredByType = selectedType == nil ? subjects : subjects.filter { $0.type == selectedType }
        return searchText.isEmpty ? filteredByType : filteredByType.filter { $0.subjectName.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var subjectTypes: [String] {
        Array(Set(viewModel.subjects.map { $0.type })).sorted()
    }

    @State private var showingDeleteConfirmation = false
    @State private var subjectToDelete: SubjectCredit?

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.major.isEmpty || viewModel.targetCredits == 0 {
                    ContentUnavailableView("No goal set", systemImage: "chart.pie.fill", description: Text("Please set your Major and Required Credits."))
                } else {
                    contentView
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isAdding = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAdding) {
                SubjectFormView(isPresented: $isAdding, viewModel: viewModel)
                    .presentationCornerRadius(15)
                    .presentationDetents([.medium])
            }
            .sheet(item: $selectedSubject) { subject in
                SubjectFormView(isPresented: $isEditing, viewModel: viewModel, subjectToEdit: subject)
                    .presentationCornerRadius(15)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingSettings) {
                SettingsFormView(isPresented: $showingSettings, major: $viewModel.major, targetCredits: $viewModel.targetCredits)
                    .onDisappear {
                        viewModel.saveSettings(major: viewModel.major, targetCredits: viewModel.targetCredits)
                    }
                    .presentationCornerRadius(15)
                    .presentationDetents([.medium])
            }
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Add a progress card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.major)
                                .font(.title3)
                                .fontWeight(.medium)
                            Text("Progress Overview")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        }
                        Spacer()
                        Text("\(Int((Double(completedCredits) / Double(viewModel.targetCredits)) * 100))%")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal)

                Chart {
                    ForEach(chartData.sorted { $0.credits > $1.credits }) { subject in
                        SectorMark(
                            angle: .value("Credits", subject.credits),
                            innerRadius: .ratio(0.84),
                            angularInset: 3
                        )
                        .cornerRadius(10)
                        .foregroundStyle(subject.subjectName == "Remaining" ? Color.gray.opacity(0.3) : subject.color)
                    }
                }
                .chartLegend(position: .bottom, alignment: .center, spacing: 20)
                .chartYScale(domain: 0...Double(viewModel.targetCredits > 0 ? viewModel.targetCredits : 180))
                .frame(height: 250)
                .padding(.vertical)
                .overlay {
                    VStack(spacing: 4) {
                        Text("\(completedCredits)")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.primary)
                        Text("of \(viewModel.targetCredits)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Enhanced My Subjects section with refined boxes
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("My Subjects")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(viewModel.subjects.count) total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search subjects", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Type filters with larger size
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(subjectTypes, id: \.self) { type in
                                Button(action: {
                                    selectedType = selectedType == type ? nil : type
                                }) {
                                    Text(type)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedType == type ? Color.accentColor : Color(.systemGray6))
                                        .foregroundColor(selectedType == type ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                    }
                    
                    // Refined subject boxes
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                        ForEach(filteredSubjects) { subject in
                            VStack(alignment: .leading, spacing: 12) {
                                // Top section with color and type
                                HStack {
                                    Circle()
                                        .fill(subject.color)
                                        .frame(width: 10, height: 10)
                                    Text(subject.type)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                // Subject name with more space
                                Text(subject.subjectName)
                                    .font(.headline)
                                    .lineLimit(2)
                                
                                // Credits with color emphasis
                                Text("\(Int(subject.credits)) Credits")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(subject.color)
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                // Refined action buttons
                                HStack(spacing: 16) {
                                    Spacer()
                                    
                                    Button {
                                        selectedSubject = subject
                                        isEditing = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        subjectToDelete = subject
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary.opacity(0.8))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            "Delete Subject",
            isPresented: $showingDeleteConfirmation,
            presenting: subjectToDelete
        ) { subject in
            Button("Delete \(subject.subjectName)", role: .destructive) {
                if let index = viewModel.subjects.firstIndex(where: { $0.id == subject.id }) {
                    deleteSubject(at: IndexSet([index]))
                }
            }
        } message: { subject in
            Text("Are you sure you want to delete this subject? This action cannot be undone.")
        }
    }

    private func deleteSubject(at offsets: IndexSet) {
        offsets.forEach { index in
            let subject = viewModel.subjects[index]
            viewModel.deleteSubject(subject)
        }
    }
    
    // MARK: - Action Functions
    // Function to handle "Rate my achievements"
    private func rateAchievements() {
        showingProgressRating = true
    }
    
    // Function to handle "Upload a syllabus"
    private func uploadSyllabus() {
        showingFileImporter = true
    }
    
    // Function to handle the uploaded file
    private func handleUploadedFile(_ url: URL) {
        // Example: Print the file URL
        print("Uploaded syllabus file URL: \(url)")
        
        // TODO: Add your file handling logic here
    }
}

#Preview {
    ChartView(viewModel: SubjectsViewModel())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
