import Foundation
import Combine
import Factory


protocol SelectTagsViewModelProtocol: ViewModel where State == SelectTagsViewModel.State, Action == SelectTagsViewModel.Action {
    
    init(temporaryEntry: SelectTagsViewModel.TemporaryEntry, selectTags: @escaping ([Tag], [String]) -> Void)
    
}


final class SelectTagsViewModel: SelectTagsViewModelProtocol {
    
    final class State: ObservableObject {
        
        let temporaryEntry: TemporaryEntry
        @Published var tagLabel: String
        @Published fileprivate(set) var selectableTags: [(tag: Tag, isSelected: Bool)]
        @Published fileprivate(set) var hasChanges: Bool
        @Published var focusedField: FocusField?
        
        let shouldDismiss = PassthroughSubject<Void, Never>()
        
        init(temporaryEntry: TemporaryEntry, tagLabel: String, selectableTags: [(tag: Tag, isSelected: Bool)], hasChanges: Bool, focusedField: FocusField?) {
            self.temporaryEntry = temporaryEntry
            self.tagLabel = tagLabel
            self.selectableTags = selectableTags
            self.hasChanges = hasChanges
            self.focusedField = focusedField
        }
        
    }
    
    enum Action {
        case addTag
        case toggleTag(Tag)
        case selectTags
        case cancel
        case dismissKeyboard
    }
    
    enum TemporaryEntry {
        
        case password(label: String, username: String, url: String, tags: [String])
        
        var tags: [String] {
            switch self {
            case .password(_, _, _, let tags):
                return tags
            }
        }
        
    }
    
    enum FocusField: Hashable {
        case addTagLabel
    }
    
    @Injected(\.tagsService) private var tagsService
    @LazyInjected(\.logger) private var logger
    
    let state: State
    
    private let selectTags: ([Tag], [String]) -> Void
    private var invalidTags: [String]
    private var cancellables = Set<AnyCancellable>()
    
    init(temporaryEntry: TemporaryEntry, selectTags: @escaping ([Tag], [String]) -> Void) {
        state = .init(temporaryEntry: temporaryEntry, tagLabel: "", selectableTags: [], hasChanges: false, focusedField: nil)
        self.selectTags = selectTags
        invalidTags = []
        
        setupPipelines()
    }
    
    private func setupPipelines() {
        weak var `self` = self
        
        let selectionPublisher = tagsService.tags(for: state.temporaryEntry.tags)
            .map { ($0, self?.state.hasChanges ?? false) }
            .share()
            .makeConnectable()
        
        Publishers.Zip(
            tagsService.tags,
            selectionPublisher
                .map { selection, hasChanges in
                    if let self,
                       hasChanges {
                        return (valid: self.state.selectableTags.filter(\.isSelected).map(\.tag), invalid: self.invalidTags)
                    }
                    return selection
                }
        )
        .map { tags, selection in
            let selectableTags = tags.sorted().map { (tag: $0, isSelected: selection.valid.contains($0)) }
            return (selectableTags, selection.invalid)
        }
        .sink { selectableTags, invalidTags in
            self?.state.selectableTags = selectableTags
            self?.invalidTags = invalidTags
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            state.$selectableTags
                .dropFirst()
                .compactMap { $0.filter(\.isSelected).map(\.tag) }
                .map(Set.init),
            selectionPublisher
                .map(\.0.valid)
                .map(Set.init)
        )
        .map { $0 != $1 }
        .sink { self?.state.hasChanges = $0 }
        .store(in: &cancellables)
        
        selectionPublisher
            .connect()
            .store(in: &cancellables)
    }
    
    func callAsFunction(_ action: Action) {
        switch action {
        case .addTag:
            let tag: Tag
            do {
                tag = try tagsService.addTag(label: state.tagLabel)
            } catch {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            state.tagLabel = ""
            self(.toggleTag(tag)) // TODO: expects new tag to already be emitted by tags service
        case let .toggleTag(tag):
            guard let index = state.selectableTags.firstIndex(where: { $0.tag == tag }) else {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            state.selectableTags[index].isSelected.toggle()
        case .selectTags:
            let selectedTags = state.selectableTags.filter(\.isSelected).map(\.tag)
            guard state.hasChanges,
                  tagsService.allIdsLocallyAvailable(of: selectedTags) else {
                logger.log(error: "View-ViewModel inconsistency encountered, this case shouldn't be reachable")
                return
            }
            selectTags(selectedTags, invalidTags)
            state.shouldDismiss.send()
        case .cancel:
            state.shouldDismiss.send()
        case .dismissKeyboard:
            state.focusedField = nil
        }
    }
    
}


#if DEBUG

extension SelectTagsViewModel.TemporaryEntry: Equatable {}

#endif
