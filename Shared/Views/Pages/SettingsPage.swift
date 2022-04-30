import SwiftUI


struct SettingsPage: View {
    
    let updateOfflineData: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var securityCheckController: SecurityCheckController
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
                updateOfflineData()
            }
    }
    
    private func listView() -> some View {
        List {
            if let session = sessionController.session {
                credentialsSection(session: session)
                if #available(iOS 15, *) {
                    securityCheckSection()
                }
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
    
    @available(iOS 15, *)
    private func securityCheckSection() -> some View {
        Section(header: Text("_securityCheck")) {
            switch securityCheckController.state {
            case .notRun:
                EmptyView()
            case .running:
                EmptyView()
            case .failed:
                HStack {
                    Image(systemName: "xmark.shield.fill")
                        .foregroundColor(.red)
                    VStack(alignment: .leading) {
                        Text("_failedToRunSecurityCheck")
                            .bold()
                        Spacer()
                        Text("_securityCheckFailedMessage")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 6)
            case .resultsAvailable:
                if let securityChecks = securityCheckController.securityChecks {
                    let highSeveritySecurityChecks = securityChecks.filter { $0.severity == .high }
                    let mediumSeveritySecurityChecks = securityChecks.filter { $0.severity == .medium }
                    let lowSeveritySecurityChecks = securityChecks.filter { $0.severity == .low }
                    NavigationLink(destination: SecurityCheckPage()) {
                        VStack(alignment: .leading, spacing: 10) {
                            if highSeveritySecurityChecks.isEmpty,
                               mediumSeveritySecurityChecks.isEmpty,
                               lowSeveritySecurityChecks.isEmpty {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                    Text("_yourSetupIsSecure")
                                        .foregroundColor(.gray)
                                }
                            }
                            else {
                                if !highSeveritySecurityChecks.isEmpty {
                                    HStack {
                                        Image(systemName: "xmark.shield.fill")
                                            .foregroundColor(.red)
                                        Text(String(highSeveritySecurityChecks.count))
                                            .bold()
                                        Text("_severeIssues")
                                    }
                                }
                                if !mediumSeveritySecurityChecks.isEmpty {
                                    HStack {
                                        Image(systemName: "exclamationmark.shield.fill")
                                            .foregroundColor(.yellow)
                                        Text(String(mediumSeveritySecurityChecks.count))
                                            .bold()
                                        Text("_warnings")
                                    }
                                }
                                if !lowSeveritySecurityChecks.isEmpty {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.gray)
                                        Text(String(lowSeveritySecurityChecks.count))
                                            .bold()
                                        Text("_suggestions")
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .isDetailLink(false)
                }
            }
            Button {
                securityCheckController.runSecurityCheck()
            }
            label: {
                HStack {
                    Label("_runSecurityCheck", systemImage: "checklist")
                    if securityCheckController.state == .running {
                        Spacer()
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(securityCheckController.state == .running)
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
        .apply {
            view in
            if #unavailable(iOS 15) {
                view
                    .listRowInsets(EdgeInsets())
            }
        }
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
        .apply {
            view in
            if #unavailable(iOS 15) {
                view
                    .listRowInsets(EdgeInsets())
            }
        }
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
                SettingsPage(updateOfflineData: {})
            }
            .showColumns(false)
            .environmentObject(SessionController.mock)
            .environmentObject(TipController.mock)
        }
    }
    
}
