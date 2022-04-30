import Foundation


final class CertificateSecurityCheck: SecurityCheck {
    
    let id = UUID()
    let severity: SecurityCheckSeverity?
    let issue: Issue?
    let fix: (() async throws -> Void)? = nil
    
    init() throws {
        guard AuthenticationChallengeController.default.isUsingValidCertificate else {
            severity = .medium
            issue = .invalid
            return
        }
        severity = nil
        issue = nil
    }
    
}


extension CertificateSecurityCheck {
    
    enum Issue {
        case invalid
    }
    
}
