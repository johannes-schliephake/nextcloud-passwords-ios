import SwiftUI


final class EditTagController: ObservableObject {
    
    let entriesController: EntriesController
    let tag: Tag
    
    @Published var tagLabel: String
    @Published var tagColor: Color
    @Published var tagFavorite: Bool
    
    init(entriesController: EntriesController, tag: Tag) {
        self.entriesController = entriesController
        self.tag = tag
        tagLabel = tag.label
        tagColor = Color(hex: tag.color) ?? .black
        tagFavorite = tag.favorite
    }
    
    var hasChanges: Bool {
        tagLabel != tag.label ||
        tagColor.hex.compare(tag.color, options: [.caseInsensitive]) != .orderedSame ||
        tagFavorite != tag.favorite
    }
    
    var editIsValid: Bool {
        1...48 ~= tagLabel.count
    }
    
    func applyToTag() {
        if tag.id.isEmpty {
            tag.created = Date()
        }
        tag.edited = Date()
        tag.updated = Date()
        
        tag.label = tagLabel
        tag.color = tagColor.hex
        tag.favorite = tagFavorite
        
        if tag.id.isEmpty {
            entriesController.add(tag: tag)
        }
        else {
            entriesController.update(tag: tag)
        }
    }
    
    func clearTag() {
        entriesController.delete(tag: tag)
    }
    
}
