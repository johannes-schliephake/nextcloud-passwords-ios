import Combine


protocol Handleable: Stateful, Actionable {}


extension Handleable {
    
    subscript<Output, Failure>(_ keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> {
        state[keyPath: keyPath]
            .compactFlatMap { $0?.publisher }
            .eraseToAnyPublisher()
    }
    
}


extension Publisher {
    
    func handle<Subject: Handleable, Action, State, Output>(with handleable: Subject, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Published<Output>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handleEvents(receiveOutput: { handleable(action($0)) })
            .replaceOutput(with: handleable[keyPath].setFailureType(to: Failure.self))
            .eraseToAnyPublisher()
    }
    
    func handle<Subject: Handleable, Action, State, Output>(with handleable: Subject, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handleEvents(receiveOutput: { handleable(action($0)) })
            .replaceOutput(with: handleable[keyPath])
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Failure == Never {
    
    func handle<Subject: Handleable, Action, State, Output, Failure>(with handleable: Subject, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handleEvents(receiveOutput: { handleable(action($0)) })
            .setFailureType(to: Failure.self)
            .replaceOutput(with: handleable[keyPath])
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Failure == any Error {
    
    func handle<Subject: Handleable, Action, State, Output, Failure>(with handleable: Subject, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, any Error> where Action == Subject.Action, State == Subject.State {
        handleEvents(receiveOutput: { handleable(action($0)) })
            .replaceOutput(with: handleable[keyPath].mapError { $0 as any Error })
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Output == Void {
    
    func handle<Subject: Handleable, Action, State, Output>(with handleable: Subject, _ action: Action, publishing keyPath: KeyPath<State, Published<Output>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handle(with: handleable, { action }, publishing: keyPath)
    }
    
    
    func handle<Subject: Handleable, Action, State, Output>(with handleable: Subject, _ action: Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handle(with: handleable, { action }, publishing: keyPath)
    }
    
}


extension Publisher where Output == Void, Failure == Never {
    
    func handle<Subject: Handleable, Action, State, Output, Failure>(with handleable: Subject, _ action: Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> where Action == Subject.Action, State == Subject.State {
        handle(with: handleable, { action }, publishing: keyPath)
    }
    
}


extension Publisher where Output == Void, Failure == any Error {
    
    func handle<Subject: Handleable, Action, State, Output, Failure>(with handleable: Subject, _ action: Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, any Error> where Action == Subject.Action, State == Subject.State {
        handle(with: handleable, { action }, publishing: keyPath)
    }
    
}
