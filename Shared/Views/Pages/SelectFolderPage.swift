import SwiftUI


struct SelectFolderPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var settingsController: SettingsController
    @EnvironmentObject private var tipController: TipController
    
    @StateObject private var selectFolderController: SelectFolderController
    @State private var sheetItem: SheetItem?
    
    init(entriesController: EntriesController, entry: Entry, temporaryEntry: SelectFolderController.TemporaryEntry, selectFolder: @escaping (Folder) -> Void) {
        _selectFolderController = StateObject(wrappedValue: SelectFolderController(entriesController: entriesController, entry: entry, temporaryEntry: temporaryEntry, selectFolder: selectFolder))
    }
    
    // MARK: Views
    
    var body: some View {
        mainStack()
            .navigationTitle("_move")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addFolderButton()
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
    }
    
    private func mainStack() -> some View {
        VStack(spacing: 0) {
            VStack {
                Group {
                    switch selectFolderController.temporaryEntry {
                    case .folder(let label, _):
                        FolderRow(label: label)
                    case .password(let label, let username, let url, _):
                        PasswordRow(label: label, username: username, url: url)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.top, 1)
            .padding([.horizontal, .bottom])
            Divider()
                .padding(.leading)
            listView()
        }
    }
    
    private func listView() -> some View {
        ScrollViewReader {
            scrollViewProxy in
            List {
                FolderGroup(folder: selectFolderController.baseFolder, folders: selectFolderController.folders, selection: $selectFolderController.selection, isExpanded: true)
                    .apply {
                        view in
                        if #available(iOS 15, *) {
                            view
                                .listSectionSeparator(.hidden, edges: .top)
                        }
                    }
            }
            .listStyle(.plain)
            .onAppear {
                withAnimation {
                    scrollViewProxy.scrollTo(selectFolderController.selection.id, anchor: .center)
                }
            }
        }
    }
    
    @ViewBuilder private func cancelButton() -> some View {
        if #available(iOS 15.0, *) {
            Button("_cancel", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        else {
            Button("_cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func addFolderButton() -> some View {
        Button {
            sheetItem = .edit(folder: Folder(parent: selectFolderController.selection.id, client: Configuration.clientName))
        }
        label: {
            Image(systemName: "folder.badge.plus")
        }
        .sheet(item: $sheetItem) {
            item in
            switch item {
            case .edit(let folder):
                EditFolderNavigation(entriesController: selectFolderController.entriesController, folder: folder, didAdd: {
                    folder in
                    selectFolderController.selection = folder
                })
                .environmentObject(autoFillController)
                .environmentObject(biometricAuthenticationController)
                .environmentObject(sessionController)
                .environmentObject(settingsController)
                .environmentObject(tipController)
            }
        }
    }
    
    private func confirmButton() -> some View {
        Button("_done") {
            applyAndDismiss()
        }
        .disabled(!selectFolderController.hasChanges)
    }
    
    // MARK: Functions
    
    private func applyAndDismiss() {
        guard selectFolderController.hasChanges,
              selectFolderController.selection.state?.isProcessing != true else {
            return
        }
        selectFolderController.selectFolder(selectFolderController.selection)
        presentationMode.wrappedValue.dismiss()
    }
    
}


extension SelectFolderPage {
    
    enum SheetItem: Identifiable {
        
        case edit(folder: Folder)
        
        var id: String {
            switch self {
            case .edit(let folder):
                return folder.id
            }
        }
        
    }
    
}


extension SelectFolderPage {
    
    struct FolderGroup: View {
        
        let folder: Folder
        let folders: [Folder]
        @Binding var selection: Folder
        @State var isExpanded: Bool
        
        var body: some View {
            Group {
                let subfolders = folders.filter { !$0.id.isEmpty && $0.parent == folder.id }
                if subfolders.isEmpty {
                    FolderRow(label: folder.label)
                }
                else {
                    DisclosureGroup(isExpanded: $isExpanded) {
                        ForEach(subfolders) {
                            folder in
                            FolderGroup(folder: folder, folders: folders, selection: $selection, isExpanded: selection !== folder && selection.isDescendentOf(folder: folder, in: folders))
                        }
                    }
                    label: {
                        FolderRow(label: folder.label)
                    }
                }
            }
            .id(folder.id)
            .contentShape(Rectangle())
            .listRowBackground(selection === folder ? Color(white: 0.5, opacity: 0.35) : Color.clear)
            .onTapGesture {
                selection = folder
            }
        }
        
    }
    
}


extension SelectFolderPage {
    
    struct FolderRow: View {
        
        let label: String
        
        var body: some View {
            HStack {
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.accentColor)
                VStack(alignment: .leading) {
                    Text(!label.isEmpty ? label : "-")
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        
    }
    
}


extension SelectFolderPage {
    
    struct PasswordRow: View {
        
        let label: String
        let username: String
        let url: String
        
        @EnvironmentObject private var sessionController: SessionController
        
        @State private var favicon: UIImage?
        
        var body: some View {
            HStack {
                Image(uiImage: favicon ?? UIImage())
                    .resizable()
                    .frame(width: 40, height: 40)
                    .background(favicon == nil ? Color(white: 0.5, opacity: 0.2) : nil)
                    .cornerRadius(3.75)
                    .onAppear {
                        requestFavicon()
                    }
                VStack(alignment: .leading) {
                    Text(!label.isEmpty ? label : "-")
                        .lineLimit(1)
                    Text(!username.isEmpty ? username : "-")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        
        // MARK: Functions
        
        private func requestFavicon() {
            guard let domain = URL(string: url)?.host ?? URL(string: "https://\(url)")?.host,
                  let session = sessionController.session else {
                return
            }
            FaviconServiceRequest(session: session, domain: domain).send { favicon = $0 }
        }
        
    }
    
}


struct SelectFolderPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                SelectFolderPage(entriesController: EntriesController.mock, entry: .folder(Folder.mocks.first!), temporaryEntry: .folder(label: Folder.mocks.first!.label, parent: Folder.mocks.first!.parent), selectFolder: { _ in })
            }
            .showColumns(false)
        }
    }
    
}
