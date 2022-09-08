import Foundation


extension Array {
    
    @inlinable func zip<T>(with array: [T]) -> [(Element, T)] {
        Swift.zip(self, array)
            .map { ($0.0, $0.1) }
    }
    
}
