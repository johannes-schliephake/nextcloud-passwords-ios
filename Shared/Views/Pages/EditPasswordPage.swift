import SwiftUI


struct EditPasswordPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var settingsController: SettingsController
    @EnvironmentObject private var tipController: TipController
    
    @StateObject private var editPasswordController: EditPasswordController
    @ScaledMetric private var sliderLabelWidth = 87.0
    @ScaledMetric private var customFieldTypeIconWidth = 30.0
    @available(iOS 15, *) @FocusState private var focusedField: FocusField?
    @State private var showPasswordGenerator: Bool
    @State private var editMode = false
    @State private var showSelectTagsView = false
    @State private var showSelectFolderView = false
    @State private var showCancelAlert = false
    
    init(entriesController: EntriesController, password: Password) {
        _editPasswordController = StateObject(wrappedValue: EditPasswordController(entriesController: entriesController, password: password))
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
            .apply {
                view in
                if #available(iOS 15, *) {
                    view
                        .initialize(focus: $focusedField, with: editPasswordController.password.id.isEmpty ? .passwordLabel : nil)
                        .interactiveDismissDisabled(editPasswordController.hasChanges)
                }
                else {
                    view
                        .actionSheet(isPresented: $showCancelAlert) {
                            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_discardChanges")) {
                                presentationMode.wrappedValue.dismiss()
                            }])
                        }
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
        List {
            serviceSection()
            accountSection()
            passwordGeneratorSection()
            customFieldsSection()
            notesSection()
            favoriteButton()
            tagsSection()
            moveSection()
        }
        .listStyle(.insetGrouped)
        .apply {
            view in
            if #available(iOS 15, *) {
                view
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button {
                                focusedField = focusedField?.previous()
                            }
                            label: {
                                Image(systemName: "chevron.up")
                            }
                            .disabled(focusedField?.previous() == nil)
                            Button {
                                focusedField = focusedField?.next(customUserFieldsCount: editPasswordController.passwordCustomUserFields.count)
                            }
                            label: {
                                Image(systemName: "chevron.down")
                            }
                            .disabled(focusedField?.next(customUserFieldsCount: editPasswordController.passwordCustomUserFields.count) == nil)
                            Spacer()
                            Button {
                                focusedField = nil
                            }
                            label: {
                                Text("_dismiss")
                                    .bold()
                            }
                        }
                    }
                    .onSubmit {
                        guard !showSelectFolderView,
                              !showSelectTagsView else { /// Prevent submit handling when page is not visible
                            return
                        }
                        if let next = focusedField?.next(customUserFieldsCount: editPasswordController.passwordCustomUserFields.count) {
                            focusedField = next
                        }
                        else {
                            applyAndDismiss()
                        }
                    }
            }
        }
    }
    
    private func serviceSection() -> some View {
        Section(header: Text("_service")) {
            EditLabeledRow(type: .text, label: "_name" as LocalizedStringKey, value: $editPasswordController.passwordLabel)
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .focused($focusedField, equals: .passwordLabel)
                            .submitLabel(.next)
                    }
                }
            EditLabeledRow(type: .url, label: "_url" as LocalizedStringKey, value: $editPasswordController.passwordUrl)
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .focused($focusedField, equals: .passwordUrl)
                            .submitLabel(.next)
                    }
                }
        }
    }
    
    private func accountSection() -> some View {
        Section(header: Text("_account")) {
            EditLabeledRow(type: .email, label: "_username" as LocalizedStringKey, value: $editPasswordController.passwordUsername)
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .focused($focusedField, equals: .passwordUsername)
                            .submitLabel(.next)
                    }
                }
            EditLabeledRow(type: .secret, label: "_password" as LocalizedStringKey, value: $editPasswordController.passwordPassword)
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .focused($focusedField, equals: .passwordPassword)
                            .submitLabel(FocusField.passwordPassword.next(customUserFieldsCount: editPasswordController.passwordCustomUserFields.count) != nil ? .next : .done)
                    }
                }
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
                if editMode {
                    Text("_done")
                }
                else {
                    Text("_edit")
                }
            }
        }) {
            ForEach(editPasswordController.passwordCustomUserFields.indices, id: \.self) {
                customUserFieldIndex in
                HStack {
                    Menu {
                        Picker("", selection: $editPasswordController.passwordCustomUserFields[customUserFieldIndex].type) {
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
                        Image(systemName: editPasswordController.passwordCustomUserFields[customUserFieldIndex].type.systemName)
                            .frame(minWidth: customFieldTypeIconWidth, maxHeight: .infinity, alignment: .leading)
                    }
                    Spacer()
                    VStack {
                        EditLabeledRow(type: .text, label: "_name" as LocalizedStringKey, value: $editPasswordController.passwordCustomUserFields[customUserFieldIndex].label)
                            .apply {
                                view in
                                if #available(iOS 15, *) {
                                    view
                                        .focused($focusedField, equals: .passwordCustomFields(index: customUserFieldIndex, row: .label))
                                        .submitLabel(.next)
                                }
                            }
                        Divider()
                        EditLabeledRow(type: LabeledRow.RowType(rawValue: editPasswordController.passwordCustomUserFields[customUserFieldIndex].type.rawValue) ?? .text, label: "_\(editPasswordController.passwordCustomUserFields[customUserFieldIndex].type)".localized, value: $editPasswordController.passwordCustomUserFields[customUserFieldIndex].value)
                            .apply {
                                view in
                                if #available(iOS 15, *) {
                                    view
                                        .focused($focusedField, equals: .passwordCustomFields(index: customUserFieldIndex, row: .value))
                                        .submitLabel(FocusField.passwordCustomFields(index: customUserFieldIndex, row: .value).next(customUserFieldsCount: editPasswordController.passwordCustomUserFields.count) != nil ? .next : .done)
                                }
                            }
                    }
                }
                .id(editPasswordController.passwordCustomUserFields[customUserFieldIndex].id)
            }
            .onMove {
                indices, offset in
                editPasswordController.passwordCustomUserFields.move(fromOffsets: indices, toOffset: offset)
            }
            .onDelete {
                indices in
                editPasswordController.passwordCustomUserFields.remove(atOffsets: indices)
            }
            Button {
                editPasswordController.passwordCustomUserFields.append(Password.CustomField(label: "", type: .text, value: ""))
            }
            label: {
                Label("_addCustomField", systemImage: "plus.circle")
            }
            .disabled(editPasswordController.passwordCustomFieldCount >= 20)
        }
    }
    
    private func notesSection() -> some View {
        Section(header: Text("_notes")) {
            TextView("-", text: $editPasswordController.passwordNotes)
                .frame(height: 100)
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
    
    private func tagsSection() -> some View {
        Section(header: Text("_tags")) {
            Button {
                showSelectTagsView = true
            }
            label: {
                HStack {
                    if editPasswordController.passwordValidTags.isEmpty {
                        Label("_addTags", systemImage: "tag")
                    }
                    else {
                        FlowView(editPasswordController.passwordValidTags.sortedByLabel(), alignment: .leading) {
                            tag in
                            TagBadge(tag: tag, baseColor: Color(.systemGroupedBackground))
                        }
                        .padding(.vertical, 6)
                    }
                    Spacer()
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    .fixedSize()
                }
            }
            .sheet(isPresented: $showSelectTagsView) {
                SelectTagsNavigation(entriesController: editPasswordController.entriesController, temporaryEntry: .password(label: editPasswordController.passwordLabel, username: editPasswordController.passwordUsername, url: editPasswordController.passwordUrl, tags: editPasswordController.passwordValidTags.map { $0.id } + editPasswordController.passwordInvalidTags), selectTags: {
                    validTags, _ in
                    editPasswordController.passwordValidTags = validTags
                })
                .environmentObject(autoFillController)
                .environmentObject(biometricAuthenticationController)
                .environmentObject(sessionController)
                .environmentObject(settingsController)
                .environmentObject(tipController)
            }
        }
    }
    
    private func moveSection() -> some View {
        Section(header: Text("_folder")) {
            Button {
                showSelectFolderView = true
            }
            label: {
                HStack {
                    Label(editPasswordController.folderLabel, systemImage: "folder")
                    Spacer()
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    .fixedSize()
                }
            }
            .sheet(isPresented: $showSelectFolderView) {
                SelectFolderNavigation(entriesController: editPasswordController.entriesController, entry: .password(editPasswordController.password), temporaryEntry: .password(label: editPasswordController.passwordLabel, username: editPasswordController.passwordUsername, url: editPasswordController.passwordUrl, folder: editPasswordController.passwordFolder), selectFolder: {
                    parent in
                    editPasswordController.passwordFolder = parent.id
                })
                .environmentObject(autoFillController)
                .environmentObject(biometricAuthenticationController)
                .environmentObject(sessionController)
                .environmentObject(settingsController)
                .environmentObject(tipController)
            }
        }
    }
    
    @ViewBuilder private func cancelButton() -> some View {
        if #available(iOS 15.0, *) {
            Button("_cancel", role: .cancel) {
                cancelAndDismiss()
            }
            .actionSheet(isPresented: $showCancelAlert) {
                ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_discardChanges")) {
                    presentationMode.wrappedValue.dismiss()
                }])
            }
        }
        else {
            Button("_cancel") {
                cancelAndDismiss()
            }
        }
    }
    
    private func confirmButton() -> some View {
        Button(editPasswordController.password.id.isEmpty ? "_create" : "_done") {
            applyAndDismiss()
        }
        .disabled(!editPasswordController.editIsValid)
    }
    
    // MARK: Functions
    
    private func cancelAndDismiss() {
        if editPasswordController.hasChanges {
            showCancelAlert = true
        }
        else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func applyAndDismiss() {
        guard editPasswordController.editIsValid,
              settingsController.settingsAreAvailable,
              editPasswordController.password.state?.isProcessing != true else {
            return
        }
        editPasswordController.applyToPassword()
        presentationMode.wrappedValue.dismiss()
    }
    
}


