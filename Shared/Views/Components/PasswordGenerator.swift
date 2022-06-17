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
        VStack(spacing: 15) {
            VStack {
                Toggle("_numbers", isOn: $generatorNumbers)
                Toggle("_specialCharacters", isOn: $generatorSpecial)
                HStack(spacing: 16) {
                    Text("_strength")
                    VStack(spacing: 4) {
                        ZStack {
                            HStack {
                                Rectangle()
                                    .frame(width: 4, height: 6)
                                ForEach(1..<PasswordServiceRequest.Strength.allCases.count, id: \.self) {
                                    _ in
                                    Spacer()
                                    Rectangle()
                                        .frame(width: 4, height: 6)
                                }
                            }
                            .foregroundColor(Color(white: 0.5, opacity: 0.23))
                            .padding(.horizontal, 11.5)
                            .offset(y: 6)
                            Slider(value: Binding(get: {
                                Double(generatorStrength.rawValue)
                            }, set: {
                                generatorStrength = PasswordServiceRequest.Strength(rawValue: Int($0)) ?? generatorStrength
                            }), in: 0...Double(PasswordServiceRequest.Strength.allCases.count - 1), step: 1)
                        }
                        ZStack {
                            Text("_low")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("_medium")
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("_ultra")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
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
            guard let password else {
                showPasswordServiceErrorAlert = true
                return
            }
            self.password = password
        }
    }
    
}
