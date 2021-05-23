import SwiftUI


struct EntriesPage: View {
    
    @ObservedObject var entriesController: EntriesController
    @ObservedObject var folder: Folder
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var tipController: TipController
    
    @State private var showServerSetupView = SessionController.default.session == nil
    @State private var showSettingsView = false
    @State private var folderForEditing: Folder?
    @State private var passwordForEditing: Password?
    @State private var folderForDeletion: Folder?
    @State private var passwordForDeletion: Password?
    @State private var searchTerm = ""
    @State private var showErrorAlert = false
    @State private var challengePassword = ""
    @State private var storeChallengePassword = false
    @State private var showStorePasswordMessage = false
    
    init(entriesController: EntriesController, folder: Folder? = nil) {
        self.entriesController = entriesController
        self.folder = folder ?? Folder()
    }
    
    // MARK: Views
    
    var body: some View {
        let entries = EntriesController.processEntries(passwords: entriesController.passwords, folders: entriesController.folders, folder: folder, searchTerm: searchTerm, filterBy: entriesController.filterBy, sortBy: entriesController.sortBy, reversed: entriesController.reversed)
        let suggestions = EntriesController.processSuggestions(passwords: entriesController.passwords, serviceURLs: autoFillController.serviceURLs)
        return mainStack(entries: entries, suggestions: suggestions)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingToolbarView()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if sessionController.session != nil,
                       entriesController.state != .error && (sessionController.state != .error || entriesController.state == .offline),
                       !sessionController.state.isChallengeAvailable,
                       entriesController.state == .offline || entriesController.state == .online,
                       let entries = entries {
                        trailingToolbarView(entries: entries)
                    }
                }
            }
            .navigationTitle(folder.label)
    }
    
    private func mainStack(entries: [Entry]?, suggestions: [Password]?) -> some View {
        VStack {
            if sessionController.session == nil {
                connectView()
            }
            else if entriesController.state == .error || sessionController.state == .error {
                errorView()
            }
            else if sessionController.state.isChallengeAvailable {
                challengeView()
            }
            else if entriesController.state == .offline || entriesController.state == .online,
                    sessionController.state == .offline || sessionController.state == .online,
                    let entries = entries {
                listView(entries: entries, suggestions: suggestions)
                    .searchBar(term: $searchTerm)
            }
            else {
                ProgressView()
            }
            EmptyView()
                .sheet(isPresented: $showSettingsView) {
                    SettingsNavigation(updateOfflineContainers: {
                        entriesController.updateOfflineContainers()
                    })
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(tipController)
                }
        }
    }
    
    private func connectView() -> some View {
        VStack {
            Button("_connectToServer") {
                showServerSetupView = true
            }
            .frame(maxWidth: 600)
            .buttonStyle(ActionButtonStyle())
            EmptyView()
                .sheet(isPresented: $showServerSetupView) {
                    ServerSetupNavigation()
                        .environmentObject(autoFillController)
                        .environmentObject(biometricAuthenticationController)
                        .environmentObject(sessionController)
                        .environmentObject(tipController)
                }
        }
        .padding()
    }
    
    private func errorView() -> some View {
        VStack {
            Text("_anErrorOccurred")
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    private func challengeView() -> some View {
        List {
            Section(header: Text("_e2ePassword")) {
                SecureField("-", text: $challengePassword, onCommit: {
                    solveChallenge()
                })
                .frame(maxWidth: 600)
                .onAppear {
                    challengePassword = ""
                }
            }
            Section {
                Toggle(isOn: $storeChallengePassword) {
                    HStack {
                        Text("_storePassword")
                        Button {
                            showStorePasswordMessage = true
                        }
                        label: {
                            Image(systemName: "questionmark.circle")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .alert(isPresented: $showStorePasswordMessage) {
                            Alert(title: Text("_storePassword"), message: Text("_storePasswordMessage"))
                        }
                    }
                }
                .frame(maxWidth: 600)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 2))
                .listRowBackground(Color(UIColor.systemGroupedBackground))
            }
            Button("_logIn") {
                solveChallenge()
            }
            .frame(maxWidth: 600)
            .buttonStyle(ActionButtonStyle())
            .listRowInsets(EdgeInsets())
            .disabled(challengePassword.count < 12)
        }
        .listStyle(InsetGroupedListStyle())
        .frame(maxWidth: 600)
    }
    
    private func listView(entries: [Entry], suggestions: [Password]?) -> some View {
        VStack {
            if let suggestions = suggestions,
               suggestions.isEmpty || folder.isBaseFolder {
                List {
                    Section(header: Text("_suggestions")) {
                        if !suggestions.isEmpty {
                            suggestionRows(suggestions: suggestions)
                        }
                        else {
                            Button(action: {
                                passwordForEditing = Password(url: autoFillController.serviceURLs?.first?.absoluteString ?? "", folder: folder.id, client: Configuration.clientName, favorite: folder.isBaseFolder && entriesController.filterBy == .favorites)
                            }, label: {
                                Text("_createPassword")
                            })
                            .buttonStyle(ActionButtonStyle())
                            .disabled(entriesController.state != .online || folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                        }
                    }
                    if !entries.isEmpty {
                        Section(header: Text("_all")) {
                            entryRows(entries: entries)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            else if !entries.isEmpty {
                List {
                    entryRows(entries: entries)
                }
                .listStyle(PlainListStyle())
            }
            else {
                Text("_nothingToSeeHere")
                    .foregroundColor(.gray)
                    .padding()
            }
            EmptyView()
                .sheet(item: $folderForEditing) {
                    folder in
                    EditFolderNavigation(folder: folder, addFolder: {
                        entriesController.add(folder: folder)
                    }, updateFolder: {
                        entriesController.update(folder: folder)
                    })
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(tipController)
                }
                .actionSheet(item: $folderForDeletion) {
                    folder in
                    ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deleteFolder")) {
                        entriesController.delete(folder: folder)
                    }])
                }
            EmptyView()
                .sheet(item: $passwordForEditing) {
                    password in
                    EditPasswordNavigation(password: password, addPassword: {
                        entriesController.add(password: password)
                    }, updatePassword: {
                        entriesController.update(password: password)
                    })
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(tipController)
                }
                .actionSheet(item: $passwordForDeletion) {
                    password in
                    ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deletePassword")) {
                        entriesController.delete(password: password)
                    }])
                }
        }
    }
    
    private func suggestionRows(suggestions: [Password]) -> some View {
        ForEach(suggestions) {
            password in
            PasswordRow(entriesController: entriesController, password: password, showStatus: entriesController.sortBy == .status, editPassword: {
                passwordForEditing = password
            }, deletePassword: {
                passwordForDeletion = password
            })
            .deleteDisabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
        }
        .onDelete {
            indices in
            passwordForDeletion = suggestions[safe: indices.first]
        }
    }
    
    private func entryRows(entries: [Entry]) -> some View {
        ForEach(entries) {
            entry -> AnyView in
            switch entry {
            case .folder(let folder):
                let folderRow = FolderRow(entriesController: entriesController, folder: folder, editFolder: {
                    folderForEditing = folder
                }, deleteFolder: {
                    folderForDeletion = folder
                })
                .deleteDisabled(entriesController.state != .online || folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                return AnyView(folderRow)
            case .password(let password):
                let passwordRow = PasswordRow(entriesController: entriesController, password: password, showStatus: entriesController.sortBy == .status, editPassword: {
                    passwordForEditing = password
                }, deletePassword: {
                    passwordForDeletion = password
                })
                .deleteDisabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                return AnyView(passwordRow)
            }
        }
        .onDelete {
            indices in
            onDeleteEntry(entry: entries[safe: indices.first])
        }
    }
    
    private func leadingToolbarView() -> some View {
        HStack {
            if folder.isBaseFolder {
                if let cancel = autoFillController.cancel {
                    Button("_cancel") {
                        cancel()
                    }
                }
                else {
                    Button("_settings") {
                        showSettingsView = true
                    }
                }
            }
        }
    }
    
    private func trailingToolbarView(entries: [Entry]) -> some View {
        HStack {
            if let state = folder.state {
                if state.isError {
                    errorButton(state: state)
                }
                else if state.isProcessing {
                    ProgressView()
                }
                Spacer()
            }
            filterSortMenu()
            createMenu()
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
        .buttonStyle(BorderlessButtonStyle())
        .alert(isPresented: $showErrorAlert) {
            switch state {
            case .creationFailed:
                return Alert(title: Text("_error"), message: Text("_createFolderErrorMessage"))
            case .updateFailed:
                return Alert(title: Text("_error"), message: Text("_editFolderErrorMessage"))
            case .deletionFailed:
                return Alert(title: Text("_error"), message: Text("_deleteFolderErrorMessage"))
            case .decryptionFailed:
                return Alert(title: Text("_error"), message: Text("_decryptFolderErrorMessage"))
            default:
                return Alert(title: Text("_error"))
            }
        }
    }
    
    private func filterSortMenu() -> some View {
        Menu {
            Picker("", selection: $entriesController.filterBy) {
                Label("_all", systemImage: "list.bullet")
                    .tag(EntriesController.Filter.all)
                Label("_folders", systemImage: "folder")
                    .tag(EntriesController.Filter.folders)
                Label("_favorites", systemImage: "star")
                    .tag(EntriesController.Filter.favorites)
            }
            Picker("", selection: $entriesController.sortBy) {
                Label("_name", systemImage: entriesController.reversed ? "chevron.down" : "chevron.up")
                    .showIcon(entriesController.sortBy == .label)
                    .tag(EntriesController.Sorting.label)
                Label("_updated", systemImage: entriesController.reversed ? "chevron.down" : "chevron.up")
                    .showIcon(entriesController.sortBy == .updated)
                    .tag(EntriesController.Sorting.updated)
                Label("_username", systemImage: entriesController.reversed ? "chevron.down" : "chevron.up")
                    .showIcon(entriesController.sortBy == .username)
                    .tag(EntriesController.Sorting.username)
                Label("_url", systemImage: entriesController.reversed ? "chevron.down" : "chevron.up")
                    .showIcon(entriesController.sortBy == .url)
                    .tag(EntriesController.Sorting.url)
                Label("_security", systemImage: entriesController.reversed ? "chevron.down" : "chevron.up")
                    .showIcon(entriesController.sortBy == .status)
                    .tag(EntriesController.Sorting.status)
            }
        }
        label: {
            Spacer()
            Image(systemName: "arrow.up.arrow.down")
                .accessibility(identifier: "filterSortMenu")
            Spacer()
        }
        .onChange(of: entriesController.filterBy, perform: didChange)
    }
    
    private func createMenu() -> some View {
        Menu {
            Button(action: {
                folderForEditing = Folder(parent: folder.id, client: Configuration.clientName, favorite: folder.isBaseFolder && entriesController.filterBy == .favorites)
            }, label: {
                Label("_createFolder", systemImage: "folder")
            })
            Button(action: {
                passwordForEditing = Password(url: autoFillController.serviceURLs?.first?.absoluteString ?? "", folder: folder.id, client: Configuration.clientName, favorite: folder.isBaseFolder && entriesController.filterBy == .favorites)
            }, label: {
                Label("_createPassword", systemImage: "key")
            })
        }
        label: {
            Spacer()
            Image(systemName: "plus")
        }
        .disabled(entriesController.state != .online || folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
    }
    
    // MARK: Functions
    
    private func solveChallenge() {
        if !challengePassword.isEmpty {
            sessionController.solveChallenge(password: challengePassword, store: storeChallengePassword)
        }
    }
    
    private func onDeleteEntry(entry: Entry?) {
        switch entry {
        case .folder(let folder):
            folderForDeletion = folder
        case .password(let password):
            passwordForDeletion = password
        case .none:
            break
        }
    }
    
    private func didChange(filterBy: EntriesController.Filter) {
        if !folder.isBaseFolder,
           filterBy != .folders {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
}


extension EntriesPage {
    
    struct FolderRow: View {
        
        @ObservedObject var entriesController: EntriesController
        @ObservedObject var folder: Folder
        let editFolder: () -> Void
        let deleteFolder: () -> Void
        
        @State private var showErrorAlert = false
        
        // MARK: Views
        
        var body: some View {
            entriesPageLink()
                .contextMenu {
                    Button {
                        toggleFavorite()
                    }
                    label: {
                        Label("_favorite", systemImage: folder.favorite ? "star.fill" : "star")
                    }
                    .disabled(entriesController.state != .online || folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                    Button {
                        editFolder()
                    }
                    label: {
                        Label("_edit", systemImage: "pencil")
                    }
                    .disabled(entriesController.state != .online || folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                    Divider()
                    Button {
                        deleteFolder()
                    }
                    label: {
                        Label("_delete", systemImage: "trash")
                    }
                    .disabled(entriesController.state != .online || folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                }
        }
        
        private func entriesPageLink() -> some View {
            NavigationLink(destination: EntriesPage(entriesController: entriesController, folder: folder)) {
                mainStack()
            }
            .isDetailLink(false)
        }
        
        private func mainStack() -> some View {
            HStack {
                folderImage()
                labelText()
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    if let state = folder.state {
                        if state.isError {
                            errorButton(state: state)
                        }
                        else if state.isProcessing {
                            ProgressView()
                        }
                    }
                    if folder.favorite {
                        favoriteImage()
                    }
                }
            }
        }
        
        private func folderImage() -> some View {
            Image(systemName: "folder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(Color.accentColor)
        }
        
        private func labelText() -> some View {
            VStack(alignment: .leading) {
                Text(folder.label)
                    .lineLimit(1)
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
            .buttonStyle(BorderlessButtonStyle())
            .alert(isPresented: $showErrorAlert) {
                switch state {
                case .creationFailed:
                    return Alert(title: Text("_error"), message: Text("_createFolderErrorMessage"))
                case .updateFailed:
                    return Alert(title: Text("_error"), message: Text("_editFolderErrorMessage"))
                case .deletionFailed:
                    return Alert(title: Text("_error"), message: Text("_deleteFolderErrorMessage"))
                case .decryptionFailed:
                    return Alert(title: Text("_error"), message: Text("_decryptFolderErrorMessage"))
                default:
                    return Alert(title: Text("_error"))
                }
            }
        }
        
        private func favoriteImage() -> some View {
            Image(systemName: "star.fill")
                .foregroundColor(.gray)
        }
        
        // MARK: Functions
        
        private func toggleFavorite() {
            folder.edited = Date()
            folder.updated = Date()
            folder.favorite.toggle()
            entriesController.update(folder: folder)
        }
        
    }
    
}


extension EntriesPage {
    
    struct PasswordRow: View {
        
        @ObservedObject var entriesController: EntriesController
        @ObservedObject var password: Password
        let showStatus: Bool
        let editPassword: () -> Void
        let deletePassword: () -> Void
        
        @EnvironmentObject private var autoFillController: AutoFillController
        @EnvironmentObject private var sessionController: SessionController
        
        @State private var favicon: UIImage?
        @State private var showPasswordDetailView = false
        @State private var showErrorAlert = false
        
        // MARK: Views
        
        var body: some View {
            wrapperStack()
                .contextMenu {
                    Button {
                        UIPasteboard.general.privateString = password.password
                    }
                    label: {
                        Label("_copyPassword", systemImage: "doc.on.doc")
                    }
                    if !password.username.isEmpty {
                        Button {
                            UIPasteboard.general.string = password.username
                        }
                        label: {
                            Label("_copyUsername", systemImage: "doc.on.doc")
                        }
                    }
                    if let url = URL(string: password.url),
                       let canOpenURL = UIApplication.safeCanOpenURL,
                       canOpenURL(url),
                       let open = UIApplication.safeOpen {
                        Button {
                            open(url)
                        }
                        label: {
                            Label("_openUrl", systemImage: "safari")
                        }
                    }
                    Divider()
                    Button {
                        toggleFavorite()
                    }
                    label: {
                        Label("_favorite", systemImage: password.favorite ? "star.fill" : "star")
                    }
                    .disabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                    if password.editable {
                        Button {
                            editPassword()
                        }
                        label: {
                            Label("_edit", systemImage: "pencil")
                        }
                        .disabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                    }
                    Divider()
                    Button {
                        deletePassword()
                    }
                    label: {
                        Label("_delete", systemImage: "trash")
                    }
                    .disabled(entriesController.state != .online || password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                }
        }
        
        private func wrapperStack() -> some View {
            HStack {
                if let complete = autoFillController.complete {
                    Button {
                        complete(password.username, password.password)
                    }
                    label: {
                        mainStack()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                    Spacer()
                    Button {
                        showPasswordDetailView = true
                    }
                    label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    NavigationLink(destination: PasswordDetailPage(entriesController: entriesController, password: password, updatePassword: {
                        entriesController.update(password: password)
                    }, deletePassword: {
                        entriesController.delete(password: password)
                    }), isActive: $showPasswordDetailView) {}
                    .isDetailLink(true)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                }
                else {
                    NavigationLink(destination: PasswordDetailPage(entriesController: entriesController, password: password, updatePassword: {
                        entriesController.update(password: password)
                    }, deletePassword: {
                        entriesController.delete(password: password)
                    })) {
                        mainStack()
                    }
                    .isDetailLink(true)
                }
            }
        }
        
        private func mainStack() -> some View {
            HStack {
                faviconImage()
                labelStack()
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    if let state = password.state {
                        if state.isError {
                            errorButton(state: state)
                        }
                        else if state.isProcessing {
                            ProgressView()
                        }
                    }
                    if password.favorite {
                        favoriteImage()
                    }
                    if showStatus {
                        statusImage()
                    }
                }
            }
        }
        
        private func faviconImage() -> some View {
            Image(uiImage: favicon ?? UIImage())
                .resizable()
                .frame(width: 40, height: 40)
                .background(favicon == nil ? Color(white: 0.5, opacity: 0.2) : nil)
                .cornerRadius(3.75)
                .onAppear {
                    requestFavicon()
                }
                .onChange(of: password.url) {
                    _ in
                    requestFavicon()
                }
        }
        
        private func labelStack() -> some View {
            VStack(alignment: .leading) {
                Text(password.label)
                    .lineLimit(1)
                Text(!password.username.isEmpty ? password.username : "-")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
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
            .buttonStyle(BorderlessButtonStyle())
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
        
        private func favoriteImage() -> some View {
            Image(systemName: "star.fill")
                .foregroundColor(.gray)
        }
        
        private func statusImage() -> some View {
            switch password.statusCode {
            case .good:
                return Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
            case .outdated, .duplicate:
                return Image(systemName: "exclamationmark.shield.fill")
                    .foregroundColor(.yellow)
            case .breached:
                return Image(systemName: "xmark.shield.fill")
                    .foregroundColor(.red)
            }
        }
        
        // MARK: Functions
        
        private func toggleFavorite() {
            password.updated = Date()
            password.favorite.toggle()
            entriesController.update(password: password)
        }
        
        private func requestFavicon() {
            guard let domain = URL(string: password.url)?.host ?? URL(string: "https://\(password.url)")?.host,
                  let session = sessionController.session else {
                return
            }
            FaviconServiceRequest(session: session, domain: domain).send { favicon = $0 }
        }
        
    }
    
}


struct EntriesPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                EntriesPage(entriesController: EntriesController.mock)
            }
            .showColumns(true)
            .environmentObject(AutoFillController.mock)
            .environmentObject(BiometricAuthenticationController.mock)
            .environmentObject(SessionController.mock)
            .environmentObject(TipController.mock)
        }
    }
    
}
