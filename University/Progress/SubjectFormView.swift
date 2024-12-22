//
//  SubjectFormView.swift
//  University
//
//  Created by Ibrahim Abdullah on 19.12.24.
//

import SwiftUI

struct SubjectFormView: View {
    
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: SubjectsViewModel
    var subjectToEdit: SubjectCredit?

    @State private var subjectName: String = ""
    @State private var credits: String = ""
    @State private var selectedColor: Color = .blue
    @State private var selectedType: String = "Pflicht"
    
    let subjectTypes = ["Pflicht", "Wahlpflicht", "Praktikum", "Sonstiges"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Subject Name & Credits")) {
                    TextField("Enter subject", text: $subjectName)
                        .autocapitalization(.words)
                    TextField("Enter number of credits", text: $credits)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Subject Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(subjectTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Color")) {
                    ColorPicker("Select Color", selection: $selectedColor, supportsOpacity: false)
                }
            }
            .navigationTitle(subjectToEdit == nil ? "Add Subject" : "Edit Subject")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button(subjectToEdit == nil ? "Add" : "Save") {
                    saveSubject()
                }
                .disabled(!isFormValid())
            )
            .onAppear {
                if let subject = subjectToEdit {
                    subjectName = subject.subjectName
                    credits = String(subject.credits)
                    selectedColor = subject.color
                    selectedType = subject.type
                }
            }
        }
    }
    
    private func saveSubject() {
        guard let creditCount = Int(credits), !subjectName.isEmpty else {
            return
        }
        
        let id = subjectToEdit?.id ?? UUID() // Reuse the existing ID if editing
        let editedSubject = SubjectCredit(
            id: id,
            subjectName: subjectName,
            credits: creditCount,
            color: selectedColor,
            type: selectedType
        )
        
        viewModel.saveSubject(editedSubject)
        isPresented = false
    }
    
    private func isFormValid() -> Bool {
        guard let _ = Int(credits), !subjectName.isEmpty else {
            return false
        }
        return true
    }
}

#Preview {
    SubjectFormView(isPresented: .constant(true), viewModel: SubjectsViewModel())
}
