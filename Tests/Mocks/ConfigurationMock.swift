@testable import Passwords
import Foundation


enum ConfigurationMock: Configurating {
    
    static var buildNumberString = "0"
    static var shortVersionString = "0.0.0"
    static var appService = "mock"
    static var appGroup = "group.mock"
    static var appKeychain = "team.keychain.mock"
    static var clientName = "Mock"
    static var isDebug = true
    static var isTestEnvironment = true
    static var isTestFlight = false
    static var userDefaults = UserDefaults(suiteName: "mock")!
    static var jsonDecoder = JSONDecoder()
    static var nonUpdatingJsonEncoder = JSONEncoder()
    static var updatingJsonEncoder = JSONEncoder()
    static var propertyListDecoder = PropertyListDecoder()
    static var preferredLanguage: String? = "en"
    
}
