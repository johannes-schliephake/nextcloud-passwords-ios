import SwiftUI
import Factory


struct SettingsPage: View {
    
    @StateObject var viewModel: AnyViewModelOf<SettingsViewModel>
    
    var body: some View {
        listView()
            .navigationTitle("_settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    doneButton()
                }
            }
            .dismiss(on: viewModel[\.shouldDismiss])
    }
    
    private func listView() -> some View {
        List {
            if let username = viewModel[\.username],
               let server = viewModel[\.server] {
                credentialsSection(username: username, server: server)
            }
            optionsSection()
            enableProviderSection()
            supportThisProjectSection()
            aboutSection()
            thanksSection()
        }
        .listStyle(.insetGrouped)
    }
    
    private func credentialsSection(username: String, server: String) -> some View {
        Section(header: Text("_credentials")) {
            LabeledRow(type: .nonLinguisticText, label: "_nextcloudServerAddress", value: server)
            LabeledRow(type: .nonLinguisticText, label: "_username", value: username)
            if viewModel[\.isChallengePasswordStored] {
                Button {
                    viewModel(.clearChallengePassword)
                } label: {
                    if #available(iOS 17, *) {
                        Label(Strings.clearStoredE2EPassword, systemImage: "key.slash")
                    } else {
                        Label(Strings.clearStoredE2EPassword, systemImage: "delete.left")
                    }
                }
                .disabled(viewModel[\.wasChallengePasswordCleared])
            }
            Button(role: .destructive) {
                viewModel(.logout)
            } label: {
                HStack {
                    Spacer()
                    Text("_logOut")
                    Spacer()
                }
            }
            .actionSheet(isPresented: $viewModel[\.showLogoutAlert]) {
                ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_logOut")) {
                    viewModel(.confirmLogout)
                }])
            }
        }
        .apply { view in
            if #available(iOS 16, *) {
                view
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
        }
    }
    
    private func optionsSection() -> some View {
        Section(header: Text("_options")) {
            Toggle("_encryptedOfflineStorage", isOn: .init {
                viewModel[\.isOfflineStorageEnabled]
            } set: { isOn in
                viewModel(.setIsOfflineStorageEnabled(isOn))
            })
            Toggle("_automaticallyGeneratePasswords", isOn: .init {
                viewModel[\.isAutomaticPasswordGenerationEnabled]
            } set: { isOn in
                viewModel(.setIsAutomaticPasswordGenerationEnabled(isOn))
            })
            Toggle(Strings.universalClipboard, isOn: .init {
                viewModel[\.isUniversalClipboardEnabled]
            } set: { isOn in
                viewModel(.setIsUniversalClipboardEnabled(isOn))
            })
        }
    }
    
    private func enableProviderSection() -> some View {
        Section(header: Text("_integration")) {
            if #available(iOS 17, *),
               let attributedString = try? AttributedString(markdown: Strings.providerInstructionsMessageWithLink, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                Text(attributedString)
                    .environment(\.openURL, .init { url in
                        viewModel(.openProviderSettingsUrl(url))
                        return .handled
                    })
            } else {
                Text("_providerInstructionsMessage")
            }
        }
        .font(.footnote)
        .foregroundColor(.gray)
        .monospacedDigit()
        .listRowBackground(Color(UIColor.systemGroupedBackground))
    }
    
    private func supportThisProjectSection() -> some View {
        Section(header: Text("_supportThisProject"), footer: supportThisProjectFooter()) {
            Menu {
                if let products = viewModel[\.tipProducts] {
                    ForEach(products, id: \.id) { product in
                        Button {
                            viewModel(.tip(product))
                        } label: {
                            Text("\(product.displayName) (\(product.displayPrice))")
                        }
                    }
                }
            } label: {
                HStack {
                    Label("_giveATip", systemImage: "heart")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if viewModel[\.isTipTransactionRunning] {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .enabled(viewModel[\.canPurchaseTip])
            if !viewModel[\.isTestFlight],
               let betaUrl = viewModel[\.betaUrl] {
                Link(destination: betaUrl) {
                    Label(Strings.joinTestFlightBeta, systemImage: "testtube.2")
                }
            }
        }
        .apply { view in
            if #available(iOS 16, *) {
                view
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
        }
    }
    
    @ViewBuilder private func supportThisProjectFooter() -> some View {
        if viewModel[\.isTestFlight] {
            Text(Strings.supportThisProjectMessage)
        }
    }
    
    private func aboutSection() -> some View {
        Section(header: Text("_about")) {
            if viewModel[\.isLogAvailable] {
                NavigationLink {
                    LogPage(viewModel: LogViewModel().eraseToAnyViewModel())
                } label: {
                    Label("Log", systemImage: "doc.text.magnifyingglass")
                        .foregroundColor(.accentColor)
                        .apply { view in
                            if #available(iOS 17, *) {
                                view
                                    .typesettingLanguage(.init(languageCode: .english))
                            }
                        }
                        .apply { view in
                            if #available(iOS 16, *) {
                                view
                                    .environment(\.locale, .init(languageCode: .english))
                            } else {
                                view
                                    .environment(\.locale, .init(identifier: "en"))
                            }
                        }
                }
                .isDetailLink(false)
            }
            LabeledRow(type: .text, label: "_version", value: viewModel[\.versionName])
            if let sourceCodeUrl = viewModel[\.sourceCodeUrl] {
                Link(destination: sourceCodeUrl) {
                    Label("_sourceCode", systemImage: "curlybraces")
                }
            }
        }
        .apply { view in
            if #available(iOS 16, *) {
                view
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
        }
    }
    
    private func thanksSection() -> some View {
        Section {
            VStack(spacing: 8) {
                Text("_thanksMessage")
                    .font(.footnote)
                    .foregroundColor(.gray)
                HStack {
                    Spacer()
                    Text("Johannes Schliephake")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.gray)
                        .apply { view in
                            if #available(iOS 17, *) {
                                view
                                    .typesettingLanguage(.init(languageCode: .german))
                            }
                        }
                        .apply { view in
                            if #available(iOS 16, *) {
                                view
                                    .environment(\.locale, .init(languageCode: .german))
                            } else {
                                view
                                    .environment(\.locale, .init(identifier: "de"))
                            }
                        }
                    Spacer()
                }
            }
        }
        .listRowBackground(Color(UIColor.systemGroupedBackground))
    }
    
    private func doneButton() -> some View {
        Button("_done") {
            viewModel(.done)
        }
    }
    
}
