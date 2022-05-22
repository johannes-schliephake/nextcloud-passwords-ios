import SwiftUI


struct EntriesPage: View {
    
    @ObservedObject var entriesController: EntriesController
    private let showFilterSortMenu: Bool
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var settingsController: SettingsController
    @EnvironmentObject private var tipController: TipController
    
    @StateObject private var folderController: FolderController
    @available(iOS 15, *) @FocusState private var focusedField: FocusField?
    @State private var showServerSetupView = SessionController.default.session == nil
    @State private var showSettingsView = false
    @State private var challengePassword = ""
    @State private var storeChallengePassword = false
    @State private var showStorePasswordTooltip = false
    @State private var sheetItem: SheetItem?
    @State private var actionSheetItem: ActionSheetItem?
    @State private var showFolderErrorAlert = false
    @State private var showTagErrorAlert = false
    @State private var showOfflineText = false
    
    init(entriesController: EntriesController, folder: Folder? = nil, tag: Tag? = nil, showFilterSortMenu: Bool = true) {
        self.entriesController = entriesController
        _folderController = StateObject(wrappedValue: FolderController(entriesController: entriesController, folder: folder, tag: tag, defaultSorting: showFilterSortMenu ? nil : .label))
        self.showFilterSortMenu = showFilterSortMenu
    }
    
    // MARK: Views
    
    var body: some View {
        mainStack()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingToolbarView()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if sessionController.session != nil,
                       entriesController.state != .error && sessionController.state != .error,
                       !sessionController.state.isChallengeAvailable,
                       entriesController.state == .offline || entriesController.state == .online,
                       autoFillController.credentialIdentifier == nil,
                       let entries = folderController.entries {
                        trailingToolbarView(entries: entries)
                    }
                }
                ToolbarItem(placement: .principal) {
                    if #available(iOS 15, *) {
                        if entriesController.state == .offline || sessionController.state == .offlineChallengeAvailable {
                            principalToolbarView()
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .onAppear {
                folderController.autoFillController = autoFillController
            }
    }
    
    private var navigationTitle: String {
        guard sessionController.session != nil,
              autoFillController.credentialIdentifier == nil else {
            return "_passwords".localized
        }
        guard autoFillController.mode != .extension else {
            return "_otps".localized
        }
        switch (entriesController.filterBy, folderController.folder.isBaseFolder, folderController.tag) {
        case (.all, true, nil):
            return "_passwords".localized
        case (.folders, true, nil):
            return "_folders".localized
        case (.favorites, true, nil):
            return "_favorites".localized
        case (.tags, true, nil):
            return "_tags".localized
        case (.otps, true, nil):
            return "_otps".localized
        case (_, _, .some(let tag)):
            return tag.label
        case (_, false, _):
            return folderController.folder.label
        }
    }
    
    private func mainStack() -> some View {
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
                    autoFillController.credentialIdentifier == nil,
                    let entries = folderController.entries,
                    let folders = entriesController.folders,
                    let tags = entriesController.tags {
                listView(entries: entries, folders: folders, tags: tags)
            }
            else {
                ProgressView()
            }
        }
        .background(
            /// This hack is necessary because the toolbar, where this sheet would actually belong, is buggy, iOS 14 can't stack sheets (not even throughout the view hierarchy) and iOS 15 can't use sheets on EmptyView (previous hack)
            Color.clear
                .sheet(isPresented: $showSettingsView) {
                    SettingsNavigation(updateOfflineData: {
                        entriesController.updateOfflineContainers()
                        entriesController.updateAutoFillCredentials()
                    })
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(settingsController)
                    .environmentObject(tipController)
                }
        )
    }
    
    private func connectView() -> some View {
        VStack {
            Button("_connectToServer") {
                showServerSetupView = true
            }
            .frame(maxWidth: 600)
            .buttonStyle(.action)
            .sheet(isPresented: $showServerSetupView) {
                ServerSetupNavigation()
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(settingsController)
                    .environmentObject(tipController)
            }
        }
        .padding()
    }
    
