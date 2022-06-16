import SwiftUI


struct SelectTagsPage: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var selectTagsController: SelectTagsController
    @FocusState private var focusedField: FocusField?
    
    init(entriesController: EntriesController, temporaryEntry: SelectTagsController.TemporaryEntry, selectTags: @escaping ([Tag], [String]) -> Void) {
        _selectTagsController = StateObject(wrappedValue: SelectTagsController(entriesController: entriesController, temporaryEntry: temporaryEntry, selectTags: selectTags))
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
                addTagBadge()
            }
            .listRowSeparator(.hidden)
            ForEach(selectTagsController.tags) {
                tag in
                toggleTagBadge(tag: tag)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
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
    
    private func addTagBadge() -> some View {
        HStack(spacing: 10) {
            Circle()
                .strokeBorder(Color(.placeholderText), lineWidth: 1.5)
                .frame(width: 15.8, height: 15.8)
            TextField("_createTag", text: $selectTagsController.tagLabel, onCommit: {
                selectTagsController.addTag()
                focusedField = .addTagLabel
            })
            .focused($focusedField, equals: .addTagLabel)
            .submitLabel(.done)
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
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            dismiss()
        }
    }
    
    private func confirmButton() -> some View {
        Button("_done") {
            applyAndDismiss()
        }
        .disabled(!selectTagsController.hasChanges)
    }
    
    // MARK: Functions
    
    private func applyAndDismiss() {
        guard selectTagsController.hasChanges,
              selectTagsController.selection.allSatisfy({ $0.state?.isProcessing != true }) else {
            return
        }
        selectTagsController.selectTags(selectTagsController.selection, selectTagsController.invalidTags)
        dismiss()
    }
    
}


extension SelectTagsPage {
    
    private enum FocusField: Hashable {
        case addTagLabel
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
                SelectTagsPage(entriesController: EntriesController.mock, temporaryEntry: .password(label: Password.mock.label, username: Password.mock.username, url: Password.mock.url, tags: Password.mock.tags), selectTags: { _, _  in })
            }
            .showColumns(false)
        }
    }
    
}
