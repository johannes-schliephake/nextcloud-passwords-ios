import SwiftUI


protocol Configurating {
    
    static var buildNumberString: String { get }
    static var shortVersionString: String { get }
    static var appService: String { get }
    static var appGroup: String { get }
    static var appKeychain: String { get }
    static var clientName: String { get }
    static var isDebug: Bool { get }
    static var isTestEnvironment: Bool { get }
    static var isTestFlight: Bool { get }
    static var userDefaults: UserDefaults { get }
    static var jsonDecoder: JSONDecoder { get }
    static var nonUpdatingJsonEncoder: JSONEncoder { get }
    static var updatingJsonEncoder: JSONEncoder { get }
    static var propertyListDecoder: PropertyListDecoder { get }
    
}


enum Configuration: Configurating {
    
    static let defaults: [String: Any] = [
        "automaticallyGeneratePasswords": true,
        "storeOffline": true,
        "universalClipboard": false,
        "didAcceptAboutOtps": false,
        "showMetadata": true,
        "generatorNumbers": true,
        "generatorSpecial": true,
        "generatorStrength": PasswordServiceRequest.Strength.ultra.rawValue
    ]
    
    static let buildNumberString = Bundle.main.infoDictionary?["CFBundleVersion"] as! String // swiftlint:disable:this force_cast
    static let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String // swiftlint:disable:this force_cast
    static let appService = Bundle.main.object(forInfoDictionaryKey: "AppService") as! String // swiftlint:disable:this force_cast
    static let appGroup = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as! String // swiftlint:disable:this force_cast
    static let appKeychain = Bundle.main.object(forInfoDictionaryKey: "AppKeychain") as! String // swiftlint:disable:this force_cast
    /// Make sure to only use ASCII characters for the client name because it is used in HTTP headers
    static let clientName = "\(Bundle.root.infoDictionary?["CFBundleName"] as! String) (iOS\(isDebug ? ", Debug" : ""))" // swiftlint:disable:this force_cast
    static let isDebug = appService.hasSuffix("debug")
    static let isTestEnvironment = ProcessInfo.processInfo.environment["TEST"] == "true"
    static let isTestFlight = Bundle.root.isTestFlight
    static let userDefaults: UserDefaults = {
        let userDefaults = UserDefaults(suiteName: isTestEnvironment ? "test.\(Self.appGroup)" : Self.appGroup)!
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
    static let propertyListDecoder = PropertyListDecoder()
    
}
