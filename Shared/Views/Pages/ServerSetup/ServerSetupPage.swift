import SwiftUI
import Factory


struct ServerSetupPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<ServerSetupViewModel>
    
    @FocusState private var focusedField: ServerSetupViewModel.FocusField?
    
    var body: some View {
        Group {
            if viewModel[\.isServerAddressManaged] {
                managedSetupPage()
            } else {
                listView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            connectButton()
                        }
                    }
                    .sync($viewModel[\.focusedField], to: _focusedField)
            }
        }
        .navigationTitle("_connectToServer")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                cancelButton()
            }
        }
        .dismiss(on: viewModel[\.shouldDismiss])
    }
    
    @ViewBuilder private func managedSetupPage() -> some View {
        if let challenge = viewModel[\.challenge] {
            LoginFlowPage(viewModel: resolve(\.loginFlowViewModelType).init(challenge: challenge).eraseToAnyViewModel())
        } else {
            VStack(spacing: 8) {
                ProgressView()
                Text(Strings.connectingToNextcloudInstanceAtUrl(viewModel[\.serverAddress]))
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            .alert(isPresented: $viewModel[\.showManagedServerAddressErrorAlert]) {
                Alert(title: Text("_error"), message: Text(Strings.managedServerUrlErrorMessage), dismissButton: .cancel {
                    viewModel(.cancel)
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
                    viewModel(.dismissKeyboard)
                } label: {
                    Text("_dismiss")
                        .bold()
                }
            }
        }
    }
    
    private func serverAddressField() -> some View {
        Section(header: Text("_nextcloudServerAddress"), footer: serverAddressFieldFooter()) {
            ZStack {
                if let challenge = viewModel[\.challenge] {
                    NavigationLink(destination: LoginFlowPage(viewModel: resolve(\.loginFlowViewModelType).init(challenge: challenge).eraseToAnyViewModel()), isActive: $viewModel[\.showLoginFlowPage]) {}
                        .isDetailLink(false)
                        .frame(width: 0, height: 0)
                        .hidden()
                }
                HStack {
                    TextField("-", text: $viewModel[\.serverAddress])
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .serverAddress)
                        .submitLabel(.done)
                        .onSubmit {
                            if viewModel[\.challengeAvailable] {
                                viewModel(.connect)
                            }
                        }
                    if viewModel[\.isValidating] {
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
            viewModel(.cancel)
        }
    }
    
    private func connectButton() -> some View {
        Button("_connect") {
            viewModel(.connect)
        }
        .enabled(viewModel[\.challengeAvailable])
    }
    
}
