import SwiftUI


struct PasswordGenerator: View {
    
    @Binding var password: String
    var generateInitial = false
    
    @AppStorage("generatorNumbers", store: Configuration.userDefaults) private var generatorNumbers = Configuration.defaults["generatorNumbers"] as! Bool // swiftlint:disable:this force_cast
    @AppStorage("generatorSpecial", store: Configuration.userDefaults) private var generatorSpecial = Configuration.defaults["generatorSpecial"] as! Bool // swiftlint:disable:this force_cast
    @AppStorage("generatorStrength", store: Configuration.userDefaults) private var generatorStrength = PasswordServiceRequest.Strength(rawValue: Configuration.defaults["generatorStrength"] as! Int) ?? .default // swiftlint:disable:this force_cast
    
    @State private var showPasswordGenerator = false
    @State private var showPasswordServiceErrorAlert = false
    @State private var showProgressView = false
    
    // MARK: Views
    
    var body: some View {
        Button {
            showPasswordGenerator = true
        }
        label: {
            Image(systemName: "slider.horizontal.3")
        }
        .buttonStyle(.borderless)
        .tooltip(isPresented: $showPasswordGenerator, arrowDirections: [.up, .down]) {
            passwordGenerator()
                .padding()
        }
        .alert(isPresented: $showPasswordServiceErrorAlert) {
            Alert(title: Text("_error"), message: Text("_passwordServiceErrorMessage"))
        }
        .onChange(of: password) { _ in showPasswordGenerator = false }
        .onAppear {
            guard generateInitial,
                  password.isEmpty else {
                return
            }
            generatePassword()
        }
    }
    
    private func passwordGenerator() -> some View {
        VStack(spacing: 16) {
            VStack {
                Toggle("_numbers", isOn: $generatorNumbers)
                Toggle("_specialCharacters", isOn: $generatorSpecial)
                HStack {
                    Text("_strength")
                    Spacer()
                    Picker("", selection: $generatorStrength) {
                        ForEach(PasswordServiceRequest.Strength.allCases) {
                            strength in
                            switch strength {
                            case .low:
                                Text("_low")
                                    .tag(strength)
                            case .default:
                                Text("_default")
                                    .tag(strength)
                            case .medium:
                                Text("_medium")
                                    .tag(strength)
                            case .high:
                                Text("_high")
                                    .tag(strength)
                            case .ultra:
                                Text("_ultra")
                                    .tag(strength)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            Divider()
                .padding(.trailing, -100)
            Button {
                generatePassword()
            }
            label: {
                HStack {
                    Label("_generatePassword", systemImage: "dice")
                    if showProgressView {
                        Spacer()
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(showProgressView)
        }
    }
    
    // MARK: Functions
    
    private func generatePassword() {
        guard let session = SessionController.default.session else {
            showPasswordServiceErrorAlert = true
            return
        }
        
        showProgressView = true
        PasswordServiceRequest(session: session, strength: generatorStrength, numbers: generatorNumbers, special: generatorSpecial).send {
            password in
            showProgressView = false
            guard let password = password else {
                showPasswordServiceErrorAlert = true
                return
            }
            self.password = password
        }
    }
    
}
