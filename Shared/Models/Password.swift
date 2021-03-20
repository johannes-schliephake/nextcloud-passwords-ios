import Foundation


final class Password: ObservableObject, Identifiable {
    
    @Published var id: String
    @Published var label: String
    @Published var username: String
    @Published var password: String
    @Published var url: String
    @Published var notes: String
    var customFields: String
    let status: Int
    let statusCode: StatusCode
    var hash: String
    var folder: String
    @Published var revision: String
    let share: String?
    let shared: Bool
    var cseType: String
    var cseKey: String
    let sseType: String
    let client: String
    var hidden: Bool
    let trashed: Bool
    @Published var favorite: Bool
    let editable: Bool
    @Published var edited: Date
    @Published var created: Date
    @Published var updated: Date
    @Published var error: Entry.EntryError?
    
    init(id: String = "", label: String = "", username: String = "", password: String = "", url: String = "", notes: String = "", customFields: String = "[]", status: Int = 0, statusCode: StatusCode = .good, hash: String = "unknown", folder: String, revision: String = "", share: String? = nil, shared: Bool = false, cseType: String = "none", cseKey: String = "", sseType: String = "unknown", client: String = "unknown", hidden: Bool = false, trashed: Bool = false, favorite: Bool = false, editable: Bool = true, edited: Date = Date(timeIntervalSince1970: 0), created: Date = Date(timeIntervalSince1970: 0), updated: Date = Date(timeIntervalSince1970: 0)) {
        self.id = id
        self.label = label
        self.username = username
        self.password = password
        self.url = url
        self.notes = notes
        self.customFields = customFields
        self.status = status
        self.statusCode = statusCode
        self.hash = hash
        self.folder = folder
        self.revision = revision
        self.share = share
        self.shared = shared
        self.cseType = cseType
        self.cseKey = cseKey
        self.sseType = sseType
        self.client = client
        self.hidden = hidden
        self.trashed = trashed
        self.favorite = favorite
        self.editable = editable
        self.edited = edited
        self.created = created
        self.updated = updated
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String.self, forKey: .password)
        url = try container.decode(String.self, forKey: .url)
        notes = try container.decode(String.self, forKey: .notes)
        customFields = try container.decode(String.self, forKey: .customFields)
        status = try container.decode(Int.self, forKey: .status)
        statusCode = try container.decode(StatusCode.self, forKey: .statusCode)
        hash = try container.decode(String.self, forKey: .hash)
        folder = try container.decode(String.self, forKey: .folder)
        revision = try container.decode(String.self, forKey: .revision)
        share = try container.decode(String?.self, forKey: .share)
        shared = try container.decode(Bool.self, forKey: .shared)
        cseType = try container.decode(String.self, forKey: .cseType)
        cseKey = try container.decode(String.self, forKey: .cseKey)
        sseType = try container.decode(String.self, forKey: .sseType)
        client = try container.decode(String.self, forKey: .client)
        hidden = try container.decode(Bool.self, forKey: .hidden)
        trashed = try container.decode(Bool.self, forKey: .trashed)
        favorite = try container.decode(Bool.self, forKey: .favorite)
        editable = try container.decode(Bool.self, forKey: .editable)
        /// Decode dates to double and call init manually to avoid wrong reference year (defaults to 2001, but 1970 is needed)
        edited = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .edited))
        created = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .created))
        updated = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .updated))
        
        switch cseType {
        case "none":
            break
        case "CSEv1r1":
            guard let keychain = CredentialsController.default.credentials?.keychain,
                  let key = keychain.keys[cseKey],
                  let decryptedLabel = Crypto.CSEv1r1.decrypt(payload: label, key: key),
                  let decryptedUsername = Crypto.CSEv1r1.decrypt(payload: username, key: key),
                  let decryptedPassword = Crypto.CSEv1r1.decrypt(payload: password, key: key),
                  let decryptedUrl = Crypto.CSEv1r1.decrypt(payload: url, key: key),
                  let decryptedNotes = Crypto.CSEv1r1.decrypt(payload: notes, key: key),
                  let decryptedCustomFields = Crypto.CSEv1r1.decrypt(payload: customFields, key: key) else {
                error = .decryptError
                return
            }
            label = decryptedLabel
            username = decryptedUsername
            password = decryptedPassword
            url = decryptedUrl
            notes = decryptedNotes
            customFields = decryptedCustomFields
        default:
            error = .decryptError
        }
    }
    
    func matches(searchTerm: String) -> Bool {
        label.lowercased().contains(searchTerm.lowercased()) ||
            username.lowercased().contains(searchTerm.lowercased()) ||
            url.lowercased().contains(searchTerm.lowercased()) ||
            notes.lowercased().contains(searchTerm.lowercased())
    }
    
    func isDescendentOf(folder: Folder, in folders: [Folder]) -> Bool {
        /// Add folder to folders because base folder is not stored in folders
        let folders = folders + [folder]
        return folders.first { [self] in $0.id == self.folder }?.isDescendentOf(folder: folder, in: folders) ?? false
    }
    
}


