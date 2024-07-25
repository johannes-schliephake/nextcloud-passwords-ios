import Foundation
import Factory


final class Folder: ObservableObject, Identifiable {
    
    @LazyInjected(\.logger) private var logger
    
    @Published var id: String
    @Published var label: String
    var parent: String?
    @Published var edited: Date
    @Published var created: Date
    @Published var updated: Date
    var revision: String {
        didSet {
            updateOfflineContainer()
        }
    }
    var cseType: String
    var cseKey: String
    var sseType: String
    var client: String
    var hidden: Bool
    var trashed: Bool
    @Published var favorite: Bool
    
    @Published var state: Entry.State?
    var offlineContainer: OfflineContainer?
    
    var isIdLocallyAvailable: Bool {
        !id.isEmpty
    }
    
    var isBaseFolder: Bool {
        id == Entry.baseId
    }
    
    convenience init() {
        self.init(id: Entry.baseId, label: "_rootFolder".localized, parent: nil)
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
    
    required init(from decoder: any Decoder) throws {
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
        edited = try container.decode(Date.self, forKey: .edited)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
        
        switch cseType {
        case "none":
            break
        case "CSEv1r1":
            guard let keychain = SessionController.default.session?.keychain,
                  let key = keychain.keys[cseKey],
                  let decryptedLabel = Crypto.CSEv1r1.decrypt(payload: label, key: key) else {
                state = .decryptionFailed
                logger.log(error: "Failed to decrypt folder")
                return
            }
            label = decryptedLabel
        default:
            state = .decryptionFailed
            logger.log(error: "Unknown client side encryption type")
        }
    }
    
    func score(searchTerm: String) -> Double {
        label.score(searchTerm: searchTerm, penalty: 0.3)
    }
    
    func isDescendentOf(folder: Folder, in folders: [Folder]) -> Bool {
        if folder === self {
            return true
        }
        /// Add folder to folders because base folder is not stored in folders
        let folders = folders + [folder]
        return folders.first { [self] in $0.id == parent }?.isDescendentOf(folder: folder, in: folders) ?? false
    }
    
    func update(from folder: Folder) {
        guard id == folder.id,
              revision != folder.revision else {
            return
        }
        
        label = folder.label
        parent = folder.parent
        edited = folder.edited
        created = folder.created
        updated = folder.updated
        cseType = folder.cseType
        cseKey = folder.cseKey
        sseType = folder.sseType
        client = folder.client
        hidden = folder.hidden
        trashed = folder.trashed
        favorite = folder.favorite
        
        state = folder.state
        revision = folder.revision
    }
    
    func updateOfflineContainer() {
        if revision.isEmpty || !Configuration.userDefaults.bool(forKey: "storeOffline") {
            CoreData.default.delete(offlineContainer)
            offlineContainer = nil
        }
        else if let offlineContainer {
            offlineContainer.update(from: self)
        }
        else {
            offlineContainer = OfflineContainer(context: CoreData.default.context, folder: self)
        }
        CoreData.default.save()
    }
    
}


extension Folder: Codable {
    
    private enum CodingKeys: String, CodingKey {
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
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let keychain = SessionController.default.session?.keychain,
           state != .decryptionFailed,
           cseType != "none" || encoder.userInfo[CodingUserInfoKey(rawValue: "updated")!] as? Bool == true {
            guard let key = keychain.keys[keychain.current],
                  let encryptedLabel = Crypto.CSEv1r1.encrypt(unencrypted: label, key: key) else {
                throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Encryption failed"))
            }
            try container.encode(encryptedLabel, forKey: .label)
            cseType = "CSEv1r1"
            cseKey = keychain.current
        }
        else {
            try container.encode(label, forKey: .label)
        }
        
        try container.encode(id, forKey: .id)
        try container.encode(parent, forKey: .parent)
        try container.encode(edited, forKey: .edited)
        try container.encode(created, forKey: .created)
        try container.encode(updated, forKey: .updated)
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


extension Folder: Hashable {
    
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}


extension Array where Element == Folder {
    
    func sortedByLabel() -> [Folder] {
        sorted { $0.label.compare($1.label, options: [.caseInsensitive, .diacriticInsensitive, .numeric]) == .orderedAscending }
    }
    
}


extension Folder: MockObject {
    
    static var mock: Folder {
        Folder(id: "00000000-0000-0000-0001-000000000000", label: "_folder".localized, parent: Entry.baseId, edited: Date(), created: Date(), updated: Date(), revision: Entry.baseId, favorite: true)
    }
    
    static var mocks: [Folder] {
        [
            Folder(id: "00000000-0000-0000-0001-000000000001", label: Locale.current.languageCode == "en" ? "Finances" : "Finanzen", parent: Entry.baseId, edited: Date(), created: Date(), updated: Date(), revision: Entry.baseId, favorite: true),
            Folder(id: "00000000-0000-0000-0001-000000000002", label: Locale.current.languageCode == "en" ? "Work" : "Arbeit", parent: Entry.baseId, edited: Date(), created: Date(), updated: Date(), revision: Entry.baseId),
            Folder(id: "00000000-0000-0000-0001-000000000003", label: Locale.current.languageCode == "en" ? "Entertainment" : "Unterhaltung", parent: Entry.baseId, edited: Date(), created: Date(), updated: Date(), revision: Entry.baseId)
        ]
    }
    
}
