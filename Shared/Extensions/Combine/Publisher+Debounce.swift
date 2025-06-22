import Combine
import Factory


extension Publisher {
    
    func debounce<S>(for dueTime: S.SchedulerTimeType.Stride, scheduler keyPath: KeyPath<Container, Factory<S>>, options: S.SchedulerOptions? = nil) -> some Publisher<Output, Failure> where S: Scheduler {
        debounce(for: dueTime, scheduler: resolve(keyPath), options: options)
    }
    
}
