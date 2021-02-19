import Foundation


final class Folder: ObservableObject, Identifiable {
    
    @Published var id: String
    @Published var label: String
    var parent: String?
    @Published var edited: Date
    @Published var created: Date
    @Published var updated: Date
    @Published var revision: String
    var cseType: String
    var cseKey: String
    let sseType: String
    let client: String
    var hidden: Bool
    let trashed: Bool
    @Published var favorite: Bool
    @Published var error: Entry.EntryError?
    
    convenience init() {
        self.init(id: Entry.baseId, label: "_passwords".localized, parent: nil)
    }
    
    init(id: String = "", label: String = "", parent: String?, edited: Date = Date(timeIntervalSince1970: 0), created: Date = Date(timeIntervalSince1970: 0), updated: Date = Date(timeIntervalSince1970: 0), revision: String = "", cseType: String = "none", cseKey: String = "", sseType: String = "unknown", client: String = "unknown", hidden: Bool = false, trashed: Bool = false, favorite: Bool = false) {
        self.id = id
        self.label = label
        self.parent = parent
        self.edited = edited
        self.created = created
        self.updated = updated
        self.revision = revision
        self.cseType = cseType
        self.cseKey = cseKey
        self.sseType = sseType
        self.client = client
        self.hidden = hidden
        self.trashed = trashed
        self.favorite = favorite
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        parent = try container.decode(String.self, forKey: .parent)
        revision = try container.decode(String.self, forKey: .revision)
        cseType = try container.decode(String.self, forKey: .cseType)
        cseKey = try container.decode(String.self, forKey: .cseKey)
        sseType = try container.decode(String.self, forKey: .sseType)
        client = try container.decode(String.self, forKey: .client)
        hidden = try container.decode(Bool.self, forKey: .hidden)
        trashed = try container.decode(Bool.self, forKey: .trashed)
        favorite = try container.decode(Bool.self, forKey: .favorite)
        /// Decode dates to double and call init manually to avoid wrong reference year (defaults to 2001, but 1970 is needed)
        edited = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .edited))
        created = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .created))
        updated = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .updated))
    }
    
    var isBaseFolder: Bool {
        id == Entry.baseId
    }
    
    func matches(searchTerm: String) -> Bool {
        label.lowercased().contains(searchTerm.lowercased())
    }
    
    func isDescendentOf(folder: Folder, in folders: [Folder]) -> Bool {
        if folder === self {
            return true
        }
        /// Add folder to folders because base folder is not stored in folders
        let folders = folders + [folder]
        return folders.first { [self] in $0.id == parent }?.isDescendentOf(folder: folder, in: folders) ?? false
    }
    
}


extension Folder: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case parent
        case edited
        case created
        case updated
        case revision
        case cseType
        case cseKey
        case sseType
        case client
        case hidden
        case trashed
        case favorite
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(parent, forKey: .parent)
        try container.encode(Int64(edited.timeIntervalSince1970), forKey: .edited)
        try container.encode(Int64(created.timeIntervalSince1970), forKey: .created)
        try container.encode(Int64(updated.timeIntervalSince1970), forKey: .updated)
        try container.encode(revision, forKey: .revision)
        try container.encode(cseType, forKey: .cseType)
        try container.encode(cseKey, forKey: .cseKey)
        try container.encode(sseType, forKey: .sseType)
        try container.encode(client, forKey: .client)
        try container.encode(hidden, forKey: .hidden)
        try container.encode(trashed, forKey: .trashed)
        try container.encode(favorite, forKey: .favorite)
    }
    
}


extension Folder: MockObject {
    
    static var mock: Folder {
        Folder(id: "00000000-0000-0000-0001-000000000000", label: "_folder".localized, parent: Entry.baseId, revision: Entry.baseId, favorite: true)
    }
    
    static var mocks: [Folder] {
        [
            Folder(id: "00000000-0000-0000-0001-000000000001", label: "Websites", parent: Entry.baseId, revision: Entry.baseId, favorite: true),
            Folder(id: "00000000-0000-0000-0001-000000000002", label: "Apps", parent: Entry.baseId, revision: Entry.baseId)
        ]
    }
    
}
