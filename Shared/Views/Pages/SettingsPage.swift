import SwiftUI


struct SettingsPage: View {
    
    let updateOfflineContainers: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var sessionController: SessionController
    @EnvironmentObject private var tipController: TipController
    
    @AppStorage("storeOffline", store: Configuration.userDefaults) private var storeOffline = Configuration.defaults["storeOffline"] as! Bool // swiftlint:disable:this force_cast
    @AppStorage("automaticallyGeneratePasswords", store: Configuration.userDefaults) private var automaticallyGeneratePasswords = Configuration.defaults["automaticallyGeneratePasswords"] as! Bool // swiftlint:disable:this force_cast
    @State private var showLogoutAlert = false
    
    // MARK: Views
    
    var body: some View {
        listView()
            .navigationTitle("_settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    doneButton()
                }
            }
            .onChange(of: storeOffline) {
                storeOffline in
                if !storeOffline {
                    Crypto.AES256.removeKey(named: "offlineKey")
                }
                updateOfflineContainers()
            }
    }
    
    private func listView() -> some View {
        List {
            if let session = sessionController.session {
                credentialsSection(session: session)
            }
            optionsSection()
            enableProviderSection()
            supportThisProjectSection()
            aboutSection()
            thanksSection()
        }
        .listStyle(.insetGrouped)
    }
    
    private func credentialsSection(session: Session) -> some View {
        Section(header: Text("_credentials")) {
            LabeledRow(type: .text, label: "_nextcloudServerAddress" as LocalizedStringKey, value: session.server)
            LabeledRow(type: .text, label: "_username" as LocalizedStringKey, value: session.user)
            if #available(iOS 15.0, *) {
                Button(role: .destructive) {
                    showLogoutAlert = true
                }
                label: {
                    HStack {
                        Spacer()
                        Text("_logOut")
                        Spacer()
                    }
                }
                .actionSheet(isPresented: $showLogoutAlert) {
                    ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_logOut")) {
                        logoutAndDismiss()
                    }])
                }
            }
            else {
                Button {
                    showLogoutAlert = true
                }
                label: {
                    HStack {
                        Spacer()
                        Text("_logOut")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .actionSheet(isPresented: $showLogoutAlert) {
                    ActionSheet(title: Text("_confirmAction"), buttons: [.cancel(), .destructive(Text("_logOut")) {
                        logoutAndDismiss()
                    }])
                }
            }
        }
    }
    
    private func optionsSection() -> some View {
        Section(header: Text("_options")) {
            Toggle("_encryptedOfflineStorage", isOn: $storeOffline)
            Toggle("_automaticallyGeneratePasswords", isOn: $automaticallyGeneratePasswords)
        }
    }
    
    private func enableProviderSection() -> some View {
        Section(header: Text("_integration")) {
            VStack {
                Text("_providerInstructionsMessage")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color(UIColor.systemGroupedBackground))
    }
    
    private func supportThisProjectSection() -> some View {
        Section(header: Text("_supportThisProject")) {
            Menu {
                if let products = tipController.products {
                    ForEach(products, id: \.productIdentifier) {
                        product in
                        if let localizedPrice = product.localizedPrice {
                            Button {
                                tipController.purchase(product: product)
                            }
                            label: {
                                Text("\(product.localizedTitle) (\(localizedPrice))")
                            }
                        }
                    }
                }
            }
            label: {
                HStack {
                    Label("_giveATip", systemImage: "heart")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if tipController.transactionState != nil {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(tipController.products == nil || tipController.transactionState != nil)
        }
    }
    
    private func aboutSection() -> some View {
        Section(header: Text("_about")) {
            LabeledRow(type: .text, label: "_version" as LocalizedStringKey, value: Configuration.shortVersionString)
            if let url = URL(string: "https://github.com/johannes-schliephake/nextcloud-passwords-ios") {
                Link(destination: url) {
                    Label("_sourceCode", systemImage: "curlybraces")
                }
            }
        }
    }
    
    private func thanksSection() -> some View {
        Section {
            VStack {
                Text("_thanksMessage")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
                HStack {
                    Spacer()
                    Text("Johannes Schliephake")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color(UIColor.systemGroupedBackground))
    }
    
    private func doneButton() -> some View {
        Button("_done") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // MARK: Functions
    
    private func logoutAndDismiss() {
        sessionController.logout()
        presentationMode.wrappedValue.dismiss()
    }
    
}


struct SettingsPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                SettingsPage(updateOfflineContainers: {})
            }
            .showColumns(false)
            .environmentObject(SessionController.mock)
            .environmentObject(TipController.mock)
        }
    }
    
}
