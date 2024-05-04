import SwiftUI


struct EditTagPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<EditTagViewModel>
    
    @FocusState private var focusedField: EditTagViewModel.FocusField?
    
    var body: some View {
        listView()
            .navigationTitle("_tag")
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
            tagLabelField()
            colorSelector()
            favoriteButton()
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
    
    private func tagLabelField() -> some View {
        Section(header: Text("_name")) {
            TextField("-", text: $viewModel[\.tagLabel])
                .focused($focusedField, equals: .tagLabel)
                .submitLabel(.done)
                .onSubmit {
                    if viewModel[\.editIsValid] {
                        viewModel(.applyToTag)
                    }
                }
        }
    }
    
    private func colorSelector() -> some View {
        Section(header: Text("_color")) {
            HStack {
                Label("_selectColor", systemImage: "paintpalette")
                    .foregroundColor(.accentColor)
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color(white: 0.5, opacity: 0.35), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(viewModel[\.tagColor])
                    )
                    .frame(width: 20, height: 20)
            }
            .allowsHitTesting(false)
            .background(
                ZStack {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        /// `scaleEffect` and `ColorPicker` can't be combined on iPad to enlarge tap area because the color picker view isn't a sheet
                        LazyHStack(spacing: 0) {
                            ForEach(0..<50) { _ in
                                ColorPicker("", selection: $viewModel[\.tagColor], supportsOpacity: false)
                                    .labelsHidden()
                            }
                        }
                    } else {
                        ColorPicker("", selection: $viewModel[\.tagColor], supportsOpacity: false)
                            .labelsHidden()
                            .scaleEffect(100)
                    }
                    Rectangle()
                        .foregroundColor(Color(.secondarySystemGroupedBackground))
                        .scaleEffect(10)
                        .allowsHitTesting(false)
                }
            )
        }
    }
    
    private func favoriteButton() -> some View {
        Section {
            Button {
                viewModel(.toggleFavorite)
            } label: {
                Label("_favorite", systemImage: viewModel[\.tagFavorite] ? "star.fill" : "star")
            }
        }
    }
    
    private func deleteButton() -> some View {
        Button(role: .destructive) {
            viewModel(.deleteTag)
        } label: {
            HStack {
                Spacer()
                Text("_deleteTag")
                Spacer()
            }
        }
        .actionSheet(isPresented: $viewModel[\.showDeleteAlert]) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deleteTag")) {
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
            viewModel(.applyToTag)
        }
        .enabled(viewModel[\.editIsValid])
    }
    
}
