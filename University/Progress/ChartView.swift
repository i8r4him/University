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
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.major.isEmpty && viewModel.targetCredits > 0 {
                        Button(action: {
                            viewModel.graphType = viewModel.graphType.next
                        }) {
                            Image(systemName: viewModel.graphType.iconName)
                        }
                    }
                }
                            
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        if viewModel.major.isEmpty {
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }

                        if !viewModel.major.isEmpty && viewModel.targetCredits > 0 {
                            Button(action: {
                                isAdding = true
                            }) {
                                Image(systemName: "plus")
                            }
                            
                            // Updated Menu Button
                            Menu {
                                Button(action: {
                                    rateAchievements()
                                }) {
                                    Label("Rate Progress", systemImage: "wand.and.sparkles")
                                        .symbolRenderingMode(.hierarchical)
                                }
                                
                                Button(action: {
                                    uploadSyllabus()
                                }) {
                                    Label("Upload a syllabus", systemImage: "document.badge.arrow.up.fill")
                                }
                            } label: {
                                Image(systemName: "sparkles")
                            }
                        }
                        
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
            // File Importer Modifier
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.pdf, .plainText], // Adjust based on allowed types
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        handleUploadedFile(url)
                    }
                case .failure(let error):
                    print("File import failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Major: \(viewModel.major)")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top)
                .foregroundStyle(Color.secondary)
                .padding(.horizontal)

            Chart {
                ForEach(chartData.sorted { $0.credits > $1.credits }) { subject in
                    SectorMark(
                        angle: .value("Credits", subject.credits),
                        innerRadius: .ratio(viewModel.graphType == .donut ? 0.61 : 0),
                        angularInset: viewModel.graphType == .donut ? 6 : 1
                    )
                    .cornerRadius(8)
                    .foregroundStyle(subject.subjectName == "Remaining" ? Color.gray : subject.color)
                }
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: 25)
            .chartYScale(domain: 0...Double(viewModel.targetCredits > 0 ? viewModel.targetCredits : 180))
            .frame(height: 250)
            .padding(.top, 10)

            HStack {
                Text("Completed: \(completedCredits)")
                    .font(.subheadline)
                    .foregroundColor(Color.accentColor)
                Spacer()
                Text("Remaining: \(remainingCredits)")
                    .font(.subheadline)
                    .foregroundColor(Color.accentColor)
            }
            .padding([.horizontal, .bottom])

            List {
                ForEach(viewModel.subjects) { subject in
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(subject.color)
                            .frame(width: 8, height: 50)

                        VStack(alignment: .leading) {
                            Text(subject.subjectName)
                                .font(.headline)
                            Text("\(subject.type) • Credits: \(Int(subject.credits))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            selectedSubject = subject
                            isEditing = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .onDelete(perform: deleteSubject)
            }
            .listStyle(PlainListStyle())
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