extension EditPasswordPage {
    
    private enum FocusField: Hashable {
        
        enum CustomFieldRow { // swiftlint:disable:this nesting
            case label
            case value
        }
        
        case passwordLabel
        case passwordUrl
        case passwordUsername
        case passwordPassword
        case passwordCustomFields(index: Int, row: CustomFieldRow)
        
        func previous() -> Self? {
            switch self {
            case .passwordLabel:
                return nil
            case .passwordUrl:
                return .passwordLabel
            case .passwordUsername:
                return .passwordUrl
            case .passwordPassword:
                return .passwordUsername
            case .passwordCustomFields(let index, let row):
                switch row {
                case .label:
                    return index - 1 >= 0 ? .passwordCustomFields(index: index - 1, row: .value) : .passwordPassword
                case .value:
                    return .passwordCustomFields(index: index, row: .label)
                }
            }
        }
        
        func next(customUserFieldsCount: Int) -> Self? {
            switch self {
            case .passwordLabel:
                return .passwordUrl
            case .passwordUrl:
                return .passwordUsername
            case .passwordUsername:
                return .passwordPassword
            case .passwordPassword:
                return customUserFieldsCount > 0 ? .passwordCustomFields(index: 0, row: .label) : nil
            case .passwordCustomFields(let index, let row):
                switch row {
                case .label:
                    return .passwordCustomFields(index: index, row: .value)
                case .value:
                    return index + 1 < customUserFieldsCount ? .passwordCustomFields(index: index + 1, row: .label) : nil
                }
            }
        }
        
    }
    
}


struct EditPasswordPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                EditPasswordPage(entriesController: EntriesController.mock, password: Password.mock)
            }
            .showColumns(false)
        }
    }
    
}
