import SwiftUI


struct ServerSetupPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var serverSetupController = ServerSetupController()
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
    }
    
    private func listView() -> some View {
        VStack {
            List {
                serverAddressField()
            }
            .listStyle(InsetGroupedListStyle())
            if let serverUrl = serverSetupController.validServerUrl {
                NavigationLink(destination: LoginFlowPage(serverUrl: serverUrl), isActive: $showLoginFlowPage) {}
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
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.URL)
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
    
    private func cancelButton() -> some View {
        Button("_cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func connectButton() -> some View {
        Button("_connect") {
            openLoginFlowPage()
        }
        .disabled(serverSetupController.validServerUrl == nil)
    }
    
    // MARK: Functions
    
    private func openLoginFlowPage() {
        if serverSetupController.validServerUrl != nil {
            showLoginFlowPage = true
        }
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
