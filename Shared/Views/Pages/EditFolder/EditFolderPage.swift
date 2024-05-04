import SwiftUI


struct EditFolderPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<EditFolderViewModel>
    
    @FocusState private var focusedField: EditFolderViewModel.FocusField?
    
    var body: some View {
        listView()
            .navigationTitle("_folder")
            .interactiveDismissDisabled(viewModel[\.hasChanges])
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton()
                }
            }
            .sync($viewModel[\.focusedField], to: _focusedField)
            .dismiss(on: viewModel[\.shouldDismiss])
    }
    
    private func listView() -> some View {
        List {
            folderLabelField()
            favoriteButton()
            moveSection()
            if !viewModel[\.isCreating] {
                deleteButton()
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    viewModel(.dismissKeyboard)
                } label: {
                    Text("_dismiss")
                        .bold()
                }
            }
        }
    }
    
    private func folderLabelField() -> some View {
        Section(header: Text("_name")) {
            TextField("-", text: $viewModel[\.folderLabel])
                .focused($focusedField, equals: .folderLabel)
                .submitLabel(.done)
                .onSubmit {
                    if viewModel[\.editIsValid] {
                        viewModel(.applyToFolder)
                    }
                }
        }
    }
    
    private func favoriteButton() -> some View {
        Section {
            Button {
                viewModel(.toggleFavorite)
            } label: {
                Label("_favorite", systemImage: viewModel[\.folderFavorite] ? "star.fill" : "star")
            }
        }
    }
    
    private func moveSection() -> some View {
        Section(header: Text("_folder")) {
            Button {
                viewModel(.showParentSelection)
            } label: {
                HStack {
                    Label(viewModel[\.parentLabel], systemImage: "folder")
                    Spacer()
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }
                    .fixedSize()
                    .tint(.primary)
                }
            }
            .sheet(isPresented: $viewModel[\.showSelectFolderView]) {
                SelectFolderNavigation(entry: .folder(viewModel[\.folder]), temporaryEntry: .folder(label: viewModel[\.folderLabel], parent: viewModel[\.folderParent]), selectFolder: { parent in
                    viewModel(.selectParent(parent))
                })
            }
        }
    }
    
    private func deleteButton() -> some View {
        Button(role: .destructive) {
            viewModel(.deleteFolder)
        } label: {
            HStack {
                Spacer()
                Text("_deleteFolder")
                Spacer()
            }
        }
        .actionSheet(isPresented: $viewModel[\.showDeleteAlert]) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deleteFolder")) {
                viewModel(.confirmDelete)
            }])
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            viewModel(.cancel)
        }
        .actionSheet(isPresented: $viewModel[\.showCancelAlert]) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_discardChanges")) {
                viewModel(.discardChanges)
            }])
        }
    }
    
    private func confirmButton() -> some View {
        Button(viewModel[\.isCreating] ? "_create" : "_done") {
            viewModel(.applyToFolder)
        }
        .enabled(viewModel[\.editIsValid])
    }
    
}
