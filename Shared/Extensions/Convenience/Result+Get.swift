import Foundation


extension Result where Failure == Never {
    
    func get() -> Success {
        try! (get as () throws -> Success)() // swiftlint:disable:this force_try
    }
    
}
