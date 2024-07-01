@testable import Passwords


final class FolderLabelUseCaseMock: FolderLabelUseCaseProtocol, Mock, PropertyAccessLogging, FunctionCallLogging {
    
    let state = FolderLabelUseCase.State()
    
    func callAsFunction(_ action: Action) {
        switch action {
        case let .setId(id):
            logFunctionCall(of: action, parameters: id)
        }
    }
    
}
