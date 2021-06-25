import Foundation
import Combine


final class FolderController: ObservableObject {
    
    let folder: Folder
    
    @Published var autoFillController: AutoFillController?
    @Published var searchTerm = ""
    @Published private(set) var entries: [Entry]?
    @Published private(set) var suggestions: [Password]?
    
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
        .map { entriesController.processEntries(folder: folder, searchTerm: $0) }
        .receive(on: DispatchQueue.main)
        .assign(to: &$entries)
        
        Publishers.Merge(
            entriesController.objectWillChange
                .compactMap { [weak self] in self?.autoFillController?.serviceURLs },
            $autoFillController
                .compactMap { $0?.serviceURLs }
        )
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .map { entriesController.processSuggestions(serviceURLs: $0) }
        .receive(on: DispatchQueue.main)
        .assign(to: &$suggestions)
    }
    
}
