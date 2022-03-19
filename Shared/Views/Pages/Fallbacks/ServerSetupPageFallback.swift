import SwiftUI


struct ServerSetupPageFallback: View { /// This insanely dumb workaround (duplicated view) prevents a crash on iOS 14 when an attribute is marked with `@available(iOS 15, *) @FocusState`
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var serverSetupController = ServerSetupController()
    // @available(iOS 15, *) @FocusState private var focusedField: FocusField?
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
                        // .initialize(focus: $focusedField, with: .serverAddress)
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
                                    // focusedField = nil
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
                    .apply {
                        view in
                        if #available(iOS 15, *) {
                            view
                                // .focused($focusedField, equals: .serverAddress)
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


extension ServerSetupPageFallback {
    
    private enum FocusField: Hashable {
        case serverAddress
    }
    
}


struct ServerSetupPageFallbackPreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                ServerSetupPageFallback()
            }
            .showColumns(false)
        }
    }
    
}
