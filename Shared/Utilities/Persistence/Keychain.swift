import Foundation


/// Functions for managing key-value string pairs in keychain
final class Keychain {
    
    static let `default` = Keychain(service: Configuration.appService, accessGroup: Configuration.appKeychain)
    
    private let service: String
    private let accessGroup: String
    
    init(service: String, accessGroup: String) {
        self.service = service
        self.accessGroup = accessGroup
        
        if !Configuration.userDefaults.bool(forKey: "appDidLaunch") {
            clear()
            Configuration.userDefaults.set(true, forKey: "appDidLaunch")
        }
    }
    
    func store(key: String, value: String) {
        if Configuration.isTestEnvironment {
            return
        }
        
        let dataFromString = Data(value.utf8)
        var attributes: [CFString: Any] = [kSecAttrService: service,
                          kSecAttrAccessGroup: accessGroup,
                          kSecClass: kSecClassGenericPassword,
                          kSecAttrAccount: key]
        let attributesToUpdate: [CFString: Any] = [kSecValueData: dataFromString]
        let status = SecItemUpdate(attributes as CFDictionary, attributesToUpdate as CFDictionary)
        
        if status == errSecItemNotFound {
            attributes = [kSecAttrService: service,
                          kSecAttrAccessGroup: accessGroup,
                          kSecClass: kSecClassGenericPassword,
                          kSecAttrAccount: key,
                          kSecValueData: dataFromString]
            SecItemAdd(attributes as CFDictionary, nil)
        }
    }
    
    func load(key: String) -> String? {
        if Configuration.isTestEnvironment {
            return nil
        }
        
        let attributes: [CFString: Any] = [kSecAttrService: service,
                          kSecAttrAccessGroup: accessGroup,
                          kSecClass: kSecClassGenericPassword,
                          kSecAttrAccount: key,
                          kSecReturnData: kCFBooleanTrue!,
                          kSecMatchLimit: kSecMatchLimitOne]
        var result: AnyObject?
        let status = SecItemCopyMatching(attributes as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8) // swiftlint:disable:this non_optional_string_data_conversion
    }
    
    func remove(key: String) {
        if Configuration.isTestEnvironment {
            return
        }
        
        let attributes: [CFString: Any] = [kSecAttrService: service,
                          kSecAttrAccessGroup: accessGroup,
                          kSecClass: kSecClassGenericPassword,
                          kSecAttrAccount: key]
        SecItemDelete(attributes as CFDictionary)
    }
    
    func clear() {
        if Configuration.isTestEnvironment {
            return
        }
        
        let attributes: [CFString: Any] = [kSecAttrService: service,
                          kSecAttrAccessGroup: accessGroup,
                          kSecClass: kSecClassGenericPassword]
        SecItemDelete(attributes as CFDictionary)
    }
    
}
