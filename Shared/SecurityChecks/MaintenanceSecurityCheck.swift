import SwiftUI


final class MaintenanceSecurityCheck: SecurityCheck {
    
    let id = UUID()
    let severity: SecurityCheckSeverity? = .low
    let fix: (() async throws -> Void)? = {
        guard let session = SessionController.default.session,
              let serverUrl = URL(string: session.server) else {
            throw SecurityCheckError.fixFailed
        }
        let url = serverUrl.appendingPathComponent("index.php/settings/admin/overview")
        UIApplication.safeOpen?(url)
        throw SecurityCheckError.fixIncomplete
    }
    
}
