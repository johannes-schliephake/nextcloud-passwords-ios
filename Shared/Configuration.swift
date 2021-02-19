import Foundation


struct Configuration {
    
    static let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String // swiftlint:disable:this force_cast
    static let appService = Bundle.main.object(forInfoDictionaryKey: "AppService") as! String // swiftlint:disable:this force_cast
    static let appGroup = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as! String // swiftlint:disable:this force_cast
    static let appKeychain = Bundle.main.object(forInfoDictionaryKey: "AppKeychain") as! String // swiftlint:disable:this force_cast
    static let clientName = "\(Bundle.main.infoDictionary?["CFBundleName"] as! String) (iOS)" // swiftlint:disable:this force_cast
    static let isTestEnvironment = ProcessInfo.processInfo.environment["TEST"] == "true"
    static let userDefaults = UserDefaults(suiteName: Configuration.appGroup)!
    
    private init() {}
    
}
