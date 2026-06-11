import Combine
import FactoryKit


extension Publisher {
    
    func receive<S>(on keyPath: KeyPath<Container, Factory<S>>, options: S.SchedulerOptions? = nil) -> some Publisher<Output, Failure> where S: Scheduler {
        receive(on: dependency(keyPath))
    }
    
}
