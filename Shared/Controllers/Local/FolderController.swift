import Foundation
import Combine


final class FolderController: ObservableObject {
    
    let folder: Folder
    
    @Published var autoFillController: AutoFillController?
    @Published var searchTerm = ""
    @Published private(set) var entries: [Entry]?
    @Published private(set) var suggestions: [Password]?
    
    private var entriesPipelineUuid: UUID?
    private var suggestionsPipelineUuid: UUID?
    
    init(entriesController: EntriesController, folder: Folder?) {
        let folder = folder ?? Folder()
        self.folder = folder
        
        Publishers.Merge(
            entriesController.objectWillChange
                .compactMap { [weak self] in self?.searchTerm }
                .receive(on: DispatchQueue.global(qos: .userInitiated)),
            $searchTerm
                .throttle(for: 0.5, scheduler: DispatchQueue.global(qos: .userInitiated), latest: true)
                .removeDuplicates { [weak self] in self?.entries != nil && $0 == $1 }
        )
        .map { ($0, UUID()) }
        .handleEvents(receiveOutput: { [weak self] _, uuid in self?.entriesPipelineUuid = uuid })
        .map { (entriesController.processEntries(folder: folder, searchTerm: $0.0), $0.1) }
        .compactMap { [weak self] entries, uuid in uuid == self?.entriesPipelineUuid ? entries : nil }
        .receive(on: DispatchQueue.main)
        .assign(to: &$entries)
        
        Publishers.Merge(
            entriesController.objectWillChange
                .compactMap { [weak self] in self?.autoFillController?.serviceURLs },
            $autoFillController
                .compactMap { $0?.serviceURLs }
        )
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .map { ($0, UUID()) }
        .handleEvents(receiveOutput: { [weak self] _, uuid in self?.suggestionsPipelineUuid = uuid })
        .map { (entriesController.processSuggestions(serviceURLs: $0.0), $0.1) }
        .compactMap { [weak self] suggestions, uuid in uuid == self?.suggestionsPipelineUuid ? suggestions : nil }
        .receive(on: DispatchQueue.main)
        .assign(to: &$suggestions)
    }
    
}
