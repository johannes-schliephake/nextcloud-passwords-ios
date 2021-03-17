import SwiftUI


struct EditPasswordPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject private var editPasswordController: EditPasswordController
    @ScaledMetric private var sliderLabelWidth: CGFloat = 87
    @State private var hidePassword = true
    @State private var showPasswordGenerator: Bool
    
    init(password: Password, addPassword: @escaping () -> Void, updatePassword: @escaping () -> Void) {
        _editPasswordController = StateObject(wrappedValue: EditPasswordController(password: password, addPassword: addPassword, updatePassword: updatePassword))
        _showPasswordGenerator = State(initialValue: password.id.isEmpty)
    }
    
    // MARK: Views
    
    var body: some View {
        listView()
            .navigationTitle("_password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton()
                }
            }
    }
    
    private func listView() -> some View {
        List {
            serviceSection()
            accountSection()
            passwordGeneratorSection()
            notesSection()
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func serviceSection() -> some View {
        Section(header: Text("_service")) {
            VStack(alignment: .leading) {
                Text("_name")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                TextField("-", text: $editPasswordController.passwordLabel)
            }
            VStack(alignment: .leading) {
                Text("_url")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                TextField("-", text: $editPasswordController.passwordUrl)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.URL)
            }
        }
    }
    
    private func accountSection() -> some View {
        Section(header: Text("_account")) {
            VStack(alignment: .leading) {
                Text("_username")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                TextField("-", text: $editPasswordController.passwordUsername)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("_password")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    if hidePassword {
                        TextField("-", text: .constant("••••••••••••"))
                            .foregroundColor(.primary)
                            .font(.system(.body, design: .monospaced))
                            .disabled(true)
                    }
                    else {
                        TextField("-", text: $editPasswordController.passwordPassword)
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
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
    
    private func passwordGeneratorSection() -> some View {
        DisclosureGroup("_passwordGenerator", isExpanded: $showPasswordGenerator) {
            if horizontalSizeClass == .regular {
                HStack {
                    Toggle("_numbers", isOn: $editPasswordController.generatorNumbers)
                    Divider()
                        .padding(.horizontal)
                    Toggle("_specialCharacters", isOn: $editPasswordController.generatorSpecial)
                }
            }
            else {
                Toggle("_numbers", isOn: $editPasswordController.generatorNumbers)
                Toggle("_specialCharacters", isOn: $editPasswordController.generatorSpecial)
            }
            HStack {
                Text(String(format: "_length(length)".localized, String(Int(editPasswordController.generatorLength))))
                    .frame(width: sliderLabelWidth, alignment: .leading)
                Spacer()
                Slider(value: $editPasswordController.generatorLength, in: 1...36, step: 1)
                    .frame(maxWidth: 400)
            }
            Button {
                editPasswordController.generatePassword()
            }
            label: {
                HStack {
                    Label("_generatePassword", systemImage: "key")
                    if editPasswordController.showProgressView {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(editPasswordController.showProgressView)
            .alert(isPresented: $editPasswordController.showErrorAlert) {
                Alert(title: Text("_error"), message: Text("_passwordServiceErrorMessage"))
            }
        }
    }
    
    private func notesSection() -> some View {
        Section(header: Text("_notes")) {
            TextView("-", text: $editPasswordController.passwordNotes)
                .frame(height: 100)
        }
    }
    
    private func cancelButton() -> some View {
        Button("_cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func confirmButton() -> some View {
        Button(editPasswordController.password.id.isEmpty ? "_create" : "_done") {
            applyAndDismiss()
        }
        .disabled(editPasswordController.passwordPassword.isEmpty || editPasswordController.passwordLabel.isEmpty)
    }
    
    // MARK: Functions
    
    private func applyAndDismiss() {
        editPasswordController.applyToPassword()
        presentationMode.wrappedValue.dismiss()
    }
    
}


struct EditPasswordPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                EditPasswordPage(password: Password.mock, addPassword: {}, updatePassword: {})
            }
            .showColumns(false)
        }
    }
    
}
