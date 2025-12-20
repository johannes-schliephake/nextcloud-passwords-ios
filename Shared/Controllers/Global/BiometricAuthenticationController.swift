import Combine
import LocalAuthentication
import SwiftUI
import Factory


final class BiometricAuthenticationController: ObservableObject {
    
    @LazyInjected(\.autoFillController) private var autoFillController
    @LazyInjected(\.sessionController) private var sessionController
    
    private let isLockedSubject = CurrentValueSubject<Bool, Never>(true)
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        weak let `self` = self
        
        NotificationCenter.default.publisher(for: UIScene.didActivateNotification)
            .ignoreValue()
            .flatMap(maxPublishers: .max(1)) {
                Bridge { @MainActor [weak self] in
                    if self?.isLockedSubject.value == false {
                        true
                    } else {
                        await self?.verifyDeviceOwner() ?? false
                    }
                }
            }
            .filter { $0 }
            .ignoreValue()
            .receive(on: DispatchQueue.main)
            .sink { self?.isLockedSubject.send(false) }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)
            .ignoreValue()
            .sink { self?.isLockedSubject.send(true) }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            NotificationCenter.default.publisher(for: UIScene.willConnectNotification)
                .compactMap { $0.object as? UIWindowScene }
                .first(),
            Publishers.Merge(
                NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification)
                    .map { _ in (true, true) },
                isLockedSubject
                    .map { ($0, !$0) }
            )
        )
        .sink { $0.blur(enabled: $1.0, animated: $1.1) }
        .store(in: &cancellables)
    }
    
    private init(isLocked: Bool) {
        isLockedSubject.send(isLocked)
    }
    
    private func verifyDeviceOwner() async -> Bool {
        let context = LAContext()
        let policy = LAPolicy.deviceOwnerAuthentication
        
        guard sessionController.session != nil,
              context.canEvaluatePolicy(policy, error: nil) else {
            return true
        }
        
        do {
            return try await context.evaluatePolicy(policy, localizedReason: Strings.unlockApp)
        } catch {
            guard (error as? LAError)?.code == .userCancel else {
                return false
            }
            if let cancelAutoFill = autoFillController.cancel {
                cancelAutoFill()
                return false
            } else {
                return await verifyDeviceOwner()
            }
        }
    }
    
}


extension BiometricAuthenticationController: MockObject {
    
    static var mock: BiometricAuthenticationController {
        BiometricAuthenticationController(isLocked: false)
    }
    
}


private extension UIWindowScene {
    
    private static let blurTag = -2398416497534319401
    
    func blur(enabled: Bool, animated: Bool) {
        windows.forEach { window in
            if let blur = window.viewWithTag(Self.blurTag) {
                switch (enabled, animated) {
                case (true, true):
                    blur.isHidden = false
                    UIView.animate(withDuration: 0.2) {
                        blur.alpha = 1
                    }
                case (false, true):
                    UIView.animate(withDuration: 0.2) {
                        blur.alpha = 0
                    } completion: { _ in
                        blur.isHidden = true
                    }
                case (_, false):
                    blur.isHidden = !enabled
                    blur.alpha = enabled ? 1 : 0
                }
            } else if enabled {
                let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                blur.tag = Self.blurTag
                blur.layer.zPosition = .init(Float.greatestFiniteMagnitude)
                window.addSubview(blur)
                if let rootView = window.rootViewController?.view {
                    blur.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        blur.topAnchor.constraint(equalTo: rootView.topAnchor),
                        blur.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
                        blur.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
                        blur.trailingAnchor.constraint(equalTo: rootView.trailingAnchor)
                    ])
                } else {
                    resolve(\.logger).log(error: "Unable to find a root view controller to constrain the blur view to, falling back to frame-based method")
                    blur.frame = window.frame
                }
            }
        }
    }
    
}
