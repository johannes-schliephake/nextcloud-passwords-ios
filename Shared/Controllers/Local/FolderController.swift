import Foundation
import Combine


final class FolderController: ObservableObject {
    
    let folder: Folder
    let tag: Tag?
    let defaultSorting: EntriesController.Sorting?
    
    @Published var autoFillController: AutoFillController?
    @Published var searchTerm = ""
    @Published private(set) var entries: [Entry]?
    @Published private(set) var suggestions: [Password]?
    
    private var entriesPipeline: AnyCancellable?
    private var suggestionsPipeline: AnyCancellable?
    private let entriesControllerDidChange = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(entriesController: EntriesController, folder: Folder?, tag: Tag?, defaultSorting: EntriesController.Sorting?) {
        let folder = folder ?? Folder()
        self.folder = folder
        self.tag = tag
        self.defaultSorting = defaultSorting
        
        entriesController.objectWillChange
            .sink {
                [weak self] in
                DispatchQueue.main.async {
                    self?.entriesControllerDidChange.send()
                }
            }
            .store(in: &subscriptions)
        
        entriesPipeline = Publishers.Merge(
            entriesControllerDidChange
                .compactMap { [weak self] in self?.searchTerm }
                .receive(on: DispatchQueue.global(qos: .userInitiated)),
            $searchTerm
                .throttle(for: 0.5, scheduler: DispatchQueue.global(qos: .userInitiated), latest: true)
                .removeDuplicates { [weak self] in self?.entries != nil && $0 == $1 }
        )
        .map { entriesController.processEntries(folder: folder, tag: tag, searchTerm: $0, defaultSorting: defaultSorting) }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in self?.entries = $0 }
        
        suggestionsPipeline = Publishers.Merge(
            entriesController.objectWillChange
                .compactMap { [weak self] in self?.autoFillController?.serviceURLs },
            $autoFillController
                .compactMap { $0?.serviceURLs }
        )
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .map { entriesController.processSuggestions(serviceURLs: $0) }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in self?.suggestions = $0 }
    }
    
}
