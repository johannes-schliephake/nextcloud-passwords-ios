import SwiftUI
import PhotosUI


struct EditPasswordPage: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsController: SettingsController
    
    @StateObject private var editPasswordController: EditPasswordController
    @ScaledMetric private var customFieldTypeIconWidth = 30.0
    @FocusState private var focusedField: FocusField?
    @AppStorage("didAcceptAboutOtps", store: Configuration.userDefaults) private var didAcceptAboutOtps = Configuration.defaults["didAcceptAboutOtps"] as! Bool // swiftlint:disable:this force_cast
    @State private var editMode = false
    @State private var sheetItem: SheetItem?
    @State private var showAboutOtpsTooltip = false
    @State private var showPhotosPicker = false
    @State private var showDeleteAlert = false
    @State private var showCancelAlert = false
    
    init(entriesController: EntriesController, password: Password) {
        _editPasswordController = StateObject(wrappedValue: EditPasswordController(entriesController: entriesController, password: password))
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
            .initialize(focus: $focusedField, with: editPasswordController.password.id.isEmpty ? .passwordLabel : nil)
            .interactiveDismissDisabled(editPasswordController.hasChanges)
            .environment(\.editMode, .constant(editMode ? .active : .inactive))
    }
    
    private func listView() -> some View {
        List {
            serviceSection()
            accountSection()
            customFieldsSection()
            notesSection()
            favoriteButton()
            tagsSection()
            moveSection()
            if !editPasswordController.password.id.isEmpty {
                deleteButton()
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focusedField = focusedField?.previous(customUserFieldIds: editPasswordController.passwordCustomUserFields.map { $0.id })
                }
                label: {
                    Image(systemName: "chevron.up")
                }
                .disabled(focusedField?.previous(customUserFieldIds: editPasswordController.passwordCustomUserFields.map { $0.id }) == nil)
                Button {
                    focusedField = focusedField?.next(customUserFieldIds: editPasswordController.passwordCustomUserFields.map { $0.id })
                }
                label: {
                    Image(systemName: "chevron.down")
                }
                .disabled(focusedField?.next(customUserFieldIds: editPasswordController.passwordCustomUserFields.map { $0.id }) == nil)
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
            guard sheetItem == nil else { /// Prevent submit handling when page is not visible
                return
            }
            if let next = focusedField?.next(customUserFieldIds: editPasswordController.passwordCustomUserFields.map { $0.id }) {
                focusedField = next
            }
            else {
                applyAndDismiss()
            }
        }
        .apply {
            view in
            if #available(iOS 16, *) {
                view
                    .photosPicker(isPresented: $showPhotosPicker, selection: Binding(get: {
                        nil
                    }, set: { selection in
                        guard let selection else {
                            return
                        }
                        editPasswordController.extractOtp(from: selection)
                    }), matching: .images)
            }
        }
        .sheet(item: $sheetItem) {
            item in
            switch item {
            case .edit(let otp):
                EditOTPNavigation(otp: OTP(type: otp.type, algorithm: otp.algorithm, secret: otp.secret, digits: otp.digits, counter: otp.counter, period: otp.period, issuer: editPasswordController.passwordLabel, accountname: editPasswordController.passwordUsername) ?? otp, updateOtp: {
                    otp in
                    editPasswordController.passwordOtp = otp
                })
            case .scanQrCode:
                CaptureOTPNavigation {
                    otp in
                    editPasswordController.passwordOtp = otp
                }
            case .detectQrCode:
                if #unavailable(iOS 16) {
                    ImagePicker {
                        image in
                        editPasswordController.extractOtp(from: image)
                    }
                }
            case .selectTags:
                SelectTagsNavigation(entriesController: editPasswordController.entriesController, temporaryEntry: .password(label: editPasswordController.passwordLabel, username: editPasswordController.passwordUsername, url: editPasswordController.passwordUrl, tags: editPasswordController.passwordValidTags.map { $0.id } + editPasswordController.passwordInvalidTags), selectTags: {
                    validTags, _ in
                    editPasswordController.passwordValidTags = validTags
                })
            case .selectFolder:
                SelectFolderNavigation(entriesController: editPasswordController.entriesController, entry: .password(editPasswordController.password), temporaryEntry: .password(label: editPasswordController.passwordLabel, username: editPasswordController.passwordUsername, url: editPasswordController.passwordUrl, folder: editPasswordController.passwordFolder), selectFolder: {
                    parent in
                    editPasswordController.passwordFolder = parent.id
                })
            }
        }
    }
    
    private func serviceSection() -> some View {
        Section(header: Text("_service")) {
            EditLabeledRow(type: .text, label: "_name" as LocalizedStringKey, value: $editPasswordController.passwordLabel)
                .focused($focusedField, equals: .passwordLabel)
                .submitLabel(.next)
            EditLabeledRow(type: .url, label: "_url" as LocalizedStringKey, value: $editPasswordController.passwordUrl)
                .focused($focusedField, equals: .passwordUrl)
                .submitLabel(.next)
        }
    }
    
    private func accountSection() -> some View {
        Section(header: Text("_account")) {
            EditLabeledRow(type: .email, label: "_username" as LocalizedStringKey, value: $editPasswordController.passwordUsername)
                .focused($focusedField, equals: .passwordUsername)
                .submitLabel(.next)
            HStack(spacing: 16) {
                EditLabeledRow(type: .secret, label: "_password" as LocalizedStringKey, value: $editPasswordController.passwordPassword)
                    .focused($focusedField, equals: .passwordPassword)
                    .submitLabel(FocusField.passwordPassword.next(customUserFieldIds: editPasswordController.passwordCustomUserFields.map { $0.id }) != nil ? .next : .done)
                    .accessibility(identifier: "showPasswordButton")
                PasswordGenerator(password: $editPasswordController.passwordPassword, generateInitial: Configuration.userDefaults.bool(forKey: "automaticallyGeneratePasswords"))
                    .accessibility(identifier: "passwordGenerator")
            }
            otpButton()
        }
    }
    
    @ViewBuilder private func otpButton() -> some View {
        if let otp = editPasswordController.passwordOtp {
            Button {
                sheetItem = .edit(otp: otp)
            }
            label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("_otp")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Label("_configured", systemImage: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                    Spacer()
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    .fixedSize()
                    .tint(.primary)
                }
            }
        }
        else if !didAcceptAboutOtps {
            Button {
                showAboutOtpsTooltip = true
            }
            label: {
                Label("_addOtp", systemImage: "123.rectangle")
            }
            .disabled(editPasswordController.passwordCustomFieldCount >= 20)
            .tooltip(isPresented: $showAboutOtpsTooltip, content: {
                VStack(alignment: .leading, spacing: 15) {
                    Text("_aboutOtps")
                        .font(.title2.bold())
                    Text("_aboutOtpsMessage")
                    Button {
                        showAboutOtpsTooltip = false
                        didAcceptAboutOtps = true
                    }
                    label: {
                        Text("_confirm")
                    }
                    .buttonStyle(.action)
                }
            })
        }
        else {
            Menu {
                Button {
                    sheetItem = .scanQrCode
                }
                label: {
                    Label("_scanQrCode", systemImage: "qrcode")
                }
                .disabled(UIApplication.isExtension)
                Button {
                    if #available(iOS 16, *) {
                        showPhotosPicker = true
                    }
                    else {
                        sheetItem = .detectQrCode
                    }
                }
                label: {
                    Label("_detectQrCodeInPicture", systemImage: "photo")
                }
                Button {
                    guard let otp = OTP() else {
                        return
                    }
                    sheetItem = .edit(otp: otp)
                }
                label: {
                    Label("_addManually", systemImage: "square.and.pencil")
                }
            }
            label: {
                Label("_addOtp", systemImage: "123.rectangle")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(editPasswordController.passwordCustomFieldCount >= 20)
            .alert(isPresented: $editPasswordController.showExtractOtpErrorAlert) {
                Alert(title: Text("_error"), message: Text("_extractOtpErrorMessage"))
            }
        }
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
            .disabled(editPasswordController.passwordCustomUserFields.isEmpty)
            .onChange(of: editPasswordController.passwordCustomUserFields.isEmpty) { editMode = editMode && !$0 }
        }
            .font(.footnote)) {
            ForEach($editPasswordController.passwordCustomUserFields) {
                $customUserField in
                HStack {
                    Menu {
                        Picker("", selection: $customUserField.type) {
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
                        Image(systemName: customUserField.type.systemName)
                            .frame(minWidth: customFieldTypeIconWidth, maxHeight: .infinity, alignment: .leading)
                    }
                    .apply {
                        view in
                        if #available(iOS 16, *) {
                            view
                                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                        }
                    }
                    Spacer()
                    VStack {
                        EditLabeledRow(type: .text, label: "_name" as LocalizedStringKey, value: $customUserField.label)
                            .focused($focusedField, equals: .passwordCustomFields(id: customUserField.id, row: .label))
                            .submitLabel(.next)
                        Divider()
                        HStack(spacing: 16) {
                            EditLabeledRow(type: LabeledRow.RowType(rawValue: customUserField.type.rawValue) ?? .text, label: "_\(customUserField.type)".localized, value: $customUserField.value)
                                .focused($focusedField, equals: .passwordCustomFields(id: customUserField.id, row: .value))
                                .submitLabel(FocusField.passwordCustomFields(id: customUserField.id, row: .value).next(customUserFieldIds: editPasswordController.passwordCustomUserFields.map { $0.id }) != nil ? .next : .done)
                            if customUserField.type == .secret {
                                PasswordGenerator(password: $customUserField.value)
                            }
                        }
                    }
                }
                .id(customUserField.id)
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
                Label("_addCustomField", systemImage: "rectangle.and.paperclip")
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
        Section {
            Button {
                editPasswordController.passwordFavorite.toggle()
            }
            label: {
                Label("_favorite", systemImage: editPasswordController.passwordFavorite ? "star.fill" : "star")
            }
        }
    }
    
    private func tagsSection() -> some View {
        Section(header: Text("_tags")) {
            Button {
                sheetItem = .selectTags
            }
            label: {
                HStack {
                    if editPasswordController.passwordValidTags.isEmpty {
                        Label("_addTags", systemImage: "tag")
                    }
                    else {
                        if #available(iOS 16, *) {
                            FlowView(alignment: .leading) {
                                ForEach(editPasswordController.passwordValidTags.sortedByLabel()) {
                                    tag in
                                    TagBadge(tag: tag, baseColor: Color(.systemGroupedBackground))
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        else {
                            LegacyFlowView(editPasswordController.passwordValidTags.sortedByLabel(), alignment: .leading) {
                                tag in
                                TagBadge(tag: tag, baseColor: Color(.systemGroupedBackground))
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    Spacer()
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    .fixedSize()
                    .tint(.primary)
                }
            }
        }
    }
    
    private func moveSection() -> some View {
        Section(header: Text("_folder")) {
            Button {
                sheetItem = .selectFolder
            }
            label: {
                HStack {
                    Label(editPasswordController.folderLabel, systemImage: "folder")
                    Spacer()
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    .fixedSize()
                    .tint(.primary)
                }
            }
        }
    }
    
    private func deleteButton() -> some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        }
        label: {
            HStack {
                Spacer()
                Text("_deletePassword")
                Spacer()
            }
        }
        .actionSheet(isPresented: $showDeleteAlert) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deletePassword")) {
                deleteAndDismiss()
            }])
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            cancelAndDismiss()
        }
        .actionSheet(isPresented: $showCancelAlert) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_discardChanges")) {
                dismiss()
            }])
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
            dismiss()
        }
    }
    
    private func applyAndDismiss() {
        guard editPasswordController.editIsValid,
              settingsController.settingsAreAvailable,
              editPasswordController.password.state?.isProcessing != true else {
            return
        }
        editPasswordController.applyToPassword()
        dismiss()
    }
    
    private func deleteAndDismiss() {
        editPasswordController.clearPassword()
        dismiss()
    }
    
}


