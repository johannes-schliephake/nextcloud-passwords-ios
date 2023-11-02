import Combine
import LocalAuthentication
import SwiftUI


final class BiometricAuthenticationController: ObservableObject {
    
    var autoFillController: AutoFillController?
    
    @Published private(set) var hideContents = true
    private var isLocked = true
    
    private var subscriptions = Set<AnyCancellable>()
    private let semaphore = DispatchSemaphore(value: 1)
    
    init() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.unlockApp() }
            .store(in: &subscriptions)
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in self?.hideContents = true }
            .store(in: &subscriptions)
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.isLocked = true }
            .store(in: &subscriptions)
    }
    
    private init(isLocked: Bool) {
        self.hideContents = isLocked
        self.isLocked = isLocked
    }
    
    func invalidate() {
        subscriptions.removeAll()
    }
    
    private func unlockApp() {
        DispatchQueue().async { [weak self] in
            guard let self else {
                return
            }
            semaphore.wait()
            
            guard isLocked else {
                DispatchQueue.main.async { [weak self] in
                    self?.hideContents = false
                    self?.semaphore.signal()
                }
                return
            }
            
            let context = LAContext()
            let policy = LAPolicy.deviceOwnerAuthentication
            var error: NSError?
            guard SessionController.default.session != nil,
                  context.canEvaluatePolicy(policy, error: &error) else {
                DispatchQueue.main.async { [weak self] in
                    self?.hideContents = false
                    self?.isLocked = false
                    self?.semaphore.signal()
                }
                return
            }
            
            context.evaluatePolicy(policy, localizedReason: "_unlockApp".localized) { [weak self] success, error in
                guard success else {
                    guard let laError = error as? LAError,
                          laError.code == .userCancel else {
                        self?.semaphore.signal()
                        return
                    }
                    if let cancelAutoFill = self?.autoFillController?.cancel {
                        cancelAutoFill()
                    }
                    else {
                        self?.semaphore.signal()
                        self?.unlockApp()
                    }
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.hideContents = false
                    self?.isLocked = false
                    self?.semaphore.signal()
                }
            }
        }
    }
    
}


extension BiometricAuthenticationController: MockObject {
    
    static var mock: BiometricAuthenticationController {
        BiometricAuthenticationController(isLocked: false)
    }
    
}
