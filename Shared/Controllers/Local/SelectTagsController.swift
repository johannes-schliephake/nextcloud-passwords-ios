import Foundation
import Combine


final class SelectTagsController: ObservableObject {
    
    let temporaryEntry: TemporaryEntry
    var tags: [Tag]
    let addTag: (Tag) -> Void
    let selectTags: ([Tag]) -> Void
    
    @Published var selection: [Tag]
    @Published var createTagLabel = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(temporaryEntry: TemporaryEntry, tags: [Tag], addTag: @escaping (Tag) -> Void, selectTags: @escaping ([Tag]) -> Void) {
        self.temporaryEntry = temporaryEntry
        self.tags = tags
        self.addTag = addTag
        self.selectTags = selectTags
        
        selection = temporaryEntry.tags.compactMap {
            tagId in
            tags.first { $0.id == tagId }
        }
        
        tags.forEach {
            tag in
            tag.objectWillChange
                .sink { [weak self] in self?.objectWillChange.send() }
                .store(in: &subscriptions)
        }
    }
    
    func createTag() {
        guard 1...48 ~= createTagLabel.count else {
            return
        }
        let tag = Tag(label: createTagLabel, client: Configuration.clientName, edited: Date(), created: Date(), updated: Date())
        tags.append(tag)
        selection.append(tag)
        tag.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &subscriptions)
        addTag(tag)
        createTagLabel = ""
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