    private func errorView() -> some View {
        List {
            VStack(alignment: .center) {
                Text("_anErrorOccurred")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
                Button {
                    entriesController.refresh()
                }
                label: {
                    Label("_tryAgain", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color(UIColor.systemGroupedBackground))
        }
        .apply {
            view in
            if #available(iOS 15, *) {
                view
                    .refreshable {
                        await entriesController.refresh()
                    }
            }
            else {
                view
                    .refreshGesture {
                        endRefreshing in
                        entriesController.refresh {
                            endRefreshing()
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func challengeView() -> some View {
        List {
            Section(header: Text("_e2ePassword")) {
                SecureField("-", text: $challengePassword, onCommit: {
                    solveChallenge()
                })
                .frame(maxWidth: 600)
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .focused($focusedField, equals: .challengePassword)
                            .submitLabel(.done)
                    }
                }
                .onAppear {
                    challengePassword = ""
                }
            }
            Section {
                Toggle(isOn: $storeChallengePassword) {
                    HStack {
                        Text("_storePassword")
                        Button {
                            showStorePasswordTooltip = true
                        }
                        label: {
                            Image(systemName: "questionmark.circle")
                        }
                        .buttonStyle(.borderless)
                        .tooltip(isPresented: $showStorePasswordTooltip) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("_storePasswordMessage")
                            }
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
            .buttonStyle(.action)
            .listRowInsets(EdgeInsets())
            .disabled(challengePassword.count < 12)
        }
        .listStyle(.insetGrouped)
        .frame(maxWidth: 600)
        .apply {
            view in
            if #available(iOS 15, *) {
                view
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
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
                    .initialize(focus: $focusedField, with: .challengePassword)
            }
        }
    }
    
    private func listView(entries: [Entry], folders: [Folder], tags: [Tag]) -> some View {
        VStack {
            if let suggestions = folderController.suggestions,
               folderController.searchTerm.isEmpty,
               suggestions.isEmpty && autoFillController.mode == .provider || !suggestions.isEmpty && folderController.folder.isBaseFolder && folderController.tag == nil {
                List {
                    Section(header: Text("_suggestions")) {
                        if !suggestions.isEmpty {
                            suggestionRows(suggestions: suggestions)
                        }
                        else {
                            Button(action: {
                                sheetItem = .edit(entry: .password(Password(url: autoFillController.serviceURLs?.first?.absoluteString ?? "", folder: folderController.folder.id, client: Configuration.clientName, favorite: folderController.folder.isBaseFolder && folderController.tag == nil && entriesController.filterBy == .favorites, tags: [folderController.tag?.id].compactMap { $0 })))
                            }, label: {
                                Text("_createPassword")
                            })
                            .buttonStyle(.action)
                            .disabled(folderController.folder.state?.isProcessing ?? false || folderController.tag?.state?.isProcessing ?? false || folderController.folder.state == .decryptionFailed || folderController.tag?.state == .decryptionFailed)
                        }
                    }
                    if !entries.isEmpty {
                        Section(header: Text("_all")) {
                            entryRows(entries: entries)
                        }
                    }
                }
                .listStyle(.plain)
            }
            else if !entries.isEmpty {
                List {
                    entryRows(entries: entries)
                }
                .listStyle(.plain)
            }
            else {
                List {
                    VStack(alignment: .center) {
                        Text("_nothingToSeeHere")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                .listStyle(.insetGrouped)
            }
        }
        .apply {
            view in
            if #available(iOS 15, *) {
                view
                    .searchable(text: $folderController.searchTerm)
                    .keyboardType(.alphabet)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .refreshable {
                        await entriesController.refresh()
                    }
            }
            else {
                view
                    .searchBar(term: $folderController.searchTerm)
                    .refreshGesture {
                        endRefreshing in
                        entriesController.refresh {
                            endRefreshing()
                        }
                    }
            }
        }
        .sheet(item: $sheetItem) {
            item in
            switch item {
            case .edit(.folder(let folder)):
                EditFolderNavigation(entriesController: entriesController, folder: folder)
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(settingsController)
                    .environmentObject(tipController)
            case .edit(.password(let password)):
                EditPasswordNavigation(entriesController: entriesController, password: password)
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(settingsController)
                    .environmentObject(tipController)
            case .edit(.tag(let tag)):
                EditTagNavigation(entriesController: entriesController, tag: tag)
                    .environmentObject(autoFillController)
                    .environmentObject(biometricAuthenticationController)
                    .environmentObject(sessionController)
                    .environmentObject(settingsController)
                    .environmentObject(tipController)
            case .move(.folder(let folder)):
                SelectFolderNavigation(entriesController: entriesController, entry: .folder(folder), temporaryEntry: .folder(label: folder.label, parent: folder.parent), selectFolder: {
                    parent in
                    folder.parent = parent.id
                    entriesController.update(folder: folder)
                })
                .environmentObject(autoFillController)
                .environmentObject(biometricAuthenticationController)
                .environmentObject(sessionController)
                .environmentObject(settingsController)
                .environmentObject(tipController)
            case .move(.password(let password)):
                SelectFolderNavigation(entriesController: entriesController, entry: .password(password), temporaryEntry: .password(label: password.label, username: password.username, url: password.url, folder: password.folder), selectFolder: {
                    parent in
                    password.folder = parent.id
                    entriesController.update(password: password)
                })
                .environmentObject(autoFillController)
                .environmentObject(biometricAuthenticationController)
                .environmentObject(sessionController)
                .environmentObject(settingsController)
                .environmentObject(tipController)
            case .move(.tag):
                EmptyView()
            case .tag(.folder):
                EmptyView()
            case .tag(.password(let password)):
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
            case .tag(.tag):
                EmptyView()
            }
        }
        .actionSheet(item: $actionSheetItem) {
            item in
            switch item {
            case .delete(.folder(let folder)):
                return ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deleteFolder")) {
                    entriesController.delete(folder: folder)
                }])
            case .delete(.password(let password)):
                return ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deletePassword")) {
                    entriesController.delete(password: password)
                }])
            case .delete(.tag(let tag)):
                return ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deleteTag")) {
                    entriesController.delete(tag: tag)
                }])
            }
        }
    }
    
    private func suggestionRows(suggestions: [Password]) -> some View {
        ForEach(suggestions) {
            password in
            PasswordRow(entriesController: entriesController, folderController: folderController, password: password, editPassword: {
                sheetItem = .edit(entry: .password(password))
            }, movePassword: {
                sheetItem = .move(entry: .password(password))
            }, tagPassword: {
                sheetItem = .tag(entry: .password(password))
            }, deletePassword: {
                actionSheetItem = .delete(entry: .password(password))
            })
            .deleteDisabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
        }
        .apply {
            view in
            if #unavailable(iOS 15) {
                view
                    .onDelete {
                        indices in
                        guard let password = suggestions[safe: indices.first] else {
                            return
                        }
                        actionSheetItem = .delete(entry: .password(password))
                    }
            }
        }
    }
    
    private func entryRows(entries: [Entry]) -> some View {
        ForEach(entries) {
            entry -> AnyView in
            switch entry {
            case .folder(let folder):
                let folderRow = FolderRow(entriesController: entriesController, folder: folder, editFolder: {
                    sheetItem = .edit(entry: .folder(folder))
                }, moveFolder: {
                    sheetItem = .move(entry: .folder(folder))
                }, deleteFolder: {
                    actionSheetItem = .delete(entry: .folder(folder))
                })
                .deleteDisabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                return AnyView(folderRow)
            case .password(let password):
                let passwordRow = PasswordRow(entriesController: entriesController, folderController: folderController, password: password, editPassword: {
                    sheetItem = .edit(entry: .password(password))
                }, movePassword: {
                    sheetItem = .move(entry: .password(password))
                }, tagPassword: {
                    sheetItem = .tag(entry: .password(password))
                }, deletePassword: {
                    actionSheetItem = .delete(entry: .password(password))
                })
                .deleteDisabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                return AnyView(passwordRow)
            case .tag(let tag):
                let tagRow = TagRow(entriesController: entriesController, tag: tag, editTag: {
                    sheetItem = .edit(entry: .tag(tag))
                }, deleteTag: {
                    actionSheetItem = .delete(entry: .tag(tag))
                })
                .deleteDisabled(tag.state?.isProcessing ?? false || tag.state == .decryptionFailed)
                return AnyView(tagRow)
            }
        }
        .apply {
            view in
            if #unavailable(iOS 15) {
                view
                    .onDelete {
                        indices in
                        onDeleteEntry(entry: entries[safe: indices.first])
                    }
            }
        }
    }
    
    private func leadingToolbarView() -> some View {
        HStack {
            if folderController.folder.isBaseFolder && folderController.tag == nil {
                if let cancel = autoFillController.cancel {
                    if #available(iOS 15.0, *) {
                        Button("_cancel", role: .cancel) {
                            cancel()
                        }
                    }
                    else {
                        Button("_cancel") {
                            cancel()
                        }
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
            if let state = folderController.folder.state {
                if state.isError {
                    folderErrorButton(state: state)
                }
                else if state.isProcessing {
                    ProgressView()
                }
                Spacer()
            }
            else if let state = folderController.tag?.state {
                if state.isError {
                    tagErrorButton(state: state)
                }
                else if state.isProcessing {
                    ProgressView()
                }
                Spacer()
            }
            if autoFillController.mode != .extension {
                if showFilterSortMenu {
                    filterSortMenu()
                }
                createMenu()
            }
        }
    }
    
    private func principalToolbarView() -> some View {
        ZStack {
            if showOfflineText {
                Text("_offline")
            }
            else {
                Button {
                    withAnimation {
                        showOfflineText = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2200)) {
                        withAnimation {
                            showOfflineText = false
                        }
                    }
                }
                label: {
                    Image(systemName: "bolt.horizontal.fill")
                }
            }
        }
        .fixedSize()
        .animation(.easeInOut(duration: 0.2))
        .foregroundColor(Color(UIColor.systemGray3))
    }
    
    private func folderErrorButton(state: Entry.State) -> some View {
        Button {
            showFolderErrorAlert = true
        }
        label: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(state == .deletionFailed ? .gray : .red)
        }
        .buttonStyle(.borderless)
        .alert(isPresented: $showFolderErrorAlert) {
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
    
    private func tagErrorButton(state: Entry.State) -> some View {
        Button {
            showTagErrorAlert = true
        }
        label: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(state == .deletionFailed ? .gray : .red)
        }
        .buttonStyle(.borderless)
        .alert(isPresented: $showTagErrorAlert) {
            switch state {
            case .creationFailed:
                return Alert(title: Text("_error"), message: Text("_createTagErrorMessage"))
            case .updateFailed:
                return Alert(title: Text("_error"), message: Text("_editTagErrorMessage"))
            case .deletionFailed:
                return Alert(title: Text("_error"), message: Text("_deleteTagErrorMessage"))
            case .decryptionFailed:
                return Alert(title: Text("_error"), message: Text("_decryptTagErrorMessage"))
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
                Label("_tags", systemImage: "tag")
                    .tag(EntriesController.Filter.tags)
                Label("_otps", systemImage: "ellipsis.rectangle")
                    .tag(EntriesController.Filter.otps)
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
            HStack {
                Spacer()
                Image(systemName: "arrow.up.arrow.down")
            }
        }
        .accessibility(identifier: "filterSortMenu")
        .onChange(of: entriesController.filterBy, perform: didChange)
    }
    
    private func createMenu() -> some View {
        Menu {
            Button(action: {
                sheetItem = .edit(entry: .folder(Folder(parent: folderController.folder.id, client: Configuration.clientName, favorite: folderController.folder.isBaseFolder && folderController.tag == nil && entriesController.filterBy == .favorites)))
            }, label: {
                Label("_createFolder", systemImage: "folder")
            })
            Button(action: {
                sheetItem = .edit(entry: .password(Password(url: autoFillController.serviceURLs?.first?.absoluteString ?? "", folder: folderController.folder.id, client: Configuration.clientName, favorite: folderController.folder.isBaseFolder && folderController.tag == nil && entriesController.filterBy == .favorites, tags: [folderController.tag?.id].compactMap { $0 })))
            }, label: {
                Label("_createPassword", systemImage: "key")
            })
            Button(action: {
                sheetItem = .edit(entry: .tag(Tag(client: Configuration.clientName, favorite: folderController.folder.isBaseFolder && folderController.tag == nil && entriesController.filterBy == .favorites)))
            }, label: {
                Label("_createTag", systemImage: "tag")
            })
        }
        label: {
            HStack {
                Spacer()
                Image(systemName: "plus")
            }
        }
        .disabled(folderController.folder.state?.isProcessing ?? false || folderController.tag?.state?.isProcessing ?? false || folderController.folder.state == .decryptionFailed || folderController.tag?.state == .decryptionFailed)
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
            actionSheetItem = .delete(entry: .folder(folder))
        case .password(let password):
            actionSheetItem = .delete(entry: .password(password))
        case .tag(let tag):
            actionSheetItem = .delete(entry: .tag(tag))
        case .none:
            break
        }
    }
    
    private func didChange(filterBy: EntriesController.Filter) {
        if !folderController.folder.isBaseFolder || folderController.tag != nil,
           filterBy != .folders {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
}


extension EntriesPage {
    
    private enum SheetItem: Identifiable {
        
        case edit(entry: Entry)
        case move(entry: Entry)
        case tag(entry: Entry)
        
        var id: String {
            switch self {
            case .edit(let entry), .move(let entry), .tag(let entry):
                return entry.id
            }
        }
        
    }
    
}


extension EntriesPage {
    
    private enum ActionSheetItem: Identifiable {
        
        case delete(entry: Entry)
        
        var id: String {
            switch self {
            case .delete(let entry):
                return entry.id
            }
        }
        
    }
    
}


extension EntriesPage {
    
    private enum FocusField: Hashable {
        case challengePassword
    }
    
}


extension EntriesPage {
    
    private struct FolderRow: View {
        
        @ObservedObject var entriesController: EntriesController
        @ObservedObject var folder: Folder
        let editFolder: () -> Void
        let moveFolder: () -> Void
        let deleteFolder: () -> Void
        
        @State private var showErrorAlert = false
        
        // MARK: Views
        
        var body: some View {
            entriesPageLink()
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    toggleFavorite()
                                }
                                label: {
                                    Label("_favorite", systemImage: folder.favorite ? "star.slash.fill" : "star.fill")
                                }
                                .tint(.yellow)
                                .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                                Button {
                                    editFolder()
                                }
                                label: {
                                    Label("_edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                                .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteFolder()
                                }
                                label: {
                                    Label("_delete", systemImage: "trash")
                                }
                                .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                                Button {
                                    moveFolder()
                                }
                                label: {
                                    Label("_move", systemImage: "folder")
                                }
                                .tint(.purple)
                                .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                            }
                    }
                }
                .contextMenu {
                    Button {
                        editFolder()
                    }
                    label: {
                        Label("_edit", systemImage: "pencil")
                    }
                    .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                    Button {
                        toggleFavorite()
                    }
                    label: {
                        Label("_favorite", systemImage: folder.favorite ? "star.fill" : "star")
                    }
                    .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                    Button {
                        moveFolder()
                    }
                    label: {
                        Label("_move", systemImage: "folder")
                    }
                    .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                    Divider()
                    if #available(iOS 15.0, *) {
                        Button(role: .destructive) {
                            deleteFolder()
                        }
                        label: {
                            Label("_delete", systemImage: "trash")
                        }
                        .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                    }
                    else {
                        Button {
                            deleteFolder()
                        }
                        label: {
                            Label("_delete", systemImage: "trash")
                        }
                        .disabled(folder.state?.isProcessing ?? false || folder.state == .decryptionFailed)
                    }
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
                Spacer()
                HStack {
                    if let state = folder.state {
                        if state.isError {
                            errorButton(state: state)
                        }
                        else if state.isProcessing {
                            ProgressView()
                            Spacer()
                        }
                    }
                    if folder.favorite {
                        favoriteImage()
                    }
                }
                .fixedSize()
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
            .buttonStyle(.borderless)
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
    
    private struct PasswordRow: View {
        
        @ObservedObject var entriesController: EntriesController
        @ObservedObject var folderController: FolderController
        @ObservedObject var password: Password
        let editPassword: () -> Void
        let movePassword: () -> Void
        let tagPassword: () -> Void
        let deletePassword: () -> Void
        
        @EnvironmentObject private var autoFillController: AutoFillController
        @EnvironmentObject private var sessionController: SessionController
        
        @State private var favicon: UIImage?
        @State private var showPasswordDetailView = false
        @State private var showErrorAlert = false
        
        // MARK: Views
        
        var body: some View {
            wrapperStack()
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    toggleFavorite()
                                }
                                label: {
                                    Label("_favorite", systemImage: password.favorite ? "star.slash.fill" : "star.fill")
                                }
                                .tint(.yellow)
                                .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                                Button {
                                    tagPassword()
                                }
                                label: {
                                    Label(password.tags.isEmpty ? "_addTags" : "_editTags", systemImage: "tag")
                                }
                                .tint(.orange)
                                .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                                if password.editable {
                                    Button {
                                        editPassword()
                                    }
                                    label: {
                                        Label("_edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                    .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deletePassword()
                                }
                                label: {
                                    Label("_delete", systemImage: "trash")
                                }
                                .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                                Button {
                                    movePassword()
                                }
                                label: {
                                    Label("_move", systemImage: "folder")
                                }
                                .tint(.purple)
                                .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                            }
                    }
                }
                .contextMenu {
                    Section {
                        if let url = URL(string: password.url) {
                            Link(destination: url) {
                                Label("_openUrl", systemImage: "safari")
                            }
                        }
                        if !password.username.isEmpty {
                            Button {
                                UIPasteboard.general.string = password.username
                            }
                            label: {
                                Label("_copyUsername", systemImage: "doc.on.doc")
                            }
                        }
                        Button {
                            UIPasteboard.general.privateString = password.password
                        }
                        label: {
                            Label("_copyPassword", systemImage: "doc.on.doc")
                        }
                        if let otp = password.otp {
                            Button {
                                UIPasteboard.general.privateString = otp.current
                            }
                            label: {
                                Label("_copyOtp", systemImage: "doc.on.doc")
                            }
                        }
                    }
                    Section {
                        if password.editable {
                            Button {
                                editPassword()
                            }
                            label: {
                                Label("_edit", systemImage: "pencil")
                            }
                            .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                        }
                        Button {
                            toggleFavorite()
                        }
                        label: {
                            Label("_favorite", systemImage: password.favorite ? "star.fill" : "star")
                        }
                        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                        Button {
                            tagPassword()
                        }
                        label: {
                            Label(password.tags.isEmpty ? "_addTags" : "_editTags", systemImage: "tag")
                        }
                        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                        Button {
                            movePassword()
                        }
                        label: {
                            Label("_move", systemImage: "folder")
                        }
                        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                    }
                    if #available(iOS 15.0, *) {
                        Button(role: .destructive) {
                            deletePassword()
                        }
                        label: {
                            Label("_delete", systemImage: "trash")
                        }
                        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                    }
                    else {
                        Button {
                            deletePassword()
                        }
                        label: {
                            Label("_delete", systemImage: "trash")
                        }
                        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                    }
                }
        }
        
        private func wrapperStack() -> some View {
            HStack {
                if let complete = autoFillController.complete {
                    Button {
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
                    label: {
                        mainStack()
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    Spacer()
                    ZStack {
                        NavigationLink(destination: PasswordDetailPage(entriesController: entriesController, password: password, updatePassword: {
                            entriesController.update(password: password)
                        }, deletePassword: {
                            entriesController.delete(password: password)
                        }), isActive: $showPasswordDetailView) {}
                        .isDetailLink(true)
                        .frame(width: 0, height: 0)
                        .hidden()
                        Button {
                            showPasswordDetailView = true
                        }
                        label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderless)
                    }
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
                Spacer()
                HStack {
                    if let state = password.state {
                        if state.isError {
                            errorButton(state: state)
                        }
                        else if state.isProcessing {
                            ProgressView()
                            Spacer()
                        }
                    }
                    if entriesController.filterBy == .otps || autoFillController.mode == .extension,
                       let otp = password.otp {
                        OTPDisplay(otp: otp) {
                            otp in
                            password.updated = Date()
                            password.otp = otp
                            entriesController.update(password: password)
                        }
                        content: {
                            current, accessoryView in
                            Text((current ?? "").segmented)
                                .foregroundColor(.primary)
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            accessoryView
                        }
                        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
                    }
                    else {
                        if let tags = entriesController.tags,
                           let validTags = EntriesController.tags(for: password.tags, in: tags).valid,
                           !validTags.isEmpty {
                            HStack(spacing: -6) {
                                ForEach(Array(validTags.sortedByLabel().prefix(10).enumerated()), id: \.element.id) {
                                    index, tag in
                                    Circle()
                                        .stroke(Color(UIColor.systemBackground), lineWidth: 2)
                                        .background(
                                            Circle()
                                                .strokeBorder(Color(white: 0.5, opacity: 0.35), lineWidth: 1)
                                                .background(
                                                    Circle()
                                                        .fill(Color(hex: tag.color) ?? .primary)
                                                )
                                                .frame(width: 14, height: 14)
                                        )
                                        .zIndex(Double(validTags.count - index))
                                        .frame(width: 16, height: 16)
                                }
                            }
                        }
                        if password.favorite {
                            favoriteImage()
                        }
                        if folderController.defaultSorting ?? entriesController.sortBy == .status {
                            statusImage()
                        }
                    }
                }
                .fixedSize()
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
        
        private func favoriteImage() -> some View {
            Image(systemName: "star.fill")
                .foregroundColor(.gray)
        }
        
        @ViewBuilder private func statusImage() -> some View {
            switch password.statusCode {
            case .good:
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
            case .outdated, .duplicate:
                Image(systemName: "exclamationmark.shield.fill")
                    .foregroundColor(.yellow)
            case .breached:
                Image(systemName: "xmark.shield.fill")
                    .foregroundColor(.red)
            case .unknown:
                ZStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.gray)
                    Image(systemName: "questionmark")
                        .font(.body.bold())
                        .foregroundColor(Color(.systemBackground))
                        .scaleEffect(0.5)
                }
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


extension EntriesPage {
    
    private struct TagRow: View {
        
        @ObservedObject var entriesController: EntriesController
        @ObservedObject var tag: Tag
        let editTag: () -> Void
        let deleteTag: () -> Void
        
        @State private var showErrorAlert = false
        
        // MARK: Views
        
        var body: some View {
            entriesPageLink()
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    toggleFavorite()
                                }
                                label: {
                                    Label("_favorite", systemImage: tag.favorite ? "star.slash.fill" : "star.fill")
                                }
                                .tint(.yellow)
                                .disabled(tag.state?.isProcessing ?? false || tag.state == .decryptionFailed)
                                Button {
                                    editTag()
                                }
                                label: {
                                    Label("_edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                                .disabled(tag.state?.isProcessing ?? false || tag.state == .decryptionFailed)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteTag()
                                }
                                label: {
                                    Label("_delete", systemImage: "trash")
                                }
                                .disabled(tag.state?.isProcessing ?? false || tag.state == .decryptionFailed)
                            }
                    }
                }
                .contextMenu {
                    Button {
                        editTag()
                    }
                    label: {
                        Label("_edit", systemImage: "pencil")
                    }
                    .disabled(tag.state?.isProcessing ?? false || tag.state == .decryptionFailed)
                    Button {
                        toggleFavorite()
                    }
                    label: {
                        Label("_favorite", systemImage: tag.favorite ? "star.fill" : "star")
                    }
                    .disabled(tag.state?.isProcessing ?? false || tag.state == .decryptionFailed)
                    Divider()
                    if #available(iOS 15.0, *) {
                        Button(role: .destructive) {
                            deleteTag()
                        }
                        label: {
                            Label("_delete", systemImage: "trash")
                        }
                        .disabled(tag.state?.isProcessing ?? false || tag.state == .decryptionFailed)
                    }
                    else {
                        Button {
                            deleteTag()
                        }
                        label: {
                            Label("_delete", systemImage: "trash")
                        }
                        .disabled(tag.state?.isProcessing ?? false || tag.state == .decryptionFailed)
                    }
                }
        }
        
        private func entriesPageLink() -> some View {
            NavigationLink(destination: EntriesPage(entriesController: entriesController, tag: tag)) {
                mainStack()
            }
            .isDetailLink(false)
        }
        
        private func mainStack() -> some View {
            HStack {
                tagImage()
                labelText()
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack {
                    if let state = tag.state {
                        if state.isError {
                            errorButton(state: state)
                        }
                        else if state.isProcessing {
                            ProgressView()
                            Spacer()
                        }
                    }
                    if tag.favorite {
                        favoriteImage()
                    }
                }
                .fixedSize()
            }
        }
        
        private func tagImage() -> some View {
            ZStack {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "tag.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Circle() /// Use a circle to hide the dot of the tag symbol because it is off center compared to the unfilled variant
                        .frame(width: 20, height: 20)
                        .padding(2)
                }
                .foregroundColor(Color(UIColor.secondarySystemBackground))
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "tag.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Circle()
                        .frame(width: 20, height: 20)
                        .padding(2)
                }
                .foregroundColor(Color(hex: tag.color) ?? .primary)
                .compositingGroup()
                .opacity(0.3)
                Image(systemName: "tag")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color(hex: tag.color) ?? .primary)
            }
            .frame(width: 40, height: 40)
        }
        
        private func labelText() -> some View {
            VStack(alignment: .leading) {
                Text(tag.label)
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
            .buttonStyle(.borderless)
            .alert(isPresented: $showErrorAlert) {
                switch state {
                case .creationFailed:
                    return Alert(title: Text("_error"), message: Text("_createTagErrorMessage"))
                case .updateFailed:
                    return Alert(title: Text("_error"), message: Text("_editTagErrorMessage"))
                case .deletionFailed:
                    return Alert(title: Text("_error"), message: Text("_deleteTagErrorMessage"))
                case .decryptionFailed:
                    return Alert(title: Text("_error"), message: Text("_decryptTagErrorMessage"))
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
            tag.edited = Date()
            tag.updated = Date()
            tag.favorite.toggle()
            entriesController.update(tag: tag)
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
