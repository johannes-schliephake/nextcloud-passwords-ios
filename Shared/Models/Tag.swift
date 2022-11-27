import Foundation


final class Tag: ObservableObject, Identifiable {
    
    @Published var id: String
    @Published var label: String
    @Published var color: String
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
    @Published var edited: Date
    @Published var created: Date
    @Published var updated: Date
    
    @Published var state: Entry.State?
    var offlineContainer: OfflineContainer?
    
    init(id: String = "", label: String = "", color: String = randomTagColor(), revision: String = "", cseType: String = "none", cseKey: String = "", sseType: String = "unknown", client: String = "unknown", hidden: Bool = false, trashed: Bool = false, favorite: Bool = false, edited: Date = Date(timeIntervalSince1970: 0), created: Date = Date(timeIntervalSince1970: 0), updated: Date = Date(timeIntervalSince1970: 0)) {
        self.id = id
        self.label = label
        self.color = color
        self.revision = revision
        self.cseType = cseType
        self.cseKey = cseKey
        self.sseType = sseType
        self.client = client
        self.hidden = hidden
        self.trashed = trashed
        self.favorite = favorite
        self.edited = edited
        self.created = created
        self.updated = updated
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        color = try container.decode(String.self, forKey: .color)
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
                  let decryptedLabel = Crypto.CSEv1r1.decrypt(payload: label, key: key),
                  let decryptedColor = Crypto.CSEv1r1.decrypt(payload: color, key: key) else {
                state = .decryptionFailed
                LoggingController.shared.log(error: "Failed to decrypt tag")
                return
            }
            label = decryptedLabel
            color = decryptedColor
        default:
            state = .decryptionFailed
            LoggingController.shared.log(error: "Unknown client side encryption type")
        }
    }
    
    func score(searchTerm: String) -> Double {
        label.score(searchTerm: searchTerm, penalty: 0.3)
    }
    
    func update(from tag: Tag) {
        guard id == tag.id,
              revision != tag.revision else {
            return
        }
        
        label = tag.label
        color = tag.color
        cseType = tag.cseType
        cseKey = tag.cseKey
        sseType = tag.sseType
        client = tag.client
        hidden = tag.hidden
        trashed = tag.trashed
        favorite = tag.favorite
        edited = tag.edited
        created = tag.created
        updated = tag.updated
        
        state = tag.state
        revision = tag.revision
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
            offlineContainer = OfflineContainer(context: CoreData.default.context, tag: self)
        }
        CoreData.default.save()
    }
    
    static private func randomTagColor() -> String {
        /// Colors taken from https://github.com/isuru88/random-material-color/blob/master/src/defaultPalette.js, same as Passwords web app
        ["#F44336", "#E91E63", "#9C27B0", "#673AB7", "#3F51B5", "#2196F3", "#03A9F4", "#00BCD4", "#009688", "#4CAF50", "#8BC34A", "#CDDC39", "#FFEB3B", "#FFC107", "#FF9800", "#FF5722", "#795548", "#9E9E9E", "#607D8B"].randomElement() ?? ""
    }
    
}


extension Tag: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case label
        case color
        case revision
        case cseType
        case cseKey
        case sseType
        case client
        case hidden
        case trashed
        case favorite
        case edited
        case created
        case updated
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let keychain = SessionController.default.session?.keychain,
           state != .decryptionFailed,
           cseType != "none" || encoder.userInfo[CodingUserInfoKey(rawValue: "updated")!] as? Bool == true {
            guard let key = keychain.keys[keychain.current],
                  let encryptedLabel = Crypto.CSEv1r1.encrypt(unencrypted: label, key: key),
                  let encryptedColor = Crypto.CSEv1r1.encrypt(unencrypted: color, key: key) else {
                throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Encryption failed"))
            }
            try container.encode(encryptedLabel, forKey: .label)
            try container.encode(encryptedColor, forKey: .color)
            cseType = "CSEv1r1"
            cseKey = keychain.current
        }
        else {
            try container.encode(label, forKey: .label)
            try container.encode(color, forKey: .color)
        }
        
        try container.encode(id, forKey: .id)
        try container.encode(revision, forKey: .revision)
        try container.encode(cseType, forKey: .cseType)
        try container.encode(cseKey, forKey: .cseKey)
        try container.encode(sseType, forKey: .sseType)
        try container.encode(client, forKey: .client)
        try container.encode(hidden, forKey: .hidden)
        try container.encode(trashed, forKey: .trashed)
        try container.encode(favorite, forKey: .favorite)
        try container.encode(edited, forKey: .edited)
        try container.encode(created, forKey: .created)
        try container.encode(updated, forKey: .updated)
    }
    
}


extension Tag: Hashable {
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}


extension Array where Element == Tag {
    
    func sortedByLabel() -> [Tag] {
        sorted { $0.label.compare($1.label, options: [.caseInsensitive, .diacriticInsensitive, .numeric]) == .orderedAscending }
    }
    
}


extension Tag: MockObject {
    
    static var mock: Tag {
        Tag(id: "00000000-0000-0000-0003-000000000000", label: "_tag".localized, color: "#F44336", edited: Date(), created: Date(), updated: Date())
    }
    
    static var mocks: [Tag] {
        [
            Tag(id: "00000000-0000-0000-0003-000000000001", label: Locale.current.languageCode == "en" ? "Development" : "Entwicklung", color: "#F44336", edited: Date(), created: Date(), updated: Date()),
            Tag(id: "00000000-0000-0000-0003-000000000002", label: Locale.current.languageCode == "en" ? "Self-Hosted" : "Selbst gehostet", color: "#673AB7", edited: Date(), created: Date(), updated: Date())
        ]
    }
    
}
