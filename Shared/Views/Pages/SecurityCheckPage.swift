import SwiftUI


struct SecurityCheckPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var securityCheckController: SecurityCheckController
    
    @State private var showErrorAlert = false
    
    // MARK: Views
    
    var body: some View {
        listView()
            .navigationTitle("_securityCheck")
    }
    
    private func listView() -> some View {
        List {
            if let securityChecks = securityCheckController.securityChecks {
                let highSeveritySecurityChecks = securityChecks.filter { $0.severity == .high }
                let mediumSeveritySecurityChecks = securityChecks.filter { $0.severity == .medium }
                let lowSeveritySecurityChecks = securityChecks.filter { $0.severity == .low }
                if highSeveritySecurityChecks.isEmpty,
                   mediumSeveritySecurityChecks.isEmpty,
                   lowSeveritySecurityChecks.isEmpty {
                    VStack(alignment: .center) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("_yourSetupIsSecure")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                else {
                    if !highSeveritySecurityChecks.isEmpty {
                        securityCheckSection(securityChecks: highSeveritySecurityChecks, header: Text("_severeIssues"), footer: Text("_severeIssuesMessage"))
                    }
                    if !mediumSeveritySecurityChecks.isEmpty {
                        securityCheckSection(securityChecks: mediumSeveritySecurityChecks, header: Text("_warnings"), footer: Text("_warningsMessage"))
                    }
                    if !lowSeveritySecurityChecks.isEmpty {
                        securityCheckSection(securityChecks: lowSeveritySecurityChecks, header: Text("_suggestions"), footer: Text("_suggestionsMessage"))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func securityCheckSection<Header: View, Footer: View>(securityChecks: [SecurityCheck], header: Header, footer: Footer) -> some View {
        Section(header: header, footer: footer) {
            ForEach(securityChecks, id: \.id) {
                securityCheck in
                if let severity = securityCheck.severity {
                    HStack {
                        switch severity {
                        case .high:
                            Image(systemName: "xmark.shield.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        case .medium:
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.title)
                                .foregroundColor(.yellow)
                        case .low:
                            Image(systemName: "info.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        VStack(alignment: .leading) {
                            if #available(iOS 15, *) {
                                switch securityCheck {
                                case is CertificateSecurityCheck:
                                    Text("_invalidCertificate")
                                        .bold()
                                    Spacer()
                                    Text("_invalidCertificateMessage2")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                default:
                                    EmptyView()
                                }
                            }
                            Spacer()
                            HStack {
                                if securityCheck.fix != nil {
                                    Button("_fix") {
                                        fix(securityCheck: securityCheck)
                                    }
                                    .buttonStyle(.borderless)
                                }
                                Button("_ignore") {
                                    securityCheckController.ignore(securityCheck: securityCheck)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("_error"), message: Text("_fixSecurityCheckErrorMessage"))
        }
    }
    
    // MARK: Functions
    
    private func fix(securityCheck: SecurityCheck) {
        Task {
            do {
                try await securityCheck.fix?()
                securityCheckController.ignore(securityCheck: securityCheck)
            }
            catch SecurityCheckError.fixIncomplete {}
            catch {
                showErrorAlert = true
            }
        }
    }
    
}


struct SecurityCheckPagePreview: PreviewProvider {
    
    static var previews: some View {
        PreviewDevice.generate {
            NavigationView {
                SecurityCheckPage()
            }
            .showColumns(false)
        }
    }
    
}