extension Password: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case username
        case password
        case url
        case notes
        case customFields
        case status
        case statusCode
        case hash
        case folder
        case revision
        case share
        case shared
        case cseType
        case cseKey
        case sseType
        case client
        case hidden
        case trashed
        case favorite
        case editable
        case edited
        case created
        case updated
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let keychain = CredentialsController.default.credentials?.keychain {
            guard let key = keychain.keys[keychain.current],
                  let encryptedLabel = Crypto.CSEv1r1.encrypt(unencrypted: label, key: key),
                  let encryptedUsername = Crypto.CSEv1r1.encrypt(unencrypted: username, key: key),
                  let encryptedPassword = Crypto.CSEv1r1.encrypt(unencrypted: password, key: key),
                  let encryptedUrl = Crypto.CSEv1r1.encrypt(unencrypted: url, key: key),
                  let encryptedNotes = Crypto.CSEv1r1.encrypt(unencrypted: notes, key: key),
                  let encryptedCustomFields = Crypto.CSEv1r1.encrypt(unencrypted: customFields, key: key) else {
                throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Encryption failed"))
            }
            try container.encode(encryptedLabel, forKey: .label)
            try container.encode(encryptedUsername, forKey: .username)
            try container.encode(encryptedPassword, forKey: .password)
            try container.encode(encryptedUrl, forKey: .url)
            try container.encode(encryptedNotes, forKey: .notes)
            try container.encode(encryptedCustomFields, forKey: .customFields)
            cseType = "CSEv1r1"
            cseKey = keychain.current
        }
        else {
            try container.encode(label, forKey: .label)
            try container.encode(username, forKey: .username)
            try container.encode(password, forKey: .password)
            try container.encode(url, forKey: .url)
            try container.encode(notes, forKey: .notes)
            try container.encode(customFields, forKey: .customFields)
        }
        
        try container.encode(id, forKey: .id)
        try container.encode(status, forKey: .status)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(hash, forKey: .hash)
        try container.encode(folder, forKey: .folder)
        try container.encode(revision, forKey: .revision)
        try container.encode(share, forKey: .share)
        try container.encode(shared, forKey: .shared)
        try container.encode(cseType, forKey: .cseType)
        try container.encode(cseKey, forKey: .cseKey)
        try container.encode(sseType, forKey: .sseType)
        try container.encode(client, forKey: .client)
        try container.encode(hidden, forKey: .hidden)
        try container.encode(trashed, forKey: .trashed)
        try container.encode(favorite, forKey: .favorite)
        try container.encode(editable, forKey: .editable)
        try container.encode(Int64(edited.timeIntervalSince1970), forKey: .edited)
        try container.encode(Int64(created.timeIntervalSince1970), forKey: .created)
        try container.encode(Int64(updated.timeIntervalSince1970), forKey: .updated)
    }
    
}


extension Password {
    
    enum StatusCode: String, Codable, Comparable {
        
        case good = "GOOD"
        case outdated = "OUTDATED"
        case duplicate = "DUPLICATE"
        case breached = "BREACHED"
        
        static func < (lhs: Password.StatusCode, rhs: Password.StatusCode) -> Bool {
            let order: [StatusCode] = [.good, .outdated, .duplicate, .breached]
            return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
        }
        
    }
    
}


extension Password: MockObject {
    
    static var mock: Password {
        Password(id: "00000000-0000-0000-0002-000000000000", label: "_password".localized, username: "johannes.schliephake", password: "Qr47UtYI2Nau3ee3xP51ugl6FWbUwb7F97Yz", url: "https://example.com", folder: Entry.baseId, revision: Entry.baseId, favorite: true)
    }
    
    static var mocks: [Password] {
        [
            Password(id: "00000000-0000-0000-0002-000000000001", label: "Nextcloud", username: "admin", password: "Qr47UtYI2Nau3ee3xP51ugl6FWbUwb7F97Yz", url: "https://cloud.example.com", folder: Entry.baseId, revision: Entry.baseId, favorite: true),
            Password(id: "00000000-0000-0000-0002-000000000002", label: "GitHub", username: "johannes.schliephake", password: "Qr47UtYI2Nau3ee3xP51ugl6FWbUwb7F97Yz", url: "https://github.com/login", folder: Entry.baseId, revision: Entry.baseId),
            Password(id: "00000000-0000-0000-0002-000000000003", label: "Wikipedia", username: "johannes.schliephake", password: "Qr47UtYI2Nau3ee3xP51ugl6FWbUwb7F97Yz", url: "https://en.wikipedia.org/w/index.php?title=Special:UserLogin", folder: Entry.baseId, revision: Entry.baseId)
        ]
    }
    
}
