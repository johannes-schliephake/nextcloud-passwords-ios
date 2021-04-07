import SwiftUI


struct PasswordDetailPage: View {
    
    @ObservedObject var password: Password
    let updatePassword: () -> Void
    let deletePassword: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var tipController: TipController
    
    @State private var favicon: UIImage?
    @State private var hidePassword = true
    @State private var showDeleteAlert = false
    @State private var showEditPasswordView = false
    @State private var showErrorAlert = false
    
    // MARK: Views
    
    var body: some View {
        mainStack()
            .navigationTitle(password.label)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if password.editable {
                        trailingToolbarView()
                    }
                }
            }
            .onChange(of: sessionController.challengeAvailable) {
                challengeAvailable in
                if challengeAvailable {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
    
    private func mainStack() -> some View {
        GeometryReader {
            geometry in
            VStack(spacing: 0) {
                listView()
                if let complete = autoFillController.complete {
                    Divider()
                    selectView(geometry: geometry, complete: complete)
                }
                EmptyView()
                    .sheet(isPresented: $showEditPasswordView, content: {
                        EditPasswordNavigation(password: password, addPassword: {}, updatePassword: updatePassword)
                            .environmentObject(autoFillController)
                            .environmentObject(biometricAuthenticationController)
                            .environmentObject(sessionController)
                            .environmentObject(tipController)
                    })
            }
            .edgesIgnoringSafeArea(autoFillController.complete != nil ? .bottom : [])
        }
    }
    
    private func listView() -> some View {
        List {
            HStack {
                Spacer()
                passwordStatusMenu()
                Spacer()
                faviconImage()
                Spacer()
                favoriteButton()
                Spacer()
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            serviceSection()
            accountSection()
            notesSection()
            metadataSection()
            deleteButton()
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func passwordStatusMenu() -> some View {
        Menu {
            Section {
                switch password.statusCode {
                case .good:
                    Text("_passwordStatusGoodMessage1")
                    Text("_passwordStatusGoodMessage2")
                    Text("_passwordStatusGoodMessage3")
                case .outdated:
                    Text("_passwordStatusOutdatedMessage")
                case .duplicate:
                    Text("_passwordStatusDuplicateMessage")
                case .breached:
                    Text("_passwordStatusBreachedMessage1")
                    Text("_passwordStatusBreachedMessage2")
                }
            }
            if password.editable,
               password.statusCode != .good {
                Button {
                    showEditPasswordView = true
                }
                label: {
                    Label("_editPassword", systemImage: "pencil")
                }
                .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
            }
        }
        label: {
            switch password.statusCode {
            case .good:
                Image(systemName: "checkmark.shield.fill")
                    .font(.title)
                    .foregroundColor(.green)
            case .outdated, .duplicate:
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
            case .breached:
                Image(systemName: "xmark.shield.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func faviconImage() -> some View {
        Image(uiImage: favicon ?? UIImage())
            .resizable()
            .frame(width: 64, height: 64)
            .background(favicon == nil ? Color(white: 0.5, opacity: 0.2) : nil)
            .cornerRadius(6)
            .onAppear {
                requestFavicon()
            }
            .onChange(of: password.url) {
                _ in
                requestFavicon()
            }
    }
    
    private func favoriteButton() -> some View {
        Button {
            toggleFavorite()
        }
        label: {
            Image(systemName: password.favorite ? "star.fill" : "star")
                .font(.title)
        }
        .buttonStyle(BorderlessButtonStyle())
        .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
    }
    
    private func serviceSection() -> some View {
        Section(header: Text("_service")) {
            row(subheadline: "_name", text: password.label, copiable: true)
            HStack {
                row(subheadline: "_url", text: password.url, copiable: true)
                if let url = URL(string: password.url),
                   let canOpenURL = UIApplication.safeCanOpenURL,
                   canOpenURL(url),
                   let open = UIApplication.safeOpen {
                    Spacer()
                    Button {
                        open(url)
                    }
                    label: {
                        Image(systemName: "safari")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }
    
    private func accountSection() -> some View {
        Section(header: Text("_account")) {
            row(subheadline: "_username", text: password.username, copiable: true)
            HStack {
                Button {
                    UIPasteboard.general.privateString = password.password
                }
                label: {
                    VStack(alignment: .leading) {
                        Text("_password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(hidePassword ? "••••••••••••" : password.password)
                            .foregroundColor(.primary)
                            .font(.system(.body, design: .monospaced))
                    }
                }
                Spacer()
                Button {
                    hidePassword.toggle()
                }
                label: {
                    Image(systemName: hidePassword ? "eye" : "eye.slash")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
    
    private func notesSection() -> some View {
        Section(header: Text("_notes")) {
            TextView(!password.notes.isEmpty ? password.notes : "-", isSelectable: !password.notes.isEmpty)
                .frame(height: 100)
        }
    }
    
    private func metadataSection() -> some View {
        Section(header: Text("_metadata")) {
            HStack {
                row(subheadline: "_created", text: password.created.formattedString, copiable: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                row(subheadline: "_updated", text: password.updated.formattedString, copiable: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func deleteButton() -> some View {
        Button {
            showDeleteAlert = true
        }
        label: {
            HStack {
                Spacer()
                Text("_deletePassword")
                    .foregroundColor(.red)
                Spacer()
            }
        }
        .actionSheet(isPresented: $showDeleteAlert) {
            ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_deletePassword")) {
                deleteAndDismiss()
            }])
        }
    }
    
    private func selectView(geometry: GeometryProxy, complete: @escaping (String, String) -> Void) -> some View {
        VStack {
            VStack {
                Button("_select") {
                    complete(password.username, password.password)
                }
                .buttonStyle(ActionButtonStyle())
            }
            .padding()
        }
        .padding(.bottom, geometry.safeAreaInsets.bottom)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func trailingToolbarView() -> some View {
        HStack {
            if let state = password.state {
                if state.isError {
                    errorButton(state: state)
                }
                else if state.isProcessing {
                    ProgressView()
                }
                Spacer()
            }
            Button(action: {
                showEditPasswordView = true
            }, label: {
                Text("_edit")
            })
            .disabled(password.state?.isProcessing ?? false || password.state == .decryptionFailed)
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
    
    private func row(subheadline: LocalizedStringKey, text: String, copiable: Bool) -> some View {
        Button {
            UIPasteboard.general.string = text
        }
        label: {
            VStack(alignment: .leading) {
                Text(subheadline)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(!text.isEmpty ? text : "-")
                    .foregroundColor(.primary)
            }
        }
        .disabled(!copiable || text.isEmpty)
    }
    
    // MARK: Functions
    
    private func requestFavicon() {
        guard let url = URL(string: password.url),
              let domain = url.host,
              let session = sessionController.session else {
            return
        }
        FaviconServiceRequest(session: session, domain: domain).send { favicon = $0 }
    }
    
    private func toggleFavorite() {
        password.state = .updating
        
        guard let session = sessionController.session else {
            password.state = .updateFailed
            return
        }
        password.favorite.toggle()
        
        UpdatePasswordRequest(session: session, password: password).send {
            response in
            guard let response = response else {
                password.state = .updateFailed
                password.favorite.toggle()
                return
            }
            password.state = nil
            password.revision = response.revision
            password.updated = Date()
        }
    }
    
    private func deleteAndDismiss() {
        deletePassword()
        presentationMode.wrappedValue.dismiss()
    }
    
}


struct PasswordDetailPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                PasswordDetailPage(password: Password.mock, updatePassword: {}, deletePassword: {})
            }
            .showColumns(false)
            .environmentObject(AutoFillController.mock)
            .environmentObject(BiometricAuthenticationController.mock)
            .environmentObject(SessionController.mock)
            .environmentObject(TipController.mock)
        }
    }
    
}
