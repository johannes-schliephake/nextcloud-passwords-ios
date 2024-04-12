import Foundation
import Combine
import Factory


protocol EditFolderViewModelProtocol: ViewModel where State == EditFolderViewModel.State, Action == EditFolderViewModel.Action {
    
    init(folder: Folder, didEdit: ((Folder) -> Void)?)
    
}


final class EditFolderViewModel: EditFolderViewModelProtocol {
    
    final class State: ObservableObject {
        
        let folder: Folder
        let isCreating: Bool
        @Published var folderLabel: String
        @Published fileprivate(set) var folderFavorite: Bool
        @Published fileprivate(set) var folderParent: String
        @Published fileprivate(set) var parentLabel: String
        @Published var showSelectFolderView: Bool
        @Published var showDeleteAlert: Bool
        @Published var showCancelAlert: Bool
        @Published fileprivate(set) var hasChanges: Bool
        @Published fileprivate(set) var editIsValid: Bool
        @Published var focusedField: FocusField?
        
        let shouldDismiss = Signal()
        
        init(folder: Folder, isCreating: Bool, folderLabel: String, folderFavorite: Bool, folderParent: String, parentLabel: String, showSelectFolderView: Bool, showDeleteAlert: Bool, showCancelAlert: Bool, hasChanges: Bool, editIsValid: Bool, focusedField: FocusField?) {
            self.folder = folder
            self.isCreating = isCreating
            self.folderLabel = folderLabel
            self.folderFavorite = folderFavorite
            self.folderParent = folderParent
            self.parentLabel = parentLabel
            self.showSelectFolderView = showSelectFolderView
            self.showDeleteAlert = showDeleteAlert
            self.showCancelAlert = showCancelAlert
            self.hasChanges = hasChanges
            self.editIsValid = editIsValid
            self.focusedField = focusedField
        }
        
    }
    
    enum Action {
        case toggleFavorite
        case showParentSelection
        case selectParent(Folder)
        case deleteFolder
        case confirmDelete
        case applyToFolder
        case cancel
        case discardChanges
        case dismissKeyboard
    }
    
    enum FocusField: Hashable {
        case folderLabel
    }
    
    @Injected(\.folderLabelUseCase) private var folderLabelUseCase
    @Injected(\.foldersService) private var foldersService
    @Injected(\.folderValidationService) private var folderValidationService
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private let didEdit: ((Folder) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    init(folder: Folder, didEdit: ((Folder) -> Void)?) {
        state = .init(folder: folder, isCreating: folder.id.isEmpty, folderLabel: folder.label, folderFavorite: folder.favorite, folderParent: folder.parent ?? "", parentLabel: "", showSelectFolderView: false, showDeleteAlert: false, showCancelAlert: false, hasChanges: false, editIsValid: true, focusedField: folder.id.isEmpty ? .folderLabel : nil)
        self.didEdit = didEdit
        
        if folder.isBaseFolder {
            logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
        } else if folder.parent == nil {
            logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
        }
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        state.$folderParent
            .handle(with: folderLabelUseCase, { .setId($0) }, publishing: \.$label)
            .sink { self?.state.parentLabel = $0 }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            state.$folderLabel
                .map { $0 != self?.state.folder.label },
            state.$folderFavorite
                .map { $0 != self?.state.folder.favorite },
            state.$folderParent
                .map { $0 != self?.state.folder.parent }
        )
        .map { $0 || $1 || $2 }
        .sink { self?.state.hasChanges = $0 }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            state.$folderLabel,
            state.$folderParent
        )
        .compactMap { self?.folderValidationService.validate(label: $0, parent: $1) }
        .sink { self?.state.editIsValid = $0 }
        .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .toggleFavorite:
            state.folderFavorite.toggle()
        case .showParentSelection:
            state.showSelectFolderView = true
        case let .selectParent(parent):
            state.folderParent = parent.id
        case .deleteFolder:
            state.showDeleteAlert = true
        case .confirmDelete:
            foldersService.delete(folder: state.folder)
            state.shouldDismiss()
        case .applyToFolder:
            do {
                try foldersService.apply(to: state.folder, folderLabel: state.folderLabel, folderFavorite: state.folderFavorite, folderParent: state.folderParent)
            } catch {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            didEdit?(state.folder)
            state.shouldDismiss()
        case .cancel:
            if state.hasChanges {
                state.showCancelAlert = true
            } else {
                state.shouldDismiss()
            }
        case .discardChanges:
            state.shouldDismiss()
        case .dismissKeyboard:
            state.focusedField = nil
        }
    }
    
}
