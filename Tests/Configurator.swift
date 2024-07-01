import Foundation
import Nimble


final class Configurator: NSObject {
    
    override init() {
        PollingDefaults.timeout = .milliseconds(100)
    }
    
}