extension EditPasswordPage {
    
    private enum SheetItem: Identifiable, Hashable {
        
        case edit(otp: OTP)
        case scanQrCode
        case detectQrCode
        case selectTags
        case selectFolder
        
        var id: Int {
            hashValue
        }
        
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
        case passwordCustomFields(id: UUID, row: CustomFieldRow)
        
        func previous(customUserFieldIds: [UUID]) -> Self? {
            switch self {
            case .passwordLabel:
                return nil
            case .passwordUrl:
                return .passwordLabel
            case .passwordUsername:
                return .passwordUrl
            case .passwordPassword:
                return .passwordUsername
            case .passwordCustomFields(let id, let row):
                switch row {
                case .label:
                    guard let previousId = customUserFieldIds.reversed().reduce(Optional(id), { $0 == nil ? $1 : $0 == $1 ? nil : $0 }) else {
                        return .passwordPassword
                    }
                    return .passwordCustomFields(id: previousId, row: .value)
                case .value:
                    return .passwordCustomFields(id: id, row: .label)
                }
            }
        }
        
        func next(customUserFieldIds: [UUID]) -> Self? {
            switch self {
            case .passwordLabel:
                return .passwordUrl
            case .passwordUrl:
                return .passwordUsername
            case .passwordUsername:
                return .passwordPassword
            case .passwordPassword:
                guard let firstId = customUserFieldIds.first else {
                    return nil
                }
                return .passwordCustomFields(id: firstId, row: .label)
            case .passwordCustomFields(let id, let row):
                switch row {
                case .label:
                    return .passwordCustomFields(id: id, row: .value)
                case .value:
                    guard let nextId = customUserFieldIds.reduce(Optional(id), { $0 == nil ? $1 : $0 == $1 ? nil : $0 }) else {
                        return nil
                    }
                    return .passwordCustomFields(id: nextId, row: .label)
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
