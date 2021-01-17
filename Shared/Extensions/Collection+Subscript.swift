import Foundation


extension Collection {
    
    subscript(safe index: Index?) -> Element? {
        guard let index = index,
              indices.contains(index) else {
            return nil
        }
        return self[index]
    }
    
}
