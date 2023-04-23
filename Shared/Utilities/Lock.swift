import Foundation


struct Lock {
    
    private let lock = NSLock()
    
    func callAsFunction<Result>(_ block: () -> Result) -> Result {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }
    
}
