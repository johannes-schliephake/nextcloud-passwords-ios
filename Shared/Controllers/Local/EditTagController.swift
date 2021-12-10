import SwiftUI


final class EditTagController: ObservableObject {
    
    let tag: Tag
    private let addTag: () -> Void
    private let updateTag: () -> Void
    
    @Published var tagLabel: String
    @Published var tagColor: Color
    @Published var tagFavorite: Bool
    
    init(tag: Tag, addTag: @escaping () -> Void, updateTag: @escaping () -> Void) {
        self.tag = tag
        self.addTag = addTag
        self.updateTag = updateTag
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
            addTag()
        }
        else {
            updateTag()
        }
    }
    
}
