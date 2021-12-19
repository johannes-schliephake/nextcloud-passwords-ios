import SwiftUI


struct SelectTagsPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var sessionController: SessionController
    
    @StateObject private var selectTagsController: SelectTagsController
    @available(iOS 15, *) @FocusState private var focusedField: FocusField?
    
    init(temporaryEntry: SelectTagsController.TemporaryEntry, tags: [Tag], addTag: @escaping (Tag) -> Void, selectTags: @escaping ([Tag]) -> Void) {
        _selectTagsController = StateObject(wrappedValue: SelectTagsController(temporaryEntry: temporaryEntry, tags: tags, addTag: addTag, selectTags: selectTags))
    }
    
    // MARK: Views
    
    var body: some View {
        mainStack()
            .navigationTitle("_editTags")
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
                    switch selectTagsController.temporaryEntry {
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
        List {
            VStack {
                Spacer()
                createTagBadge()
            }
            .apply {
                view in
                if #available(iOS 15, *) {
                    view
                        .listRowSeparator(.hidden)
                }
            }
            ForEach(selectTagsController.tags.sortedByLabel()) {
                tag in
                toggleTagBadge(tag: tag)
            }
            .apply {
                view in
                if #available(iOS 15, *) {
                    view
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
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
            }
        }
    }
    
    private func createTagBadge() -> some View {
        HStack(spacing: 10) {
            Circle()
                .strokeBorder(Color(.placeholderText), lineWidth: 1.5)
                .frame(width: 15.8, height: 15.8)
            TextField("_createTag" as LocalizedStringKey, text: $selectTagsController.createTagLabel, onCommit: {
                selectTagsController.createTag()
                if #available(iOS 15, *) {
                    focusedField = .createTagLabel
                }
            })
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .focused($focusedField, equals: .createTagLabel)
                            .submitLabel(.done)
                    }
                }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 5.7)
                .strokeBorder(Color(.placeholderText), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
        )
    }
    
    @ViewBuilder private func toggleTagBadge(tag: Tag) -> some View {
        let selected = selectTagsController.selection.contains { $0.id == tag.id }
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
                .opacity(selected ? 1 : 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 5.7)
                    .fill(Color(UIColor { $0.userInterfaceStyle == .dark ? .black : .secondarySystemBackground }))
                RoundedRectangle(cornerRadius: 5.7)
                    .fill((Color(hex: tag.color) ?? .primary).opacity(0.3))
                    .opacity(selected ? 1 : 0)
            }
        )
        .animation(.easeInOut(duration: 0.2))
        .onTapGesture {
            selectTagsController.toggleTag(tag)
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
        .disabled(selectTagsController.temporaryEntry.tags.sorted() == selectTagsController.selection.map { $0.id }.sorted())
    }
    
    // MARK: Functions
    
    private func applyAndDismiss() {
        guard !(selectTagsController.temporaryEntry.tags.sorted() == selectTagsController.selection.map { $0.id }.sorted()) else {
            return
        }
        selectTagsController.selectTags(selectTagsController.selection)
        presentationMode.wrappedValue.dismiss()
    }
    
}


extension SelectTagsPage {
    
    enum FocusField: Hashable {
        case createTagLabel
    }
    
}


extension SelectTagsPage {
    
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


struct SelectTagsPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                SelectTagsPage(temporaryEntry: .password(label: Password.mock.label, username: Password.mock.username, url: Password.mock.url, tags: Password.mock.tags), tags: Tag.mocks, addTag: { _ in }, selectTags: { _ in })
            }
            .showColumns(false)
        }
    }
    
}
