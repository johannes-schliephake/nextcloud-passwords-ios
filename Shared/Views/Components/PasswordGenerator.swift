import SwiftUI


struct PasswordGenerator: View {
    
    @Binding var password: String
    var generateInitial = false
    
    @ScaledMetric private var sliderLabelWidth = 87.0
    @AppStorage("generatorNumbers", store: Configuration.userDefaults) private var generatorNumbers = Configuration.defaults["generatorNumbers"] as! Bool // swiftlint:disable:this force_cast
    @AppStorage("generatorSpecial", store: Configuration.userDefaults) private var generatorSpecial = Configuration.defaults["generatorSpecial"] as! Bool // swiftlint:disable:this force_cast
    @AppStorage("generatorLength", store: Configuration.userDefaults) private var generatorLength = Configuration.defaults["generatorLength"] as! Double // swiftlint:disable:this force_cast
    
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
                    Text(String(format: "_length(length)".localized, String(Int(generatorLength))))
                        .frame(width: sliderLabelWidth, alignment: .leading)
                    Spacer()
                    Slider(value: $generatorLength, in: 1...36, step: 1)
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
        PasswordServiceRequest(session: session, numbers: generatorNumbers, special: generatorSpecial).send {
            password in
            showProgressView = false
            guard let password = password else {
                showPasswordServiceErrorAlert = true
                return
            }
            self.password = String(password.prefix(Int(generatorLength)))
        }
    }
    
}
