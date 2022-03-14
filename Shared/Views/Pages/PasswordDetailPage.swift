import SwiftUI


struct PasswordDetailPage: View {
    
    @ObservedObject var entriesController: EntriesController
    @ObservedObject var password: Password
    let updatePassword: () -> Void
    let deletePassword: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var settingsController: SettingsController
    @EnvironmentObject private var tipController: TipController
    
    @AppStorage("showMetadata", store: Configuration.userDefaults) private var showMetadata = Configuration.defaults["showMetadata"] as! Bool // swiftlint:disable:this force_cast
    @State private var favicon: UIImage?
    @State private var showDeleteAlert = false
    @State private var showEditPasswordView = false
    @State private var showErrorAlert = false
    @State private var passwordDeleted = false
    @State private var navigationSelection: NavigationSelection?
    @State private var showSelectTagsView = false
    @State private var showPasswordStatusTooltip = false
    
    // MARK: Views
    
    var body: some View {
        if passwordDeleted && UIDevice.current.userInterfaceIdiom == .pad {
            deletedView()
        }
        else {
            mainStack()
                .navigationTitle(password.label)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        stateView()
                    }
                    ToolbarItem(placement: .primaryAction) {
                        if password.editable {
                            editButton()
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
                if let complete = autoFillController.complete,
                   autoFillController.mode == .provider || autoFillController.mode == .extension && password.otp != nil {
                    Divider()
                    selectView(geometryProxy: geometryProxy, complete: complete)
                }
            }
            .edgesIgnoringSafeArea(autoFillController.complete != nil ? .bottom : [])
        }
        .sheet(isPresented: $showEditPasswordView, content: {
            EditPasswordNavigation(entriesController: entriesController, password: password)
                .environmentObject(autoFillController)
                .environmentObject(biometricAuthenticationController)
                .environmentObject(sessionController)
                .environmentObject(settingsController)
                .environmentObject(tipController)
        })
    }
    
