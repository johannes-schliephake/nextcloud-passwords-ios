import SwiftUI


final class EditPasswordController: ObservableObject {
    
    let entriesController: EntriesController
    let password: Password
    
    @Published var generatorNumbers = Configuration.userDefaults.object(forKey: "generatorNumbers") as? Bool ?? true {
        willSet {
            Configuration.userDefaults.set(newValue, forKey: "generatorNumbers")
        }
    }
    @Published var generatorSpecial = Configuration.userDefaults.object(forKey: "generatorSpecial") as? Bool ?? true {
        willSet {
            Configuration.userDefaults.set(newValue, forKey: "generatorSpecial")
        }
    }
    @Published var generatorLength = Configuration.userDefaults.object(forKey: "generatorLength") as? Double ?? 36.0 {
        willSet {
            Configuration.userDefaults.set(newValue, forKey: "generatorLength")
        }
    }
    @Published var passwordPassword: String
    @Published var passwordLabel: String
    @Published var passwordUsername: String
    @Published var passwordUrl: String
    @Published var passwordCustomUserFields: [Password.CustomField]
    @Published var passwordOtp: OTP? {
        didSet {
            if passwordLabel.isEmpty,
               let issuer = passwordOtp?.issuer {
                passwordLabel = issuer
            }
            if passwordUsername.isEmpty,
               let username = passwordOtp?.accountname {
                passwordUsername = username
            }
        }
    }
    @Published var passwordNotes: String
    @Published var passwordFavorite: Bool
    @Published var passwordValidTags: [Tag]
    let passwordInvalidTags: [String]
    @Published var passwordFolder: String
    @Published var showExtractOtpErrorAlert = false
    @Published var showPasswordServiceErrorAlert = false
    @Published var showProgressView = false
    
    init(entriesController: EntriesController, password: Password) {
        self.entriesController = entriesController
        self.password = password
        passwordPassword = password.password
        passwordLabel = password.label
        passwordUsername = password.username
        passwordUrl = password.url
        passwordCustomUserFields = password.customUserFields
        passwordOtp = password.otp
        passwordNotes = password.notes
        passwordFavorite = password.favorite
        (passwordValidTags, passwordInvalidTags) = EntriesController.tags(for: password.tags, in: entriesController.tags ?? [])
        passwordFolder = password.folder
    }
    
    var folderLabel: String {
        entriesController.folders?.first(where: { $0.id == passwordFolder })?.label ?? "_passwords".localized
    }
    
    var hasChanges: Bool {
        passwordPassword != password.password ||
        passwordLabel != password.label ||
        passwordUsername != password.username ||
        passwordUrl != password.url ||
        passwordCustomUserFields != password.customUserFields ||
        passwordOtp != password.otp ||
        passwordNotes != password.notes ||
        passwordFavorite != password.favorite ||
        passwordValidTags.map { $0.id }.sorted() != EntriesController.tags(for: password.tags, in: entriesController.tags ?? []).valid.map { $0.id }.sorted() ||
        passwordFolder != password.folder
    }
    
    var editIsValid: Bool {
        1...64 ~= passwordLabel.count &&
        passwordUsername.count <= 64 &&
        1...256 ~= passwordPassword.count &&
        passwordUrl.count <= 2048 &&
        passwordNotes.count <= 4096 &&
        passwordCustomFieldCount <= 20 &&
        passwordCustomUserFields.allSatisfy { 1...48 ~= $0.label.count && 1...320 ~= $0.value.count }
    }
    
    var passwordCustomFieldCount: Int {
        passwordCustomUserFields.count + password.customDataFields.count + (passwordOtp != nil ? 1 : 0)
    }
    
    func extractOtp(from image: UIImage) {
        guard let ciImage = CIImage(image: image),
              let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil),
              let features = detector.features(in: ciImage) as? [CIQRCodeFeature],
              let url = URL(string: features.compactMap(\.messageString).joined()),
              let otp = OTP(from: url) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                [weak self] in
                self?.showExtractOtpErrorAlert = true
            }
            return
        }
        passwordOtp = otp
    }
    
    func generatePassword() {
        guard let session = SessionController.default.session else {
            showPasswordServiceErrorAlert = true
            return
        }
        
        showProgressView = true
        PasswordServiceRequest(session: session, numbers: generatorNumbers, special: generatorSpecial).send {
            [weak self] password in
            self?.showProgressView = false
            guard let password = password,
                  let generatorLength = self?.generatorLength else {
                self?.showPasswordServiceErrorAlert = true
                return
            }
            self?.passwordPassword = String(password.prefix(Int(generatorLength)))
        }
    }
    
    func applyToPassword() {
        if password.id.isEmpty {
            password.created = Date()
        }
        if password.password != passwordPassword {
            password.edited = Date()
        }
        password.updated = Date()
        
        let hash = Crypto.SHA1.hash(passwordPassword.data(using: .utf8)!)
        password.hash = String(hash.prefix(SettingsController.default.userPasswordSecurityHash))
        
        password.password = passwordPassword
        password.label = passwordLabel
        password.username = passwordUsername
        password.url = passwordUrl
        password.customUserFields = passwordCustomUserFields
        password.otp = passwordOtp
        password.notes = passwordNotes
        password.favorite = passwordFavorite
        password.tags = passwordValidTags.map { $0.id } + passwordInvalidTags
        password.folder = entriesController.folders?.contains { $0.id == passwordFolder } == true ? passwordFolder : Entry.baseId
        
        if password.id.isEmpty {
            entriesController.add(password: password)
        }
        else {
            entriesController.update(password: password)
        }
    }
    
}
