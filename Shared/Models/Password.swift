import Foundation


final class Password: ObservableObject, Identifiable {
    
    @Published var id: String
    @Published var label: String
    @Published var username: String
    @Published var password: String
    @Published var url: String
    @Published var notes: String
    @Published var customFields: [CustomField]
    var status: Int
    var statusCode: StatusCode
    var hash: String
    var folder: String
    var revision: String {
        didSet {
            updateOfflineContainer()
        }
    }
    var share: String?
    var shared: Bool
    var cseType: String
    var cseKey: String
    var sseType: String
    var client: String
    var hidden: Bool
    var trashed: Bool
    @Published var favorite: Bool
    var editable: Bool
    @Published var edited: Date
    @Published var created: Date
    @Published var updated: Date
    
    @Published var state: Entry.State?
    var offlineContainer: OfflineContainer?
    
    init(id: String = "", label: String = "", username: String = "", password: String = "", url: String = "", notes: String = "", customFields: [CustomField] = [], status: Int = 0, statusCode: StatusCode = .good, hash: String = "unknown", folder: String, revision: String = "", share: String? = nil, shared: Bool = false, cseType: String = "none", cseKey: String = "", sseType: String = "unknown", client: String = "unknown", hidden: Bool = false, trashed: Bool = false, favorite: Bool = false, editable: Bool = true, edited: Date = Date(timeIntervalSince1970: 0), created: Date = Date(timeIntervalSince1970: 0), updated: Date = Date(timeIntervalSince1970: 0)) {
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
        var customFieldsString = try container.decode(String.self, forKey: .customFields)
        customFields = []
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
                  let decryptedUsername = Crypto.CSEv1r1.decrypt(payload: username, key: key),
                  let decryptedPassword = Crypto.CSEv1r1.decrypt(payload: password, key: key),
                  let decryptedUrl = Crypto.CSEv1r1.decrypt(payload: url, key: key),
                  let decryptedNotes = Crypto.CSEv1r1.decrypt(payload: notes, key: key),
                  let decryptedCustomFieldsString = Crypto.CSEv1r1.decrypt(payload: customFieldsString, key: key) else {
                state = .decryptionFailed
                return
            }
            label = decryptedLabel
            username = decryptedUsername
            password = decryptedPassword
            url = decryptedUrl
            notes = decryptedNotes
            customFieldsString = decryptedCustomFieldsString
        default:
            state = .decryptionFailed
        }
        
