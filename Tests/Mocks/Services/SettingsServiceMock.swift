@testable import Passwords
import Combine


final class SettingsServiceMock: SettingsServiceProtocol, Mock, PropertyAccessLogging {
    
    var _isOfflineStorageEnabled = true // swiftlint:disable:this identifier_name
    var isOfflineStorageEnabled: Bool {
        get {
            logPropertyAccess()
            return _isOfflineStorageEnabled
        }
        set {
            logPropertyAccess()
            _isOfflineStorageEnabled = newValue
        }
    }
    
    let _isOfflineStorageEnabledPublisher = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isOfflineStorageEnabledPublisher: AnyPublisher<Bool, Never> {
        logPropertyAccess()
        return _isOfflineStorageEnabledPublisher.eraseToAnyPublisher()
    }
    
    var _isOnDevicePasswordGeneratorEnabled = true // swiftlint:disable:this identifier_name
    var isOnDevicePasswordGeneratorEnabled: Bool {
        get {
            logPropertyAccess()
            return _isOnDevicePasswordGeneratorEnabled
        }
        set {
            logPropertyAccess()
            _isOnDevicePasswordGeneratorEnabled = newValue
        }
    }
    
    let _isOnDevicePasswordGeneratorEnabledPublisher = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isOnDevicePasswordGeneratorEnabledPublisher: AnyPublisher<Bool, Never> { // swiftlint:disable:this identifier_name
        logPropertyAccess()
        return _isOnDevicePasswordGeneratorEnabledPublisher.eraseToAnyPublisher()
    }
    
    var _isAutomaticPasswordGenerationEnabled = true // swiftlint:disable:this identifier_name
    var isAutomaticPasswordGenerationEnabled: Bool {
        get {
            logPropertyAccess()
            return _isAutomaticPasswordGenerationEnabled
        }
        set {
            logPropertyAccess()
            _isAutomaticPasswordGenerationEnabled = newValue
        }
    }
    
    let _isAutomaticPasswordGenerationEnabledPublisher = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isAutomaticPasswordGenerationEnabledPublisher: AnyPublisher<Bool, Never> { // swiftlint:disable:this identifier_name
        logPropertyAccess()
        return _isAutomaticPasswordGenerationEnabledPublisher.eraseToAnyPublisher()
    }
    
    var _isUniversalClipboardEnabled = true // swiftlint:disable:this identifier_name
    var isUniversalClipboardEnabled: Bool {
        get {
            logPropertyAccess()
            return _isUniversalClipboardEnabled
        }
        set {
            logPropertyAccess()
            _isUniversalClipboardEnabled = newValue
        }
    }
    
    let _isUniversalClipboardEnabledPublisher = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isUniversalClipboardEnabledPublisher: AnyPublisher<Bool, Never> {
        logPropertyAccess()
        return _isUniversalClipboardEnabledPublisher.eraseToAnyPublisher()
    }
    
}
