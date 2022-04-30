import Foundation


final class HashSettingSecurityCheck: SecurityCheck {
    
    let id = UUID()
    let severity: SecurityCheckSeverity?
    let issue: Issue?
    let fix: (() async throws -> Void)?
    
    init() throws {
        let settingsController = SettingsController.default
        guard settingsController.settingsAreAvailable else {
            throw SecurityCheckError.checkFailed
        }
        guard settingsController.userPasswordSecurityHash <= 20 else {
            severity = .high
            issue = .tooHigh
            fix = {
                settingsController.userPasswordSecurityHash = 20
            }
            return
        }
        guard settingsController.userPasswordSecurityHash == 20 else {
            severity = .medium
            issue = .tooLow
            fix = {
                settingsController.userPasswordSecurityHash = 20
            }
            return
        }
        severity = nil
        issue = nil
        fix = nil
    }
    
}


extension HashSettingSecurityCheck {
    
    enum Issue {
        case tooHigh
        case tooLow
    }
    
}
