import SwiftUI


@available(iOS 15, *)
final class AppVersionSecurityCheck: SecurityCheck {
    
    let id = UUID()
    let severity: SecurityCheckSeverity?
    let issue: Issue?
    let fix: (() async throws -> Void)?
    
    init() async throws {
        #if DEBUG
        let bundleId = Configuration.appService.replacingOccurrences(of: "-debug", with: "")
        #else
        let bundleId = Configuration.appService
        #endif
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            throw SecurityCheckError.checkFailed
        }
        let (data, _) = try await NetworkClient.default.data(from: url)
        let response = try Configuration.jsonDecoder.decode(Response.self, from: data)
        guard let result = response.results.first else {
            throw SecurityCheckError.checkFailed
        }
        guard result.version.compare(Configuration.shortVersionString, options: .numeric) != .orderedDescending else {
            severity = .medium
            issue = .appOutdated
            if UIApplication.safeShared != nil {
                fix = {
                    guard let url = URL(string: "https://apps.apple.com/app/id1546212226") else {
                        throw SecurityCheckError.fixFailed
                    }
                    UIApplication.safeOpen?(url)
                    throw SecurityCheckError.fixIncomplete
                }
            }
            else {
                fix = nil
            }
            return
        }
        guard await result.minimumOsVersion.compare(UIDevice.current.systemVersion, options: .numeric) != .orderedDescending else {
            severity = .medium
            issue = .osOutdated
            fix = nil
            return
        }
        severity = nil
        issue = nil
        fix = nil
    }
    
}


@available(iOS 15, *)
extension AppVersionSecurityCheck {
    
    enum Issue {
        case appOutdated
        case osOutdated
    }
    
}


@available(iOS 15, *)
extension AppVersionSecurityCheck {
    
    struct Response: Decodable {
        
        let results: [Result]
        
    }
    
    struct Result: Decodable {
        
        let version: String
        let minimumOsVersion: String
        
    }
    
}
