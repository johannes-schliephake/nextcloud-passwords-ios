import SwiftUI


struct SettingsPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var credentialsController: CredentialsController
    @EnvironmentObject private var tipController: TipController
    
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
    }
    
    private func listView() -> some View {
        List {
            if let credentials = credentialsController.credentials {
                credentialsSection(credentials: credentials)
            }
            enableProviderSection()
            supportThisProjectSection()
            aboutSection()
            thanksSection()
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func credentialsSection(credentials: Credentials) -> some View {
        Section(header: Text("_credentials")) {
            row(subheadline: "_nextcloudServerAddress", text: credentials.server)
            row(subheadline: "_username", text: credentials.user)
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
            row(subheadline: "_version", text: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
            if let open = UIApplication.safeOpen {
                Button {
                    open(URL(string: "https://github.com/johannes-schliephake/nextcloud-passwords-ios")!)
                }
                label: {
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
                        .fontWeight(.bold)
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
    
    private func row(subheadline: LocalizedStringKey, text: String) -> some View {
        VStack(alignment: .leading) {
            Text(subheadline)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(text)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: Functions
    
    private func logoutAndDismiss() {
        credentialsController.logout()
        presentationMode.wrappedValue.dismiss()
    }
    
}


struct SettingsPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                SettingsPage()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(CredentialsController.mock)
            .environmentObject(TipController.mock)
        }
    }
    
}
