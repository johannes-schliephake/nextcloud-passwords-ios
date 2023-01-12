import Foundation
import Combine


final class SelectTagsController: ObservableObject {
    
    let entriesController: EntriesController
    let temporaryEntry: TemporaryEntry
    let selectTags: ([Tag], [String]) -> Void
    
    @Published private(set) var selection: [Tag]
    let invalidTags: [String]
    @Published var tagLabel = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(entriesController: EntriesController, temporaryEntry: TemporaryEntry, selectTags: @escaping ([Tag], [String]) -> Void) {
        self.entriesController = entriesController
        self.temporaryEntry = temporaryEntry
        self.selectTags = selectTags
        
        (selection, invalidTags) = EntriesController.tags(for: temporaryEntry.tags, in: entriesController.tags ?? [])
        
        entriesController.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &subscriptions)
    }
    
    var tags: [Tag] {
        entriesController.tags?.sorted() ?? []
    }
    
    var hasChanges: Bool {
        selection.map { $0.id }.sorted() != EntriesController.tags(for: temporaryEntry.tags, in: entriesController.tags ?? []).valid.map { $0.id }.sorted()
    }
    
    func addTag() {
        guard 1...48 ~= tagLabel.count else {
            return
        }
        let tag = Tag(label: tagLabel, client: Configuration.clientName, edited: Date(), created: Date(), updated: Date())
        entriesController.add(tag: tag)
        selection.append(tag)
        tagLabel = ""
    }
    
    func toggleTag(_ tag: Tag) {
        if selection.contains(where: { $0.id == tag.id }) {
            selection.removeAll { $0.id == tag.id }
        }
        else {
            selection.append(tag)
        }
    }
    
}


extension SelectTagsController {
    
    enum TemporaryEntry {
        
        case password(label: String, username: String, url: String, tags: [String])
        
        var tags: [String] {
            switch self {
            case .password(_, _, _, let tags):
                return tags
            }
        }
        
    }
    
}
