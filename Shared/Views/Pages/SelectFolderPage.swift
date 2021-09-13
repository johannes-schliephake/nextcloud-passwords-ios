import SwiftUI


struct SelectFolderPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var sessionController: SessionController
    
    @StateObject private var selectFolderController: SelectFolderController
    
    init(entry: Entry, temporaryEntry: SelectFolderController.TemporaryEntry, folders: [Folder], selectFolder: @escaping (Folder) -> Void) {
        _selectFolderController = StateObject(wrappedValue: SelectFolderController(entry: entry, temporaryEntry: temporaryEntry, folders: folders, selectFolder: selectFolder))
    }
    
    // MARK: Views
    
    var body: some View {
        mainStack()
            .navigationTitle("_move")
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
            }
            .listStyle(PlainListStyle())
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
    
    private func confirmButton() -> some View {
        Button("_done") {
            applyAndDismiss()
        }
        .disabled(selectFolderController.temporaryEntry.parent == selectFolderController.selection.id)
    }
    
    // MARK: Functions
    
    private func applyAndDismiss() {
        guard !(selectFolderController.temporaryEntry.parent == selectFolderController.selection.id) else {
            return
        }
        selectFolderController.selectFolder(selectFolderController.selection)
        presentationMode.wrappedValue.dismiss()
    }
    
}


extension SelectFolderPage {
    
    struct FolderGroup: View {
        
        private let folder: Folder
        private let folders: [Folder]
        @Binding private var selection: Folder
        @State private var isExpanded: Bool
        
        init(folder: Folder, folders: [Folder], selection: Binding<Folder>, isExpanded: Bool) {
            self.folder = folder
            self.folders = folders
            _selection = selection
            _isExpanded = State(wrappedValue: isExpanded)
        }
        
        var body: some View {
            Group {
                if !folders.contains { $0.parent == folder.id } {
                    FolderRow(label: folder.label)
                }
                else {
                    DisclosureGroup(isExpanded: $isExpanded) {
                        ForEach(folders.filter { !$0.id.isEmpty && $0.parent == folder.id }) {
                            folder in
                            FolderGroup(folder: folder, folders: folders, selection: $selection, isExpanded: selection !== folder && selection.isDescendentOf(folder: folder, in: folders))
                        }
                    }
                    label: {
                        FolderRow(label: folder.label)
                            .id(folder.id)
                    }
                }
            }
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
                    Text(label)
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


struct MovePasswordPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                SelectFolderPage(entry: .folder(Folder.mocks.first!), temporaryEntry: .folder(label: Folder.mocks.first!.label, parent: Folder.mocks.first!.parent), folders: Folder.mocks, selectFolder: { _ in })
            }
            .showColumns(false)
        }
    }
    
}
