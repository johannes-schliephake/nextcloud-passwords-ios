import Foundation
import Sodium
import CryptoKit


enum Crypto {
    
    private static let sodium = Sodium()
    
}


extension Crypto {
    
    enum PWDv1r1 {
        
        struct Challenge: Decodable { // swiftlint:disable:this nesting
            
            let salts: [String]
            let type: String
            
        }
        
        static func solve(challenge: Challenge, password: String) -> String? {
            guard challenge.type == "PWDv1r1",
                  let passwordSalt = sodium.utils.hex2bin(challenge.salts[0]),
                  let key = sodium.utils.hex2bin(challenge.salts[1]),
                  let passwordHashSalt = sodium.utils.hex2bin(challenge.salts[2]) else {
                return nil
            }
            let message = password.bytes + passwordSalt
            
            guard let genericHash = sodium.genericHash.hash(message: message, key: key, outputLength: sodium.genericHash.BytesMax),
                  let solution = sodium.pwHash.hash(outputLength: sodium.box.SeedBytes, passwd: genericHash, salt: passwordHashSalt, opsLimit: sodium.pwHash.OpsLimitInteractive, memLimit: sodium.pwHash.MemLimitInteractive, alg: .Default) else {
                return nil
            }
            return sodium.utils.bin2hex(solution)
        }
        
    }
    
}


extension Crypto {
    
    enum CSEv1r1 {
        
        final class Keychain: Codable { // swiftlint:disable:this nesting
            
            let current: String
            let keys: [String: Bytes]
            
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                current = try container.decode(String.self, forKey: .current)
                keys = try container.decode([String: String].self, forKey: .keys).compactMapValues { sodium.utils.hex2bin($0) }
            }
            
            private enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
                case current
                case keys
            }
            
        }
        
        static func decrypt(keys: String, password: String, retryWithBase64: Bool = false) -> Keychain? {
            guard let encryptedBytes = retryWithBase64 ? sodium.utils.base642bin(keys) : sodium.utils.hex2bin(keys) else {
                return retryWithBase64 ? nil : decrypt(keys: keys, password: password, retryWithBase64: true)
            }
            let salt = Bytes(encryptedBytes[..<sodium.pwHash.SaltBytes])
            let payload = Bytes(encryptedBytes[sodium.pwHash.SaltBytes...])
            
            guard let secretKey = sodium.pwHash.hash(outputLength: sodium.box.SeedBytes, passwd: password.bytes, salt: salt, opsLimit: sodium.pwHash.OpsLimitInteractive, memLimit: sodium.pwHash.MemLimitInteractive, alg: .Default),
                  let json = sodium.secretBox.open(nonceAndAuthenticatedCipherText: payload, secretKey: secretKey) else {
                return retryWithBase64 ? nil : decrypt(keys: keys, password: password, retryWithBase64: true)
            }
            return try? Configuration.jsonDecoder.decode(Keychain.self, from: Data(json))
        }
        
        static func decrypt(payload: String, key: Bytes, retryWithBase64: Bool = false) -> String? {
            guard !payload.isEmpty else {
                return ""
            }
            guard let encryptedBytes = retryWithBase64 ? sodium.utils.base642bin(payload) : sodium.utils.hex2bin(payload),
                  let decryptedBytes = sodium.secretBox.open(nonceAndAuthenticatedCipherText: encryptedBytes, secretKey: key) else {
                return retryWithBase64 ? nil : decrypt(payload: payload, key: key, retryWithBase64: true)
            }
            return decryptedBytes.utf8String
        }
        
        static func encrypt(unencrypted: String, key: Bytes) -> String? {
            guard !unencrypted.isEmpty else {
                return ""
            }
            guard let nonce = sodium.randomBytes.buf(length: sodium.secretBox.NonceBytes),
                  let encryptedBytes = sodium.secretBox.seal(message: unencrypted.bytes, secretKey: key, nonce: nonce) else {
                return nil
            }
            let message = nonce + encryptedBytes
            return sodium.utils.bin2hex(message)
        }
        
    }
    
}


extension Crypto {
    
    enum SHA1 {
        
        static func hash(_ data: Data, humanReadable: Bool = false) -> String {
            if humanReadable {
                return Insecure.SHA1.hash(data: data).map { String(format: "%02X", $0) }.joined(separator: ":")
            }
            return Insecure.SHA1.hash(data: data).map { String(format: "%02x", $0) }.joined()
        }
        
    }
    
}


extension Crypto {
    
    enum SHA256 {
        
        static func hash(_ data: Data, humanReadable: Bool = false) -> String {
            if humanReadable {
                return CryptoKit.SHA256.hash(data: data).map { String(format: "%02X", $0) }.joined(separator: ":")
            }
            return CryptoKit.SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        }
        
    }
    
}


extension Crypto {
    
    enum AES256 {
        
        static func getKey(named keyName: String) -> SymmetricKey {
            if let key = Keychain.default.load(key: keyName),
               let data = Data(base64Encoded: key) {
                return SymmetricKey(data: data)
            }
            let key = SymmetricKey(size: .bits256)
            Keychain.default.store(key: keyName, value: withUnsafeBytes(of: key) { Data($0).base64EncodedString() })
            return key
        }
        
