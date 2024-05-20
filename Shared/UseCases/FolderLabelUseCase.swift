import Combine
import Factory


protocol FolderLabelUseCaseProtocol: UseCase where State == FolderLabelUseCase.State, Action == FolderLabelUseCase.Action {}


// TODO: replace temporary implementation
final class FolderLabelUseCase: FolderLabelUseCaseProtocol {
    
    final class State {
        
        @Published fileprivate(set) var label: Result<String, Never>?
        
    }
    
    enum Action {
        case setId(String)
    }
    
    @Injected(\.foldersService) private var foldersService
    
    let state: State
    
    private let idSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        state = .init()
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        idSubject
            .compactFlatMapLatest { id in
                self?.foldersService.folders
                    .map { $0.first { $0.id == id } }
            }
            .map(\.?.label)
            .replaceNil(with: "_rootFolder".localized)
            .sink { self?.state.label = .success($0) }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setId(id):
            idSubject.send(id)
        }
    }
    
}
