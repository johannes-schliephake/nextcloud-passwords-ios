import SwiftUI
import Combine
import Factory


protocol EditTagViewModelProtocol: ViewModel where State == EditTagViewModel.State, Action == EditTagViewModel.Action {
    
    init(tag: Tag)
    
}


final class EditTagViewModel: EditTagViewModelProtocol {
    
    final class State: ObservableObject {
        
        let tag: Tag
        let isCreating: Bool
        @Published var tagLabel: String
        @Published var tagColor: Color
        @Published var tagFavorite: Bool
        @Published var showDeleteAlert: Bool
        @Published var showCancelAlert: Bool
        @Published fileprivate(set) var hasChanges: Bool
        @Published fileprivate(set) var editIsValid: Bool
        @Published var focusedField: FocusField?
        
        let shouldDismiss = Signal()
        
        init(tag: Tag, isCreating: Bool, tagLabel: String, tagColor: Color, tagFavorite: Bool, showDeleteAlert: Bool, showCancelAlert: Bool, hasChanges: Bool, editIsValid: Bool, focusedField: FocusField?) {
            self.tag = tag
            self.isCreating = isCreating
            self.tagLabel = tagLabel
            self.tagColor = tagColor
            self.tagFavorite = tagFavorite
            self.showDeleteAlert = showDeleteAlert
            self.showCancelAlert = showCancelAlert
            self.hasChanges = hasChanges
            self.editIsValid = editIsValid
            self.focusedField = focusedField
        }
        
    }
    
    enum Action {
        case toggleFavorite
        case deleteTag
        case confirmDelete
        case applyToTag
        case cancel
        case discardChanges
        case dismissKeyboard
    }
    
    enum FocusField: Hashable {
        case tagLabel
    }
    
    @Injected(\.tagsService) private var tagsService
    @Injected(\.tagValidationService) private var tagValidationService
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init(tag: Tag) {
        state = .init(tag: tag, isCreating: tag.id.isEmpty, tagLabel: tag.label, tagColor: .init(hex: tag.color) ?? .black, tagFavorite: tag.favorite, showDeleteAlert: false, showCancelAlert: false, hasChanges: false, editIsValid: true, focusedField: tag.id.isEmpty ? .tagLabel : nil)
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        let initialTagColor = Color(hex: state.tag.color)
        
        weak var `self` = self
        
        Publishers.CombineLatest3(
            state.$tagLabel
                .map { $0 != self?.state.tag.label },
            state.$tagColor
                .map { $0 != initialTagColor },
            state.$tagFavorite
                .map { $0 != self?.state.tag.favorite }
        )
        .map { $0 || $1 || $2 }
        .sink { self?.state.hasChanges = $0 }
        .store(in: &cancellables)
        
        state.$tagLabel
            .compactMap { self?.tagValidationService.validate(label: $0) }
            .sink { self?.state.editIsValid = $0 }
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .toggleFavorite:
            state.tagFavorite.toggle()
        case .deleteTag:
            state.showDeleteAlert = true
        case .confirmDelete:
            tagsService.delete(tag: state.tag)
            state.shouldDismiss()
        case .applyToTag:
            do {
                try tagsService.apply(to: state.tag, tagLabel: state.tagLabel, tagColor: state.tagColor, tagFavorite: state.tagFavorite)
            } catch {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
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