        static func removeKey(named keyName: String) {
            Keychain.default.remove(key: keyName)
        }
        
        static func decrypt(offlineContainers: [OfflineContainer], key: SymmetricKey) throws -> (folders: [Folder], passwords: [Password], tags: [Tag]) {
            let folderOfflineContainers = offlineContainers
                .filter { $0.type == .folder }
            let passwordOfflineContainers = offlineContainers
                .filter { $0.type == .password }
            let tagOfflineContainers = offlineContainers
                .filter { $0.type == .tag }
            
            let folders = try folderOfflineContainers
                .map { $0.data }
                .map { try AES.GCM.SealedBox(combined: $0) }
                .map { try AES.GCM.open($0, using: key) }
                .map { try Configuration.jsonDecoder.decode(Folder.self, from: $0) }
                .zip(with: folderOfflineContainers)
                .map {
                    folder, offlineContainer -> Folder in
                    folder.offlineContainer = offlineContainer
                    return folder
                }
            let passwords = try passwordOfflineContainers
                .map { $0.data }
                .map { try AES.GCM.SealedBox(combined: $0) }
                .map { try AES.GCM.open($0, using: key) }
                .map { try Configuration.jsonDecoder.decode(Password.self, from: $0) }
                .zip(with: passwordOfflineContainers)
                .map {
                    password, offlineContainer -> Password in
                    password.offlineContainer = offlineContainer
                    return password
                }
            let tags = try tagOfflineContainers
                .map { $0.data }
                .map { try AES.GCM.SealedBox(combined: $0) }
                .map { try AES.GCM.open($0, using: key) }
                .map { try Configuration.jsonDecoder.decode(Tag.self, from: $0) }
                .zip(with: passwordOfflineContainers)
                .map {
                    tag, offlineContainer -> Tag in
                    tag.offlineContainer = offlineContainer
                    return tag
                }
            
            return (folders, passwords, tags)
        }
        
        static func decrypt(offlineSettings: Data, key: SymmetricKey) throws -> Settings {
            let encrypted = try AES.GCM.SealedBox(combined: offlineSettings)
            let encoded = try AES.GCM.open(encrypted, using: key)
            let settings = try Configuration.jsonDecoder.decode(Settings.self, from: encoded)
            return settings
        }
        
        static func encrypt(folder: Folder, key: SymmetricKey) -> Data? {
            guard let encoded = try? Configuration.nonUpdatingJsonEncoder.encode(folder),
                  let encrypted = try? AES.GCM.seal(encoded, using: key, nonce: AES.GCM.Nonce()) else {
                return nil
            }
            return encrypted.combined
        }
        
        static func encrypt(password: Password, key: SymmetricKey) -> Data? {
            guard let encoded = try? Configuration.nonUpdatingJsonEncoder.encode(password),
                  let encrypted = try? AES.GCM.seal(encoded, using: key, nonce: AES.GCM.Nonce()) else {
                return nil
            }
            return encrypted.combined
        }
        
        static func encrypt(tag: Tag, key: SymmetricKey) -> Data? {
            guard let encoded = try? Configuration.nonUpdatingJsonEncoder.encode(tag),
                  let encrypted = try? AES.GCM.seal(encoded, using: key, nonce: AES.GCM.Nonce()) else {
                return nil
            }
            return encrypted.combined
        }
        
        static func encrypt(settings: Settings, key: SymmetricKey) -> Data? {
            guard let encoded = try? Configuration.nonUpdatingJsonEncoder.encode(settings),
                  let encrypted = try? AES.GCM.seal(encoded, using: key, nonce: AES.GCM.Nonce()) else {
                return nil
            }
            return encrypted.combined
        }
        
    }
    
}


extension Crypto {

    enum OTP {
        
        enum Algorithm: String, Codable, Identifiable, CaseIterable { // swiftlint:disable:this nesting
            
            case sha1 = "SHA1"
            case sha256 = "SHA256"
            case sha512 = "SHA512"
            
            var id: String {
                rawValue
            }
            
        }
        
        static func value(algorithm: Algorithm, secret: Data, digits: Int, counter: Int) -> String? {
            let counterData = withUnsafeBytes(of: counter.bigEndian) { Data($0) }
            let secretKey = SymmetricKey(data: secret)
            
            let hmac: Data
            switch algorithm {
            case .sha1:
                hmac = Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: secretKey))
            case .sha256:
                hmac = Data(HMAC<CryptoKit.SHA256>.authenticationCode(for: counterData, using: secretKey))
            case .sha512:
                hmac = Data(HMAC<SHA512>.authenticationCode(for: counterData, using: secretKey))
            }
            
            guard var offset = hmac.last else {
                return nil
            }
            offset &= 0x0f
            let subdata = hmac.subdata(in: Int(offset)..<Int(offset) + 4)
            var number = withUnsafeBytes(of: subdata) { $0.load(as: UInt32.self) }.bigEndian
            number &= 0x7fffffff
            number %= UInt32(pow(10, Double(digits)))
            
            return String(format: "%0\(digits)d", number)
        }
        
    }

}
