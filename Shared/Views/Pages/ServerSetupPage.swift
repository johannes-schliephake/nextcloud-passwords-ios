import SwiftUI


struct ServerSetupPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var serverSetupController = ServerSetupController()
    @available(iOS 15, *) @FocusState private var focusedField: FocusField?
    @State private var showLoginFlowPage = false
    
    // MARK: Views
    
    var body: some View {
        listView()
            .navigationTitle("_connectToServer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    connectButton()
                }
            }
            .apply {
                view in
                if #available(iOS 15, *) {
                    view
                        .initialize(focus: $focusedField, with: .serverAddress)
                }
            }
    }
    
    private func listView() -> some View {
        VStack {
            List {
                serverAddressField()
            }
            .listStyle(.insetGrouped)
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
            if let serverSetupResponse = serverSetupController.response {
                NavigationLink(destination: LoginFlowPage(serverSetupResponse: serverSetupResponse), isActive: $showLoginFlowPage) {}
                    .isDetailLink(false)
            }
        }
    }
    
    private func serverAddressField() -> some View {
        Section(header: Text("_nextcloudServerAddress"), footer: serverAddressFieldFooter()) {
            HStack {
                TextField("-", text: $serverSetupController.serverAddress, onCommit: {
                    openLoginFlowPage()
                })
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .apply {
                    view in
                    if #available(iOS 15, *) {
                        view
                            .focused($focusedField, equals: .serverAddress)
                            .submitLabel(.done)
                    }
                }
                if serverSetupController.isValidating {
                    Spacer()
                    ProgressView()
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
    
    enum FocusField: Hashable {
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
