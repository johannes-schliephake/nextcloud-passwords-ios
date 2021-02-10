import Foundation


struct Configuration {
    
    static let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static let appService = Bundle.main.object(forInfoDictionaryKey: "AppService") as! String
    static let appGroup = Bundle.main.object(forInfoDictionaryKey: "AppKeychain") as! String
    static let clientName = "\(Bundle.main.infoDictionary?["CFBundleName"] as! String) (iOS)"
    
    private init() {}
    
}
