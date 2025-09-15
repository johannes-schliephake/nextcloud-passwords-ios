import SwiftUI


struct SelectTagsPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<SelectTagsViewModel>
    
    @FocusState private var focusedField: SelectTagsViewModel.FocusField?
    
    var body: some View {
        mainStack()
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("_editTags")
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
    
    private func mainStack() -> some View {
        listView()
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .safeAreaPadding(.bottom, 20)
                        .toolbar {
                            ToolbarItem(placement: .bottomBar) {
                                row()
                            }
                        }
                } else {
                    VStack(spacing: 0) {
                        row()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .padding(.top, 1)
                            .padding([.horizontal, .bottom])
                        Divider()
                            .padding(.leading)
                        view
                    }
                }
            }
    }
    
    private func listView() -> some View {
        List {
            Group {
                VStack {
                    addTagBadge()
                        .padding(.top, 8)
                }
                ForEach(viewModel[\.selectableTags], id: \.tag) {
                    tag, isSelected in
                    toggleTagBadge(tag: tag, isSelected: isSelected)
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.listRow)
        }
        .listStyle(.plain)
        .apply { view in
            if #available(iOS 26, *),
               UIDevice.current.userInterfaceIdiom == .pad {
                view
                    .scrollContentBackground(.visible)
            }
        }
    }
    
    private func row() -> some View {
        Group {
            switch viewModel[\.temporaryEntry] {
            case .password(let label, let username, let url, _):
                PasswordRow(label: label, username: username, url: url)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal)
    }
    
    private func addTagBadge() -> some View {
        HStack(spacing: 10) {
            Circle()
                .strokeBorder(Color(.placeholderText), lineWidth: 1.5)
                .frame(width: 15.8, height: 15.8)
            TextField("_createTag", text: $viewModel[\.tagLabel])
                .focused($focusedField, equals: .addTagLabel)
                .submitLabel(.done)
                .onSubmit {
                    if viewModel [\.tagLabelIsValid] {
                        viewModel(.addTag)
                    }
                }
        }
        .apply { view in
            if #available(iOS 26, *) {
                view
                    .padding(.horizontal, 10)
                    .padding(.vertical, 9)
            } else {
                view
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
            }
        }
        .background {
            if #available(iOS 26, *) {
                Capsule()
                    .strokeBorder(Color(.placeholderText), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            } else {
                RoundedRectangle(cornerRadius: 5.7)
                    .strokeBorder(Color(.placeholderText), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            }
        }
    }
    
    private func toggleTagBadge(tag: Tag, isSelected: Bool) -> some View {
        Button {
            viewModel(.toggleTag(tag))
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: tag.color) ?? .primary)
                    .frame(width: 15.8, height: 15.8)
                Text(tag.label)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .foregroundColor(Color(hex: tag.color) ?? .primary)
                    .apply { view in
                        if #available(iOS 26, *) {
                            view
                                .symbolEffect(.drawOn, isActive: !isSelected)
                        } else {
                            view
                                .opacity(isSelected ? 1 : 0)
                        }
                    }
            }
            .apply { view in
                if #available(iOS 26, *) {
                    view
                        .padding(10)
                } else {
                    view
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
            }
            .background {
                if #available(iOS 26, *) {
                    Capsule()
                        .fill(isSelected ? Color(.systemBackground) : Color(.secondarySystemBackground))
                        .fill((Color(hex: tag.color) ?? .primary).opacity(isSelected ? 0.3 : 0))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5.7)
                            .fill(Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .secondarySystemBackground }))
                        RoundedRectangle(cornerRadius: 5.7)
                            .fill((Color(hex: tag.color) ?? .primary).opacity(0.3))
                            .opacity(isSelected ? 1 : 0)
                    }
                }
            }
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder private func cancelButton() -> some View {
        if #available(iOS 26, *) {
            Button(role: .cancel) {
                viewModel(.cancel)
            }
        } else {
            Button("_cancel", role: .cancel) {
                viewModel(.cancel)
            }
        }
    }
    
    private func confirmButton() -> some View {
        Group {
            if #available(iOS 26, *) {
                Button(role: .confirm) {
                    viewModel(.selectTags)
                }
            } else {
                Button("_done") {
                    viewModel(.selectTags)
                }
            }
        }
        .enabled(viewModel[\.hasChanges])
    }
    
}


extension SelectTagsPage {
    
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
                    .apply { view in
                        if #available(iOS 26, *) {
                            view
                                .cornerRadius(6)
                        } else {
                            view
                                .cornerRadius(3.75)
                        }
                    }
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
