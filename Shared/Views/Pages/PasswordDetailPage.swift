import SwiftUI


struct PasswordDetailPage: View {
    
    @ObservedObject var password: Password
    let updatePassword: () -> Void
    let deletePassword: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var autoFillController: AutoFillController
    @EnvironmentObject private var biometricAuthenticationController: BiometricAuthenticationController
    @EnvironmentObject private var credentialsController: CredentialsController
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
    }
    
    private func mainStack() -> some View {
        VStack(spacing: 0) {
            listView()
            if let complete = autoFillController.complete {
                Divider()
                selectView(complete: complete)
            }
            EmptyView()
                .sheet(isPresented: $showEditPasswordView, content: {
                    EditPasswordNavigation(password: password, addPassword: {}, updatePassword: updatePassword)
                        .environmentObject(autoFillController)
                        .environmentObject(biometricAuthenticationController)
                        .environmentObject(credentialsController)
                        .environmentObject(tipController)
                })
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
            passwordSection()
            accountSection()
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
    }
    
    private func passwordSection() -> some View {
        Section(header: Text("_password")) {
            if hidePassword {
                Button {
                    UIPasteboard.general.privateString = password.password
                }
                label: {
                    Text("••••••••••••")
                        .foregroundColor(.primary)
                        .font(.system(.body, design: .monospaced))
                }
            }
            else {
                Button {
                    UIPasteboard.general.privateString = password.password
                }
                label: {
                    Text(password.password)
                        .foregroundColor(.primary)
                        .font(.system(.body, design: .monospaced))
                }
            }
            Button {
                hidePassword.toggle()
            }
            label: {
                Label(hidePassword ? "_showPassword" : "_hidePassword", systemImage: hidePassword ? "eye" : "eye.slash")
            }
        }
    }
    
    private func accountSection() -> some View {
        Section(header: Text("_account")) {
            row(subheadline: "_name", text: password.label, copiable: true)
            row(subheadline: "_username", text: password.username, copiable: true)
            HStack {
                row(subheadline: "_url", text: password.url, copiable: true)
                if let open = UIApplication.safeOpen,
                   let url = URL(string: password.url) {
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
            row(subheadline: "_notes", text: password.notes, copiable: false)
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
    
    private func selectView(complete: @escaping (String, String) -> Void) -> some View {
        VStack {
            Button("_select") {
                complete(password.username, password.password)
            }
            .buttonStyle(ActionButtonStyle())
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func trailingToolbarView() -> some View {
        HStack {
            if password.revision.isEmpty {
                ProgressView()
                Spacer()
            }
            else if let error = password.error {
                errorButton(error: error)
                Spacer()
            }
            Button(action: {
                showEditPasswordView = true
            }, label: {
                Text("_edit")
            })
        }
    }
    
    private func errorButton(error: Entry.EntryError) -> some View {
        Button {
            showErrorAlert = true
        }
        label: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(error == .deleteError ? .gray : .red)
        }
        .buttonStyle(BorderlessButtonStyle())
        .alert(isPresented: $showErrorAlert) {
            switch error {
            case .createError:
                return Alert(title: Text("_error"), message: Text("_createPasswordErrorMessage"))
            case .editError:
                return Alert(title: Text("_error"), message: Text("_editPasswordErrorMessage"))
            case .deleteError:
                return Alert(title: Text("_error"), message: Text("_deletePasswordErrorMessage"))
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
              let credentials = credentialsController.credentials else {
            return
        }
        FaviconServiceRequest(credentials: credentials, domain: domain).send { favicon = $0 }
    }
    
    private func toggleFavorite() {
        guard let credentials = credentialsController.credentials else {
            return
        }
        password.favorite.toggle()
        
        UpdatePasswordRequest(credentials: credentials, password: password).send {
            response in
            guard let response = response else {
                password.favorite.toggle()
                return
            }
            password.error = nil
            password.revision = response.revision
            password.updated = Date()
        }
        password.revision = ""
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
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(AutoFillController.mock)
            .environmentObject(BiometricAuthenticationController.mock)
            .environmentObject(CredentialsController.mock)
            .environmentObject(TipController.mock)
        }
    }
    
}
