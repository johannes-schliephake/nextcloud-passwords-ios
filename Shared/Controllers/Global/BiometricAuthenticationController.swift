import Combine
import LocalAuthentication
import SwiftUI


final class BiometricAuthenticationController: ObservableObject {
    
    var autoFillController: AutoFillController?
    
    @Published private(set) var isUnlocked = false
    
    private var subscriptions = Set<AnyCancellable>()
    private let semaphore = DispatchSemaphore(value: 1)
    
    init() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink(receiveValue: unlockApp).store(in: &subscriptions)
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).sink(receiveValue: lockApp).store(in: &subscriptions)
    }
    
    private init(isUnlocked: Bool) {
        self.isUnlocked = isUnlocked
    }
    
    private func unlockApp(_: Notification? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            [self] in
            semaphore.wait()
            
            guard !isUnlocked else {
                semaphore.signal()
                return
            }
            
            let context = LAContext()
            let policy = LAPolicy.deviceOwnerAuthentication
            var error: NSError?
            guard CredentialsController.default.credentials != nil,
                  context.canEvaluatePolicy(policy, error: &error) else {
                DispatchQueue.main.async {
                    isUnlocked = true
                    semaphore.signal()
                }
                return
            }
            
            context.evaluatePolicy(policy, localizedReason: "_unlockApp".localized) {
                [weak self] success, error in
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
                
                DispatchQueue.main.async {
                    self?.isUnlocked = true
                    self?.semaphore.signal()
                }
            }
        }
    }
    
    private func lockApp(_: Notification) {
        isUnlocked = false
    }
    
    func invalidate() {
        subscriptions.removeAll()
    }
    
}


extension BiometricAuthenticationController: MockObject {
    
    static var mock: BiometricAuthenticationController {
        BiometricAuthenticationController(isUnlocked: true)
    }
    
}