    private func listView() -> some View {
        List {
            Section {
                HStack {
                    Spacer()
                    passwordStatusIcon()
                    Spacer()
                    faviconImage()
                    Spacer()
                    favoriteButton()
                    Spacer()
                }
                .padding(.top)
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            if let tags = entriesController.tags,
               let validTags = EntriesController.tags(for: password.tags, in: tags).valid {
                tagsSection(tags: tags, validTags: validTags)
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
            }
            serviceSection()
            accountSection()
            if !password.customUserFields.isEmpty {
                customFieldsSection()
            }
            if !password.notes.isEmpty {
                notesSection()
            }
            metadataSection()
                .listRowBackground(Color(UIColor.systemGroupedBackground))
        }
        .listStyle(.insetGrouped)
    }
    
    private func passwordStatusIcon() -> some View {
        Button {
            showPasswordStatusTooltip = true
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
            case .unknown:
                ZStack {
                    Image(systemName: "shield.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                    Image(systemName: "questionmark")
                        .font(.title.bold())
                        .foregroundColor(Color(.systemGroupedBackground))
                        .scaleEffect(0.5)
                }
            }
        }
        .buttonStyle(.borderless)
        .tooltip(isPresented: $showPasswordStatusTooltip) {
            VStack(alignment: .leading, spacing: 16) {
                switch password.statusCode {
                case .good:
                    Text("_passwordStatusGoodMessage")
                case .outdated:
                    Text("_passwordStatusOutdatedMessage")
                case .duplicate:
                    Text("_passwordStatusDuplicateMessage")
                case .breached:
                    Text("_passwordStatusBreachedMessage")
                case .unknown:
                    Text("_passwordStatusUnknownMessage")
                }
                if password.editable,
                   password.statusCode == .outdated || password.statusCode == .duplicate || password.statusCode == .breached {
                    Divider()
                        .padding(.trailing, -100)
                    Button {
                        showPasswordStatusTooltip = false
                        showEditPasswordView = true
                    }
                    label: {
                        Label("_editPassword", systemImage: "pencil")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                }
            }
            .padding()
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
        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
    }
    
    private func tagsSection(tags: [Tag], validTags: [Tag]) -> some View {
        Section(footer: HStack {
            Spacer()
            Button(validTags.isEmpty ? "_addTags" : "_editTags") {
                showSelectTagsView = true
            }
            .font(.footnote)
            .textCase(.uppercase)
            .buttonStyle(.borderless)
            .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
            .apply {
                view in
                if #available(iOS 15, *) {
                    view
                }
                else {
                    view
                        .padding(.top, 5)
                }
            }
            Spacer()
        }) {
            if !validTags.isEmpty {
                if UIDevice.current.userInterfaceIdiom == .pad { /// Disable tag buttons for iPad because of NavigationLink bugs
                    FlowView(validTags.sortedByLabel()) {
                        tag in
                        TagBadge(tag: tag, baseColor: Color(.secondarySystemGroupedBackground))
                    }
                }
                else {
                    ZStack {
                        ForEach(validTags) {
                            tag in
                            NavigationLink("", tag: .entries(tag: tag), selection: $navigationSelection) {
                                if #available(iOS 15, *) { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
                                    EntriesPage(entriesController: entriesController, tag: tag, showFilterSortMenu: false)
                                }
                                else {
                                    EntriesPageFallback(entriesController: entriesController, tag: tag, showFilterSortMenu: false)
                                }
                            }
                            .isDetailLink(false)
                        }
                        .hidden()
                        FlowView(validTags.sortedByLabel()) {
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
            SelectTagsNavigation(entriesController: entriesController, temporaryEntry: .password(label: password.label, username: password.username, url: password.url, tags: password.tags), selectTags: {
                validTags, invalidTags in
                password.tags = validTags.map { $0.id } + invalidTags
                entriesController.update(password: password)
            })
            .environmentObject(autoFillController)
            .environmentObject(biometricAuthenticationController)
            .environmentObject(sessionController)
            .environmentObject(settingsController)
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
            if let otp = password.otp {
                HStack {
                    OTPDisplay(otp: otp) {
                        otp in
                        password.updated = Date()
                        password.otp = otp
                        entriesController.update(password: password)
                    }
                    content: {
                        current, accessoryView in
                        LabeledRow(type: .pin, label: "_otp" as LocalizedStringKey, value: current ?? "", copiable: true)
                        Spacer()
                        switch otp.type {
                        case .hotp:
                            accessoryView
                        case .totp:
                            accessoryView
                                .padding(.horizontal, 4)
                        }
                    }
                    .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                }
            }
        }
    }
    
    private func customFieldsSection() -> some View {
        Section(header: Text("_customFields")) {
            ForEach(password.customUserFields) {
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
        Section {
            DisclosureGroup(isExpanded: $showMetadata) {
                VStack {
                    labeledFootnote("_created") {
                        Text(password.created.formattedString)
                    }
                    Spacer()
                    labeledFootnote("_updated") {
                        Text(password.updated.formattedString)
                    }
                    Spacer()
                    labeledFootnote("_encryption") {
                        switch (password.cseType, password.sseType) {
                        case ("none", "none"),
                            ("none", "unknown"):
                            Text("-")
                        case (_, "none"),
                            (_, "unknown"):
                            Text("_clientSide")
                        case ("none", _):
                            Text("_serverSide")
                        case (_, _):
                            Text("\("_clientSide".localized) & \("_serverSide".localized)")
                        }
                    }
                    if let folders = entriesController.folders {
                        Spacer()
                        labeledFootnote("_folder") {
                            FlowView(password.ancestors(in: folders), spacing: 5, alignment: .trailing) {
                                ancestor in
                                HStack(spacing: 5) {
                                    Text(ancestor.label)
                                    if password.folder != ancestor.id {
                                        Image(systemName: "chevron.forward")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                    Divider()
                    labeledFootnote("_id") {
                        Text(password.id.uppercased())
                    }
                    if let hashData = password.hash.data(using: .utf8) {
                        Spacer()
                        labeledFootnote("_hash") {
                            Text(Crypto.SHA1.hash(hashData, humanReadable: true))
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: -UIDevice.current.deviceSpecificPadding, bottom: 8, trailing: 16 - UIDevice.current.deviceSpecificPadding))
            }
            label: {
                Text("_metadata")
                    .textCase(.uppercase)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func labeledFootnote<Content: View>(_ labelKey: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .top) {
            Text(labelKey)
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
            content()
                .font(.footnote)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
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
            .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
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
            .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
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
                    switch autoFillController.mode {
                    case .app:
                        break
                    case .provider:
                        complete(password.username, password.password)
                    case .extension:
                        guard let currentOtp = password.otp?.current else {
                            return
                        }
                        complete(password.username, currentOtp)
                    }
                }
                .buttonStyle(.action)
                .disabled(password.state == .decryptionFailed)
            }
            .padding()
        }
        .padding(.bottom, geometryProxy.safeAreaInsets.bottom)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    @ViewBuilder private func stateView() -> some View {
        if let state = password.state {
            if state.isError {
                errorButton(state: state)
            }
            else if state.isProcessing {
                ProgressView()
            }
        }
    }
    
    private func editButton() -> some View {
        Button(action: {
            showEditPasswordView = true
        }, label: {
            Text("_edit")
        })
        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
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
    
    private enum NavigationSelection: Hashable {
        
        case entries(tag: Tag)
        
    }
    
}


struct PasswordDetailPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                PasswordDetailPage(entriesController: EntriesController.mock, password: Password.mock, updatePassword: {}, deletePassword: {})
            }
            .showColumns(false)
            .environmentObject(AutoFillController.mock)
            .environmentObject(BiometricAuthenticationController.mock)
            .environmentObject(SessionController.mock)
            .environmentObject(TipController.mock)
        }
    }
    
}
