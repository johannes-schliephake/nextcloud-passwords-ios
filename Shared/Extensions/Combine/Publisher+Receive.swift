import Combine
import Factory


extension Publisher {
    
    func receive<S>(on keyPath: KeyPath<Container, Factory<S>>, options: S.SchedulerOptions? = nil) -> some Publisher<Output, Failure> where S: Scheduler {
        receive(on: resolve(keyPath))
    }
    
}
