import Foundation
import Combine
import Factory


protocol LogViewModelProtocol: ViewModel where State == LogViewModel.State, Action == LogViewModel.Action {
    
    init()
    
}


final class LogViewModel: LogViewModelProtocol {
    
    final class State: ObservableObject {
        
        @Published fileprivate(set) var isAvailable: Bool
        @Published fileprivate(set) var events: [LogEvent]
        
        init(isAvailable: Bool, events: [LogEvent]) {
            self.isAvailable = isAvailable
            self.events = events
        }
        
    }
    
    enum Action {
        case copyLog
        case copyEvent(LogEvent)
    }
    
    @Injected(\.logger) private var logger
    @LazyInjected(\.pasteboardService) private var pasteboardService
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init(isAvailable: true, events: [])
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        logger.isAvailablePublisher
            .receive(on: DispatchQueue.main)
            .sink { self?.state.isAvailable = $0 }
            .store(in: &cancellables)
        
        logger.eventsPublisher
            .map { $0?.reversed() }
            .replaceNil(with: [])
            .receive(on: DispatchQueue.main)
            .sink { self?.state.events = $0 }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .copyLog:
            guard logger.isAvailable,
                  let events = logger.events else {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            let logString = events
                .map(String.init)
                .joined(separator: "\n")
            pasteboardService.set(string: logString, sensitive: false)
        case let .copyEvent(event):
            let eventString = String(describing: event)
            pasteboardService.set(string: eventString, sensitive: false)
        }
    }
    
}
