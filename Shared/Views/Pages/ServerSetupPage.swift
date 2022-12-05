import SwiftUI


struct ServerSetupPage: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var serverSetupController = ServerSetupController()
    @FocusState private var focusedField: FocusField?
    @State private var showLoginFlowPage = false
    
    // MARK: Views
    
    var body: some View {
        Group {
            if serverSetupController.serverUrlIsManaged {
                managedSetupPage()
            }
            else {
                listView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            connectButton()
                        }
                    }
                    .initialize(focus: $focusedField, with: .serverAddress)
            }
        }
        .navigationTitle("_connectToServer")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                cancelButton()
            }
        }
    }
    
    @ViewBuilder private func managedSetupPage() -> some View {
        if let serverSetupResponse = serverSetupController.response {
            LoginFlowPage(serverSetupResponse: serverSetupResponse)
        }
        else {
            VStack(spacing: 8) {
                ProgressView()
                Text(Strings.connectingToNextcloudInstanceAtUrl(serverSetupController.serverAddress))
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
            }
            .alert(isPresented: $serverSetupController.showManagedServerUrlErrorAlert) {
                Alert(title: Text("_error"), message: Text(Strings.managedServerUrlErrorMessage), dismissButton: .cancel {
                    dismiss()
                })
            }
        }
    }
    
    private func listView() -> some View {
        List {
            serverAddressField()
        }
        .listStyle(.insetGrouped)
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
    
    private func serverAddressField() -> some View {
        Section(header: Text("_nextcloudServerAddress"), footer: serverAddressFieldFooter()) {
            ZStack {
                if let serverSetupResponse = serverSetupController.response {
                    NavigationLink(destination: LoginFlowPage(serverSetupResponse: serverSetupResponse), isActive: $showLoginFlowPage) {}
                        .isDetailLink(false)
                        .frame(width: 0, height: 0)
                        .hidden()
                }
                HStack {
                    TextField("-", text: $serverSetupController.serverAddress, onCommit: {
                        openLoginFlowPage()
                    })
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .serverAddress)
                    .submitLabel(.done)
                    if serverSetupController.isValidating {
                        Spacer()
                        ProgressView()
                    }
                }
            }
        }
    }
    
    private func serverAddressFieldFooter() -> some View {
        Text("_serverAddressFieldMessage")
            .font(.footnote)
            .foregroundColor(.gray)
            .padding(.vertical, 6)
    }
    
    private func cancelButton() -> some View {
        Button("_cancel", role: .cancel) {
            dismiss()
        }
    }
    
    private func connectButton() -> some View {
        Button("_connect") {
            openLoginFlowPage()
        }
        .disabled(serverSetupController.response == nil)
    }
    
    // MARK: Functions
    
    private func openLoginFlowPage() {
        if serverSetupController.response != nil {
            showLoginFlowPage = true
        }
    }
    
}


extension ServerSetupPage {
    
    private enum FocusField: Hashable {
        case serverAddress
    }
    
}


struct ServerSetupPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                ServerSetupPage()
            }
            .showColumns(false)
        }
    }
    
}
