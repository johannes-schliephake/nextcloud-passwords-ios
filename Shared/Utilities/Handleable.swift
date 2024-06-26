import Combine


protocol Handleable: Stateful, Actionable {}


/// Be careful when using `handle` more than once in a pipeline. You might be creating a setup where a state is publishing changes caused by an action downstream, thus triggering an infintie loop.
///
/// This is an example for an infinite loop caused by chained usage of `handle`:
///
///     Just(())
///         .handle(with: handleable, .doSomething, publishing: \.$value)
///         .handle(with: handleable, { .setValue($0) }, publishing: \.$unimportant)
///         .sink { _ in }
///         .store(in: &cancellables)

extension Publisher {
    
    func handle<Subject: Handleable, Action, State, Output>(with handleable: Subject, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Current<Output, Failure>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handleEvents(receiveOutput: { handleable(action($0)) })
            .replaceOutput(with: handleable[keyPath])
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Failure == Never {
    
    func handle<Subject: Handleable, Action, State, Output, Failure>(with handleable: Subject, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Current<Output, Failure>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handleEvents(receiveOutput: { handleable(action($0)) })
            .setFailureType(to: Failure.self)
            .replaceOutput(with: handleable[keyPath])
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Failure == any Error {
    
    func handle<Subject: Handleable, Action, State, Output, Failure>(with handleable: Subject, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Current<Output, Failure>.Publisher>) -> AnyPublisher<Output, any Error> where Action == Subject.Action, State == Subject.State {
        handleEvents(receiveOutput: { handleable(action($0)) })
            .replaceOutput(with: handleable[keyPath].mapError { $0 as any Error })
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Output == Void {
    
    func handle<Subject: Handleable, Action, State, Output>(with handleable: Subject, _ action: Action, publishing keyPath: KeyPath<State, Current<Output, Failure>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handle(with: handleable, { action }, publishing: keyPath)
    }
    
}


extension Publisher where Output == Void, Failure == Never {
    
    func handle<Subject: Handleable, Action, State, Output, Failure>(with handleable: Subject, _ action: Action, publishing keyPath: KeyPath<State, Current<Output, Failure>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handle(with: handleable, { action }, publishing: keyPath)
    }
    
}


extension Publisher where Output == Void, Failure == any Error {
    
    func handle<Subject: Handleable, Action, State, Output, Failure>(with handleable: Subject, _ action: Action, publishing keyPath: KeyPath<State, Current<Output, Failure>.Publisher>) -> AnyPublisher<Output, any Error> where Action == Subject.Action, State == Subject.State {
        handle(with: handleable, { action }, publishing: keyPath)
    }
    
}
