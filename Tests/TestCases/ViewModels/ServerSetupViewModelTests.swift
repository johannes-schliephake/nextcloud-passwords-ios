import XCTest
import Nimble
import Factory
@testable import Passwords


final class ServerSetupViewModelTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.reset()
    }
    
}
