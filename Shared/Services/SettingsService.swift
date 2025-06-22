import Combine
import Factory


protocol SettingsServiceProtocol {
    
    var isOfflineStorageEnabled: Bool { get set }
    var isOfflineStorageEnabledPublisher: AnyPublisher<Bool, Never> { get }
    var isOnDevicePasswordGeneratorEnabled: Bool { get set }
    var isOnDevicePasswordGeneratorEnabledPublisher: AnyPublisher<Bool, Never> { get } // swiftlint:disable:this identifier_name
    var isAutomaticPasswordGenerationEnabled: Bool { get set }
    var isAutomaticPasswordGenerationEnabledPublisher: AnyPublisher<Bool, Never> { get } // swiftlint:disable:this identifier_name
    var isUniversalClipboardEnabled: Bool { get set }
    var isUniversalClipboardEnabledPublisher: AnyPublisher<Bool, Never> { get }
    
}


// TODO: replace temporary implementation
final class SettingsService: SettingsServiceProtocol {
    
    @LazyInjected(\.entriesController) private var entriesController
    
    var isOfflineStorageEnabled: Bool {
        get {
            isOfflineStorageEnabledInternal
        }
        set {
            isOfflineStorageEnabledInternal = newValue
            resolve(\.configurationType).userDefaults.set(newValue, forKey: "storeOffline")
            
            if !newValue {
                Crypto.AES256.removeKey(named: "offlineKey")
            }
            entriesController.updateOfflineContainers()
            entriesController.updateAutoFillCredentials()
        }
    }
    var isOfflineStorageEnabledPublisher: AnyPublisher<Bool, Never> {
        $isOfflineStorageEnabledInternal
            .eraseToAnyPublisher()
    }
    var isOnDevicePasswordGeneratorEnabled: Bool {
        get {
            isOnDevicePasswordGeneratorEnabledInternal
        }
        set {
            isOnDevicePasswordGeneratorEnabledInternal = newValue
            resolve(\.configurationType).userDefaults.set(newValue, forKey: "onDeviceGenerator")
        }
    }
    var isOnDevicePasswordGeneratorEnabledPublisher: AnyPublisher<Bool, Never> { // swiftlint:disable:this identifier_name
        $isOnDevicePasswordGeneratorEnabledInternal
            .eraseToAnyPublisher()
    }
    var isAutomaticPasswordGenerationEnabled: Bool {
        get {
            isAutomaticPasswordGenerationEnabledInternal
        }
        set {
            isAutomaticPasswordGenerationEnabledInternal = newValue
            resolve(\.configurationType).userDefaults.set(newValue, forKey: "automaticallyGeneratePasswords")
        }
    }
    var isAutomaticPasswordGenerationEnabledPublisher: AnyPublisher<Bool, Never> { // swiftlint:disable:this identifier_name
        $isAutomaticPasswordGenerationEnabledInternal
            .eraseToAnyPublisher()
    }
    var isUniversalClipboardEnabled: Bool {
        get {
            isUniversalClipboardEnabledInternal
        }
        set {
            isUniversalClipboardEnabledInternal = newValue
            resolve(\.configurationType).userDefaults.set(newValue, forKey: "universalClipboard")
        }
    }
    var isUniversalClipboardEnabledPublisher: AnyPublisher<Bool, Never> {
        $isUniversalClipboardEnabledInternal
            .eraseToAnyPublisher()
    }
    
    @Published private var isOfflineStorageEnabledInternal = resolve(\.configurationType).userDefaults.bool(forKey: "storeOffline")
    @Published private var isOnDevicePasswordGeneratorEnabledInternal = resolve(\.configurationType).userDefaults.bool(forKey: "onDeviceGenerator") // swiftlint:disable:this identifier_name
    @Published private var isAutomaticPasswordGenerationEnabledInternal = resolve(\.configurationType).userDefaults.bool(forKey: "automaticallyGeneratePasswords") // swiftlint:disable:this identifier_name
    @Published private var isUniversalClipboardEnabledInternal = resolve(\.configurationType).userDefaults.bool(forKey: "universalClipboard")

}
