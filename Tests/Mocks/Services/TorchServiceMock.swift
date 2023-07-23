@testable import Passwords
import Combine


final class TorchServiceMock: TorchServiceProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let _isTorchAvailable = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isTorchAvailable: AnyPublisher<Bool, Never> {
        logPropertyAccess()
        return _isTorchAvailable.eraseToAnyPublisher()
    }
    
    let _isTorchActive = PassthroughSubject<Bool, Never>() // swiftlint:disable:this identifier_name
    var isTorchActive: AnyPublisher<Bool, Never> {
        logPropertyAccess()
        return _isTorchActive.eraseToAnyPublisher()
    }
    
    var _toggleTorch: Result<Void, TorchError> = .success(()) // swiftlint:disable:this identifier_name
    func toggleTorch() throws {
        logFunctionCall()
        try _toggleTorch.get()
    }
    
}
