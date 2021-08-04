import SwiftUI


struct EditPasswordPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var tipController: TipController
    
    @StateObject private var editPasswordController: EditPasswordController
    @ScaledMetric private var sliderLabelWidth: CGFloat = 87
    @ScaledMetric private var customFieldTypeIconWidth: CGFloat = 30
    @State private var showPasswordGenerator: Bool
    @State private var editMode = false
    @State private var showSelectFolderView = false
    
    init(password: Password, folders: [Folder], addPassword: @escaping () -> Void, updatePassword: @escaping () -> Void) {
        _editPasswordController = StateObject(wrappedValue: EditPasswordController(password: password, folders: folders, addPassword: addPassword, updatePassword: updatePassword))
        _showPasswordGenerator = State(initialValue: password.id.isEmpty && !Configuration.userDefaults.bool(forKey: "automaticallyGeneratePasswords"))
    }
    
    // MARK: Views
    
    var body: some View {
        listView()
            .navigationTitle("_password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton()
                }
            }
            .onChange(of: sessionController.state) {
                state in
                if state.isChallengeAvailable {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .onAppear {
                if editPasswordController.password.id.isEmpty,
                   Configuration.userDefaults.bool(forKey: "automaticallyGeneratePasswords") {
                    editPasswordController.generatePassword()
                }
            }
            .environment(\.editMode, .constant(editMode ? .active : .inactive))
    }
    
    private func listView() -> some View {
        VStack {
            List {
                serviceSection()
                accountSection()
                passwordGeneratorSection()
                customFieldsSection()
                notesSection()
                if editPasswordController.password.id.isEmpty {
                    favoriteButton()
                }
                moveSection()
            }
            .listStyle(InsetGroupedListStyle())
            EmptyView()
                .sheet(isPresented: $showSelectFolderView) {
                    SelectFolderNavigation(entry: .password(editPasswordController.password), temporaryEntry: .password(label: editPasswordController.passwordLabel, username: editPasswordController.passwordUsername, url: editPasswordController.passwordUrl, folder: editPasswordController.passwordFolder), folders: editPasswordController.folders, selectFolder: {
                        parent in
                        editPasswordController.passwordFolder = parent.id
                    })
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(tipController)
                }
        }
    }
    
    private func serviceSection() -> some View {
        Section(header: Text("_service")) {
            EditLabeledRow(type: .text, label: "_name" as LocalizedStringKey, value: $editPasswordController.passwordLabel)
            EditLabeledRow(type: .url, label: "_url" as LocalizedStringKey, value: $editPasswordController.passwordUrl)
        }
    }
    
    private func accountSection() -> some View {
        Section(header: Text("_account")) {
            EditLabeledRow(type: .email, label: "_username" as LocalizedStringKey, value: $editPasswordController.passwordUsername)
            EditLabeledRow(type: .secret, label: "_password" as LocalizedStringKey, value: $editPasswordController.passwordPassword)
                .accessibility(identifier: "showPasswordButton")
        }
    }
    
    private func passwordGeneratorSection() -> some View {
        DisclosureGroup("_passwordGenerator", isExpanded: $showPasswordGenerator) {
            if horizontalSizeClass == .regular {
                HStack {
                    Toggle("_numbers", isOn: $editPasswordController.generatorNumbers)
                    Divider()
                        .padding(.horizontal)
                    Toggle("_specialCharacters", isOn: $editPasswordController.generatorSpecial)
                }
            }
            else {
                Toggle("_numbers", isOn: $editPasswordController.generatorNumbers)
                Toggle("_specialCharacters", isOn: $editPasswordController.generatorSpecial)
            }
            HStack {
                Text(String(format: "_length(length)".localized, String(Int(editPasswordController.generatorLength))))
                    .frame(width: sliderLabelWidth, alignment: .leading)
                Spacer()
                Slider(value: $editPasswordController.generatorLength, in: 1...36, step: 1)
                    .frame(maxWidth: 400)
            }
            Button {
                editPasswordController.generatePassword()
            }
            label: {
                HStack {
                    Label("_generatePassword", systemImage: "key")
                    if editPasswordController.showProgressView {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(editPasswordController.showProgressView)
            .alert(isPresented: $editPasswordController.showErrorAlert) {
                Alert(title: Text("_error"), message: Text("_passwordServiceErrorMessage"))
            }
        }
        .accessibility(identifier: "passwordGenerator")
    }
    
    private func customFieldsSection() -> some View {
        Section(header: HStack {
            Text("_customFields")
            Spacer()
            Button {
                editMode.toggle()
            }
            label: {
                Text(editMode ? "_done" : "_edit")
            }
        }) {
            ForEach(editPasswordController.passwordCustomFields.indices.filter { editPasswordController.passwordCustomFields[$0].type != .data }, id: \.self) {
                index in
                HStack {
                    Menu {
                        Picker("", selection: $editPasswordController.passwordCustomFields[index].type) {
                            Label("_text", systemImage: Password.CustomField.CustomFieldType.text.systemName)
                                .tag(Password.CustomField.CustomFieldType.text)
                            Label("_secret", systemImage: Password.CustomField.CustomFieldType.secret.systemName)
                                .tag(Password.CustomField.CustomFieldType.secret)
                            Label("_email", systemImage: Password.CustomField.CustomFieldType.email.systemName)
                                .tag(Password.CustomField.CustomFieldType.email)
                            Label("_url", systemImage: Password.CustomField.CustomFieldType.url.systemName)
                                .tag(Password.CustomField.CustomFieldType.url)
                            Label("_file", systemImage: Password.CustomField.CustomFieldType.file.systemName)
                                .tag(Password.CustomField.CustomFieldType.file)
                        }
                    }
                    label: {
                        Image(systemName: editPasswordController.passwordCustomFields[index].type.systemName)
                            .frame(minWidth: customFieldTypeIconWidth, maxHeight: .infinity, alignment: .leading)
                    }
                    Spacer()
                    VStack {
                        EditLabeledRow(type: .text, label: "_name" as LocalizedStringKey, value: $editPasswordController.passwordCustomFields[index].label)
                        Divider()
                        EditLabeledRow(type: LabeledRow.RowType(rawValue: editPasswordController.passwordCustomFields[index].type.rawValue) ?? .text, label: "_\(editPasswordController.passwordCustomFields[index].type)".localized, value: $editPasswordController.passwordCustomFields[index].value)
                    }
                }
                .id(editPasswordController.passwordCustomFields[index].id)
            }
            .onMove {
                indices, offset in
                editPasswordController.passwordCustomFields.move(fromOffsets: indices, toOffset: offset)
            }
            .onDelete {
                indices in
                editPasswordController.passwordCustomFields.remove(atOffsets: indices)
            }
            Button {
                editPasswordController.passwordCustomFields.append(Password.CustomField(label: "", type: .text, value: ""))
            }
            label: {
                Label("_addCustomField", systemImage: "plus.circle")
            }
        }
    }
    
    private func notesSection() -> some View {
        Section(header: Text("_notes")) {
            TextView("-", text: $editPasswordController.passwordNotes)
                .frame(height: 100)
        }
    }
    
    private func moveSection() -> some View {
        Section(header: Text("_folder")) {
            Button {
                showSelectFolderView = true
            }
            label: {
                Label(editPasswordController.folders.first(where: { $0.id == editPasswordController.passwordFolder })?.label ?? "_passwords".localized, systemImage: "folder")
            }
        }
    }
    
    private func favoriteButton() -> some View {
        Button {
            editPasswordController.passwordFavorite.toggle()
        }
        label: {
            Label("_favorite", systemImage: editPasswordController.passwordFavorite ? "star.fill" : "star")
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func confirmButton() -> some View {
        Button(editPasswordController.password.id.isEmpty ? "_create" : "_done") {
            applyAndDismiss()
        }
        .disabled(editPasswordController.passwordPassword.isEmpty || editPasswordController.passwordLabel.isEmpty || editPasswordController.passwordCustomFields.count > 20 || editPasswordController.passwordCustomFields.filter { $0.type != .data }.map { $0.label.isEmpty || $0.label.count > 48 || $0.value.isEmpty || $0.value.count > 320 }.contains(true))
    }
    
    // MARK: Functions
    
    private func applyAndDismiss() {
        guard editPasswordController.password.state?.isProcessing != true else {
            return
        }
        editPasswordController.applyToPassword()
        presentationMode.wrappedValue.dismiss()
    }
    
}


struct EditPasswordPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                EditPasswordPage(password: Password.mock, folders: Folder.mocks, addPassword: {}, updatePassword: {})
            }
            .showColumns(false)
        }
    }
    
}
