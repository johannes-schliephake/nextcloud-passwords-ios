import Foundation


extension Collection where Element == Double {
    
    func avg() -> Double? {
        guard !isEmpty else {
            return nil
        }
        return reduce(.zero, +) / Double(count)
    }
    
}
