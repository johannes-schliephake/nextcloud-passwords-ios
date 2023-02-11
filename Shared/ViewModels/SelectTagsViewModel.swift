import Foundation
import Combine
import Factory


protocol SelectTagsViewModelProtocol: ViewModel where State == SelectTagsViewModel.State, Action == SelectTagsViewModel.Action {
    
    init(temporaryEntry: SelectTagsViewModel.TemporaryEntry, selectTags: @escaping ([Tag], [String]) -> Void)
    
}


final class SelectTagsViewModel: SelectTagsViewModelProtocol { // swiftlint:disable:this file_types_order
    
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
        case toggleTag(_ tag: Tag)
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
    
    @Injected(Container.tagsService) private var tagsService
    @LazyInjected(Container.tagLabelValidator) private var tagLabelValidator
    
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
            guard tagLabelValidator.validate(state.tagLabel) else {
                return
            }
            let tag = Tag(label: state.tagLabel, client: Configuration.clientName, edited: Date(), created: Date(), updated: Date())
            state.selectableTags.append((tag: tag, isSelected: true))
            state.tagLabel = ""
            tagsService.add(tag: tag)
        case let .toggleTag(tag):
            guard let index = state.selectableTags.firstIndex(where: { $0.tag == tag }) else {
                return
            }
            state.selectableTags[index].isSelected.toggle()
        case .selectTags:
            let selectedTags = state.selectableTags.filter(\.isSelected).map(\.tag)
            guard state.hasChanges,
                  selectedTags.allSatisfy(\.isIdLocallyAvailable) else {
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

final class SelectTagsViewModelMock: ViewModelMock<SelectTagsViewModel.State, SelectTagsViewModel.Action>, SelectTagsViewModelProtocol {
    
    convenience init(temporaryEntry: SelectTagsViewModel.TemporaryEntry, selectTags: @escaping ([Tag], [String]) -> Void) {
        self.init()
    }
    
}


extension SelectTagsViewModel.State: Mock {
    
    convenience init() {
        let passwordMock = Container.password()
        self.init(temporaryEntry: .password(label: passwordMock.label, username: passwordMock.username, url: passwordMock.url, tags: passwordMock.tags), tagLabel: "", selectableTags: Tag.mocks.map { (tag: $0, isSelected: false) }, hasChanges: false, focusedField: nil)
    }
    
}


extension SelectTagsViewModel.TemporaryEntry: Equatable {}

#endif