        if customFieldsString.isEmpty {
            customFieldsString = "[]"
        }
        guard let customFieldsData = customFieldsString.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Custom fields decoding failed"))
        }
        customFields = try Configuration.jsonDecoder.decode([CustomField].self, from: customFieldsData)
    }
    
    func score(searchTerm: String) -> Double {
        var scores = [label.score(searchTerm: searchTerm, penalty: 0.3),
                      username.score(searchTerm: searchTerm, penalty: 0.9) * 0.6,
                      notes.score(searchTerm: searchTerm, penalty: 0.01) * 0.7,
                      scoreUrlString(url, searchTerm: searchTerm)]
        
        scores += customFields
            .map {
                customField in
                let labelScore = customField.label.score(searchTerm: searchTerm, penalty: 0.9) * 0.6
                switch customField.type {
                case .text:
                    return labelScore + customField.value.score(searchTerm: searchTerm, penalty: 0.3)
                case .secret:
                    return labelScore
                case .email:
                    return labelScore + customField.value.score(searchTerm: searchTerm, penalty: 0.9) * 0.6
                case .url:
                    return labelScore + scoreUrlString(customField.value, searchTerm: searchTerm)
                case .file:
                    return labelScore + customField.value.score(searchTerm: searchTerm, penalty: 0.4) * 0.85
                default:
                    return 0.0
                }
            }
            .map { $0 * 0.8 }
        
        return scores
            .sorted { $0 > $1 }
            .enumerated()
            .map { $1 * pow(0.5, Double($0)) }
            .reduce(0.0, +)
    }
    
    func isDescendentOf(folder: Folder, in folders: [Folder]) -> Bool {
        /// Add folder to folders because base folder is not stored in folders
        let folders = folders + [folder]
        return folders.first { [self] in $0.id == self.folder }?.isDescendentOf(folder: folder, in: folders) ?? false
    }
    
    func update(from password: Password) {
        guard id == password.id,
              revision != password.revision else {
            return
        }
        
        label = password.label
        username = password.username
        self.password = password.password
        url = password.url
        notes = password.notes
        customFields = password.customFields
        status = password.status
        statusCode = password.statusCode
        hash = password.hash
        folder = password.folder
        share = password.share
        shared = password.shared
        cseType = password.cseType
        cseKey = password.cseKey
        sseType = password.sseType
        client = password.client
        hidden = password.hidden
        trashed = password.trashed
        favorite = password.favorite
        editable = password.editable
        edited = password.edited
        created = password.created
        updated = password.updated
        
        state = password.state
        revision = password.revision
    }
    
    func updateOfflineContainer() {
        if revision.isEmpty || !Configuration.userDefaults.bool(forKey: "storeOffline") {
            CoreData.default.delete(offlineContainer)
            offlineContainer = nil
        }
        else if let offlineContainer = offlineContainer {
            offlineContainer.update(from: self)
        }
        else {
            offlineContainer = OfflineContainer(context: CoreData.default.context, password: self)
        }
        CoreData.default.save()
    }
    
    private func scoreUrlString(_ urlString: String, searchTerm: String) -> Double {
        let url = URL(string: urlString)
        let searchUrl = URL(string: searchTerm)
        if let url = url?.scheme != nil ? url : URL(string: "https://\(urlString)"),
           let searchUrl = searchUrl?.scheme != nil ? searchUrl : URL(string: "https://\(searchTerm)") {
            return url.score(searchUrl: searchUrl)
        }
        else {
            return urlString.score(searchTerm: searchTerm) * 0.7
        }
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
        
        let customFieldsData = try Configuration.nonUpdatingJsonEncoder.encode(customFields)
        guard let customFieldsString = String(data: customFieldsData, encoding: .utf8) else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Custom fields encoding failed"))
        }
        
        if let keychain = SessionController.default.session?.keychain,
           state != .decryptionFailed,
           cseType != "none" || encoder.userInfo[CodingUserInfoKey(rawValue: "updated")!] as? Bool == true {
            guard let key = keychain.keys[keychain.current],
                  let encryptedLabel = Crypto.CSEv1r1.encrypt(unencrypted: label, key: key),
                  let encryptedUsername = Crypto.CSEv1r1.encrypt(unencrypted: username, key: key),
                  let encryptedPassword = Crypto.CSEv1r1.encrypt(unencrypted: password, key: key),
                  let encryptedUrl = Crypto.CSEv1r1.encrypt(unencrypted: url, key: key),
                  let encryptedNotes = Crypto.CSEv1r1.encrypt(unencrypted: notes, key: key),
                  let encryptedCustomFields = Crypto.CSEv1r1.encrypt(unencrypted: customFieldsString, key: key) else {
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
            try container.encode(customFieldsString, forKey: .customFields)
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
        try container.encode(edited, forKey: .edited)
        try container.encode(created, forKey: .created)
        try container.encode(updated, forKey: .updated)
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


extension Password {
    
    struct CustomField: Identifiable, Codable {
        
        let id = UUID()
        var label: String
        var type: CustomFieldType
        var value: String
        
        enum CodingKeys: CodingKey { // swiftlint:disable:this nesting
            case label
            case type
            case value
        }
        
        enum CustomFieldType: String, Identifiable, Codable, CaseIterable { // swiftlint:disable:this nesting
            
            case text
            case secret
            case email
            case url
            case file
            case data
            
            var id: String {
                rawValue
            }
            
            var systemName: String {
                switch self {
                case .text:
                    return "text.alignleft"
                case .secret:
                    return "key"
                case .email:
                    return "envelope"
                case .url:
                    return "safari"
                case .file:
                    return "doc"
                default:
                    return "terminal"
                }
            }
            
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
