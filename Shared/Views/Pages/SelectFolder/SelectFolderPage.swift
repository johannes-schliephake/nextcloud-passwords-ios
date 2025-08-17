import SwiftUI


struct SelectFolderPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<SelectFolderViewModel>
    
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
            .dismiss(on: viewModel[\.shouldDismiss])
    }
    
    private func mainStack() -> some View {
        VStack(spacing: 0) {
            VStack {
                Group {
                    switch viewModel[\.temporaryEntry] {
                    case let .folder(label, _):
                        FolderRow(label: label)
                    case let .password(label, username, url, _):
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
        ScrollViewReader { scrollViewProxy in
            List {
                TreePicker(viewModel[\.tree], selection: $viewModel[\.selection]) { folder in
                    FolderRow(label: folder.label)
                        .id(folder.id)
                }
                .listSectionSeparator(.hidden, edges: .top)
                .listRowInsets(.listRow)
            }
            .listStyle(.plain)
            .onAppear {
                withAnimation {
                    guard let selection = viewModel[\.selection] else {
                        return
                    }
                    scrollViewProxy.scrollTo(selection.id, anchor: .center)
                }
            }
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            viewModel(.cancel)
        }
    }
    
    private func addFolderButton() -> some View {
        Button {
            viewModel(.showFolderCreation)
        } label: {
            Image(systemName: "folder.badge.plus")
        }
        .sheet(item: $viewModel[\.sheetItem]) { item in
            switch item {
            case let .edit(folder):
                EditFolderNavigation(folder: folder, didEdit: { folder in
                    viewModel(.setSelection(folder))
                })
            }
        }
    }
    
    private func confirmButton() -> some View {
        Button("_done") {
            viewModel(.selectFolder)
        }
        .enabled(viewModel[\.hasChanges])
        .enabled(viewModel[\.selectionIsValid])
    }
    
}


extension SelectFolderPage {
    
    private struct FolderRow: View {
        
        let label: String
        
        var body: some View {
            HStack {
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.accentColor)
                Spacer(minLength: 12)
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
    
    private struct PasswordRow: View {
        
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
                Spacer(minLength: 12)
                VStack(alignment: .leading) {
                    Text(!label.isEmpty ? label : "-")
                        .lineLimit(1)
                    Text(!username.isEmpty ? username : "-")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .apply { view in
                            if #available(iOS 17, *) {
                                view
                                    .typesettingLanguage(.init(languageCode: .unavailable))
                            }
                        }
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
