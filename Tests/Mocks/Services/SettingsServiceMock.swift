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
    
}
