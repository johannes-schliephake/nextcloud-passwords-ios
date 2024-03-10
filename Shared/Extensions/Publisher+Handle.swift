import Combine


extension Publisher {
    
    func handle<HandleableUseCase: UseCase, Action, State, Output>(with useCase: HandleableUseCase, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Published<Output>.Publisher>) -> AnyPublisher<Output, Failure> where Action == HandleableUseCase.Action, State == HandleableUseCase.State {
        handleEvents(receiveOutput: { useCase(action($0)) })
            .replaceOutput(with: useCase[keyPath].setFailureType(to: Failure.self))
            .eraseToAnyPublisher()
    }
    
    func handle<HandleableUseCase: UseCase, Action, State, Output>(with useCase: HandleableUseCase, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> where Action == HandleableUseCase.Action, State == HandleableUseCase.State {
        handleEvents(receiveOutput: { useCase(action($0)) })
            .replaceOutput(with: useCase[keyPath])
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Failure == Never {
    
    func handle<HandleableUseCase: UseCase, Action, State, Output, Failure>(with useCase: HandleableUseCase, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> where Action == HandleableUseCase.Action, State == HandleableUseCase.State {
        handleEvents(receiveOutput: { useCase(action($0)) })
            .setFailureType(to: Failure.self)
            .replaceOutput(with: useCase[keyPath])
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Failure == any Error {
    
    func handle<HandleableUseCase: UseCase, Action, State, Output, Failure>(with useCase: HandleableUseCase, _ action: @escaping (Self.Output) -> Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, any Error> where Action == HandleableUseCase.Action, State == HandleableUseCase.State {
        handleEvents(receiveOutput: { useCase(action($0)) })
            .replaceOutput(with: useCase[keyPath].mapError { $0 as any Error })
            .eraseToAnyPublisher()
    }
    
}


extension Publisher where Output == Void {
    
    func handle<HandleableUseCase: UseCase, Action, State, Output>(with useCase: HandleableUseCase, _ action: Action, publishing keyPath: KeyPath<State, Published<Output>.Publisher>) -> AnyPublisher<Output, Failure> where Action == HandleableUseCase.Action, State == HandleableUseCase.State {
        handle(with: useCase, { action }, publishing: keyPath)
    }
    
    
    func handle<HandleableUseCase: UseCase, Action, State, Output>(with useCase: HandleableUseCase, _ action: Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> where Action == HandleableUseCase.Action, State == HandleableUseCase.State {
        handle(with: useCase, { action }, publishing: keyPath)
    }
    
}


extension Publisher where Output == Void, Failure == Never {
    
    func handle<HandleableUseCase: UseCase, Action, State, Output, Failure>(with useCase: HandleableUseCase, _ action: Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, Failure> where Action == HandleableUseCase.Action, State == HandleableUseCase.State {
        handle(with: useCase, { action }, publishing: keyPath)
    }
    
}


extension Publisher where Output == Void, Failure == any Error {
    
    func handle<HandleableUseCase: UseCase, Action, State, Output, Failure>(with useCase: HandleableUseCase, _ action: Action, publishing keyPath: KeyPath<State, Published<Result<Output, Failure>?>.Publisher>) -> AnyPublisher<Output, any Error> where Action == HandleableUseCase.Action, State == HandleableUseCase.State {
        handle(with: useCase, { action }, publishing: keyPath)
    }
    
}
