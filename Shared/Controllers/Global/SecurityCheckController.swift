import Foundation


final class SecurityCheckController: ObservableObject {
    
    static let `default` = SecurityCheckController()
    
    @Published private(set) var state: State = .notRun
    @Published private(set) var securityChecks: [SecurityCheck]?
    
    @available(iOS 15, *)
    func runSecurityCheck() {
        state = .running
        Task {
            [weak self] in
            do {
                let securityChecks = try await [
                    AppVersionSecurityCheck() as SecurityCheck,
                    CertificateSecurityCheck() as SecurityCheck
                ]
                await MainActor.run {
                    [self] in
                    self?.securityChecks = securityChecks
                    self?.state = .resultsAvailable
                }
            }
            catch {
                await MainActor.run {
                    [self] in
                    self?.state = .failed
                }
            }
        }
    }
    
    func ignore(securityCheck: SecurityCheck) {
        securityChecks?.removeAll { $0.id == securityCheck.id }
    }
    
    func clear() {
        state = .notRun
        securityChecks = nil
    }
    
}


extension SecurityCheckController {
    
    enum State {
        case notRun
        case running
        case failed
        case resultsAvailable
    }
    
}


extension SecurityCheckController: MockObject {
    
    static var mock: SecurityCheckController {
        SecurityCheckController()
    }
    
}
