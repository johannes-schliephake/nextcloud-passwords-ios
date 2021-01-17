import Combine
import LocalAuthentication
import SwiftUI


final class BiometricAuthenticationController: ObservableObject {
    
    @Published private(set) var isUnlocked = false {
        didSet {
            if isUnlocked {
                unlockDate = Date()
            }
        }
    }
    
    private var unlockDate: Date?
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        if !UIApplication.isExtension {
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink(receiveValue: unlockApp).store(in: &subscriptions)
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).sink(receiveValue: lockApp).store(in: &subscriptions)
        }
        unlockApp()
    }
    
    private init(isUnlocked: Bool) {
        self.isUnlocked = isUnlocked
    }
    
    private func unlockApp(_: Notification? = nil) {
        guard !isUnlocked else {
            return
        }
        
        let context = LAContext()
        let policy = LAPolicy.deviceOwnerAuthentication
        var error: NSError?
        guard CredentialsController.default.credentials != nil,
              context.canEvaluatePolicy(policy, error: &error) else {
            isUnlocked = true
            return
        }
        
        context.evaluatePolicy(policy, localizedReason: "_unlockApp".localized) {
            [weak self] success, error in
            guard success else {
                if let laError = error as? LAError,
                   laError.code == .userCancel {
                    self?.unlockApp()
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.isUnlocked = true
            }
        }
    }
    
    private func lockApp(_: Notification) {
        if let timeSinceUnlock = unlockDate?.distance(to: Date()) {
            if timeSinceUnlock < 0.5 {
                return
            }
        }
        isUnlocked = false
    }
    
}


extension BiometricAuthenticationController: MockObject {
    
    static var mock: BiometricAuthenticationController {
        BiometricAuthenticationController(isUnlocked: true)
    }
    
}
