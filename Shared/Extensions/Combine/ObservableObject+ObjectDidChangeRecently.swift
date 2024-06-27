import Foundation
import Combine


extension ObservableObject {
    
    var objectDidChangeRecently: AnyPublisher<ObjectWillChangePublisher.Output, ObjectWillChangePublisher.Failure> {
        objectWillChange
            .debounce(for: 0.01, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}
