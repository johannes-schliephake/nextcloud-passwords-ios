import SwiftUI


struct PasswordDetailPage: View {
    
    @ObservedObject var entriesController: EntriesController
    @ObservedObject var password: Password
    let folders: [Folder]
    let tags: [Tag]
    let updatePassword: () -> Void
    let deletePassword: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var tipController: TipController
    
    @State private var favicon: UIImage?
    @State private var showDeleteAlert = false
    @State private var showEditPasswordView = false
    @State private var showErrorAlert = false
    @State private var passwordDeleted = false
    @State private var navigationSelection: NavigationSelection?
    @State private var showSelectTagsView = false
    
    // MARK: Views
    
    var body: some View {
        if passwordDeleted && UIDevice.current.userInterfaceIdiom == .pad {
            deletedView()
        }
        else {
            mainStack()
                .navigationTitle(password.label)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        if password.editable {
                            primaryActionToolbarView()
                        }
                    }
                }
                .onChange(of: sessionController.state) {
                    state in
                    if state.isChallengeAvailable {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("deletePassword"), object: password)) {
                    _ in
                    /// Clear password detail page on iPad when password was deleted (SwiftUI doesn't close view when NavigationLink is removed)
                    /// This has to be done with a notification because a password can also be deleted from the EntriesPage
                    passwordDeleted = true
                }
        }
    }
    
    private func deletedView() -> some View {
        VStack {
            Text("_deletedPasswordMessage")
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    private func mainStack() -> some View {
        GeometryReader {
            geometryProxy in
            VStack(spacing: 0) {
                listView()
                if let complete = autoFillController.complete {
                    Divider()
                    selectView(geometryProxy: geometryProxy, complete: complete)
                }
            }
            .edgesIgnoringSafeArea(autoFillController.complete != nil ? .bottom : [])
        }
        .sheet(isPresented: $showEditPasswordView, content: {
            EditPasswordNavigation(password: password, folders: folders, tags: tags, addPassword: {}, updatePassword: updatePassword, addTag: {
                tag in
                entriesController.add(tag: tag)
            })
                .environmentObject(autoFillController)
                .environmentObject(biometricAuthenticationController)
                .environmentObject(sessionController)
                .environmentObject(tipController)
        })
    }
    
    private func listView() -> some View {
        List {
            HStack {
                Spacer()
                passwordStatusMenu()
                Spacer()
                faviconImage()
                Spacer()
                favoriteButton()
                Spacer()
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            if let tags = entriesController.tags,
               let passwordTags = password.tags(in: tags) {
                tagsSection(tags: tags, passwordTags: passwordTags)
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
            }
            serviceSection()
            accountSection()
            if !password.customFields.isEmpty {
                customFieldsSection()
            }
            if !password.notes.isEmpty {
                notesSection()
            }
            metadataSection()
            deleteButton()
        }
        .listStyle(.insetGrouped)
    }
    
    private func passwordStatusMenu() -> some View {
        Menu {
            Section {
                switch password.statusCode {
                case .good:
                    Text("_passwordStatusGoodMessage1")
                    Text("_passwordStatusGoodMessage2")
                    Text("_passwordStatusGoodMessage3")
                case .outdated:
                    Text("_passwordStatusOutdatedMessage")
                case .duplicate:
                    Text("_passwordStatusDuplicateMessage")
                case .breached:
                    Text("_passwordStatusBreachedMessage1")
                    Text("_passwordStatusBreachedMessage2")
                }
            }
            if password.editable,
               password.statusCode != .good {
                Button {
                    showEditPasswordView = true
                }
                label: {
                    Label("_editPassword", systemImage: "pencil")
                }
                .disabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
            }
        }
        label: {
            switch password.statusCode {
            case .good:
                Image(systemName: "checkmark.shield.fill")
                    .font(.title)
                    .foregroundColor(.green)
            case .outdated, .duplicate:
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
            case .breached:
                Image(systemName: "xmark.shield.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func faviconImage() -> some View {
        Image(uiImage: favicon ?? UIImage())
            .resizable()
            .frame(width: 64, height: 64)
            .background(favicon == nil ? Color(white: 0.5, opacity: 0.2) : nil)
            .cornerRadius(6)
            .onAppear {
                requestFavicon()
            }
            .onChange(of: password.url) {
                _ in
                requestFavicon()
            }
    }
    
    private func favoriteButton() -> some View {
        Button {
            toggleFavorite()
        }
        label: {
            Image(systemName: password.favorite ? "star.fill" : "star")
                .font(.title)
        }
        .buttonStyle(.borderless)
        .disabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
    }
    
    private func tagsSection(tags: [Tag], passwordTags: [Tag]) -> some View {
        Section(footer: HStack {
            Spacer()
            Button(passwordTags.isEmpty ? "_addTags" : "_editTags") {
                showSelectTagsView = true
            }
            .font(.footnote)
            .textCase(.uppercase)
            Spacer()
        }) {
            if !passwordTags.isEmpty {
                if UIDevice.current.userInterfaceIdiom == .pad { /// Disable tag buttons for iPad because of NavigationLink bugs
                    FlowView(passwordTags.sortedByLabel()) {
                        tag in
                        TagBadge(tag: tag, baseColor: Color(.secondarySystemGroupedBackground))
                    }
                }
                else {
                    ZStack {
                        ForEach(passwordTags) {
                            tag in
                            NavigationLink("", tag: .entries(tag: tag), selection: $navigationSelection) {
                                EntriesPage(entriesController: entriesController, tag: tag, showFilterSortMenu: false)
                            }
                            .isDetailLink(false)
                        }
                        .hidden()
                        FlowView(passwordTags.sortedByLabel()) {
                            tag in
                            Button {
                                navigationSelection = .entries(tag: tag)
                            }
                            label: {
                                TagBadge(tag: tag, baseColor: Color(.secondarySystemGroupedBackground))
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSelectTagsView) {
            SelectTagsNavigation(temporaryEntry: .password(label: password.label, username: password.username, url: password.url, tags: password.tags), tags: tags, addTag: {
                tag in
                entriesController.add(tag: tag)
            }, selectTags: {
                tags in
                password.tags = tags.map { $0.id }
                entriesController.update(password: password)
            })
            .environmentObject(autoFillController)
            .environmentObject(biometricAuthenticationController)
            .environmentObject(sessionController)
            .environmentObject(tipController)
        }
    }
    
    private func serviceSection() -> some View {
        Section(header: Text("_service")) {
            LabeledRow(type: .text, label: "_name" as LocalizedStringKey, value: password.label, copiable: true)
            LabeledRow(type: .url, label: "_url" as LocalizedStringKey, value: password.url, copiable: true)
        }
    }
    
    private func accountSection() -> some View {
        Section(header: Text("_account")) {
            LabeledRow(type: .text, label: "_username" as LocalizedStringKey, value: password.username, copiable: true)
            LabeledRow(type: .secret, label: "_password" as LocalizedStringKey, value: password.password, copiable: true)
        }
    }
    
    private func customFieldsSection() -> some View {
        Section(header: Text("_customFields")) {
            ForEach(password.customFields.filter { $0.type != .data }) {
                customField in
                LabeledRow(type: LabeledRow.RowType(rawValue: customField.type.rawValue) ?? .text, label: customField.label, value: customField.value, copiable: true)
            }
        }
    }
    
    private func notesSection() -> some View {
        Section(header: Text("_notes")) {
            TextView(password.notes)
                .frame(height: 100)
        }
    }
    
    private func metadataSection() -> some View {
        Section(header: Text("_metadata")) {
            HStack {
                LabeledRow(type: .text, label: "_created" as LocalizedStringKey, value: password.created.formattedString)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                LabeledRow(type: .text, label: "_updated" as LocalizedStringKey, value: password.updated.formattedString)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            switch (password.cseType, password.sseType) {
            case ("none", "none"),
                 ("none", "unknown"):
                LabeledRow(type: .text, label: "_encryption" as LocalizedStringKey, value: "-")
            case (_, "none"),
                 (_, "unknown"):
                LabeledRow(type: .text, label: "_encryption" as LocalizedStringKey, value: "_clientSide".localized)
            case ("none", _):
                LabeledRow(type: .text, label: "_encryption" as LocalizedStringKey, value: "_serverSide".localized)
            case (_, _):
                LabeledRow(type: .text, label: "_encryption" as LocalizedStringKey, value: "\("_clientSide".localized) & \("_serverSide".localized)")
            }
        }
    }
    
    @ViewBuilder private func deleteButton() -> some View {
        if #available(iOS 15.0, *) {
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
            .disabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
            .actionSheet(isPresented: $showDeleteAlert) {
                ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deletePassword")) {
                    deleteAndDismiss()
                }])
            }
        }
        else {
            Button {
                showDeleteAlert = true
            }
            label: {
                HStack {
                    Spacer()
                    Text("_deletePassword")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .disabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
            .actionSheet(isPresented: $showDeleteAlert) {
                ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deletePassword")) {
                    deleteAndDismiss()
                }])
            }
        }
    }
    
    private func selectView(geometryProxy: GeometryProxy, complete: @escaping (String, String) -> Void) -> some View {
        VStack {
            VStack {
                Button("_select") {
                    complete(password.username, password.password)
                }
                .buttonStyle(.action)
            }
            .padding()
        }
        .padding(.bottom, geometryProxy.safeAreaInsets.bottom)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func primaryActionToolbarView() -> some View {
        HStack {
            if let state = password.state {
                if state.isError {
                    errorButton(state: state)
                }
                else if state.isProcessing {
                    ProgressView()
                }
                Spacer()
            }
            Button(action: {
                showEditPasswordView = true
            }, label: {
                Text("_edit")
            })
            .disabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
        }
    }
    
    private func errorButton(state: Entry.State) -> some View {
        Button {
            showErrorAlert = true
        }
        label: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(state == .deletionFailed ? .gray : .red)
        }
        .buttonStyle(.borderless)
        .alert(isPresented: $showErrorAlert) {
            switch state {
            case .creationFailed:
                return Alert(title: Text("_error"), message: Text("_createPasswordErrorMessage"))
            case .updateFailed:
                return Alert(title: Text("_error"), message: Text("_editPasswordErrorMessage"))
            case .deletionFailed:
                return Alert(title: Text("_error"), message: Text("_deletePasswordErrorMessage"))
            case .decryptionFailed:
                return Alert(title: Text("_error"), message: Text("_decryptPasswordErrorMessage"))
            default:
                return Alert(title: Text("_error"))
            }
        }
    }
    
    // MARK: Functions
    
    private func requestFavicon() {
        guard let domain = URL(string: password.url)?.host ?? URL(string: "https://\(password.url)")?.host,
              let session = sessionController.session else {
            return
        }
        FaviconServiceRequest(session: session, domain: domain).send { favicon = $0 }
    }
    
    private func toggleFavorite() {
        password.updated = Date()
        password.favorite.toggle()
        entriesController.update(password: password)
    }
    
    private func deleteAndDismiss() {
        deletePassword()
        presentationMode.wrappedValue.dismiss()
    }
    
}


extension PasswordDetailPage {
    
    enum NavigationSelection: Hashable {
        
        case entries(tag: Tag)
        
    }
    
}


struct PasswordDetailPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                PasswordDetailPage(entriesController: EntriesController.mock, password: Password.mock, folders: Folder.mocks, tags: Tag.mocks, updatePassword: {}, deletePassword: {})
            }
            .showColumns(false)
            .environmentObject(AutoFillController.mock)
            .environmentObject(BiometricAuthenticationController.mock)
            .environmentObject(SessionController.mock)
            .environmentObject(TipController.mock)
        }
    }
    
}
