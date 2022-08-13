import Foundation


enum Configuration {
    
    static let defaults: [String: Any] = [
        "automaticallyGeneratePasswords": true,
        "storeOffline": true,
        "didAcceptAboutOtps": false,
        "showMetadata": true,
        "generatorNumbers": true,
        "generatorSpecial": true,
        "generatorStrength": PasswordServiceRequest.Strength.ultra.rawValue
    ]
    
    static let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String // swiftlint:disable:this force_cast
    static let appService = Bundle.main.object(forInfoDictionaryKey: "AppService") as! String // swiftlint:disable:this force_cast
    static let appGroup = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as! String // swiftlint:disable:this force_cast
    static let appKeychain = Bundle.main.object(forInfoDictionaryKey: "AppKeychain") as! String // swiftlint:disable:this force_cast
    /// Make sure to only use ASCII characters for the client name because it is used in HTTP headers
    static let clientName = "\(Bundle.root.infoDictionary?["CFBundleName"] as! String) (iOS\(appService.hasSuffix("debug") ? ", Debug" : ""))" // swiftlint:disable:this force_cast
    static let isTestEnvironment = ProcessInfo.processInfo.environment["TEST"] == "true"
    static let userDefaults: UserDefaults = {
        let userDefaults = UserDefaults(suiteName: isTestEnvironment ? "test.\(Configuration.appGroup)" : Configuration.appGroup)!
        userDefaults.register(defaults: defaults)
        return userDefaults
    }()
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    static let nonUpdatingJsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()
    static let updatingJsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.userInfo[CodingUserInfoKey(rawValue: "updated")!] = true
        return encoder
    }()
    
}
