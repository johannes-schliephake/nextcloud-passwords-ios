import Foundation
import Sodium


enum Crypto {
    
    private static let sodium = Sodium()
    
}


extension Crypto {
    
    final class Keychain: Decodable {
        
        let current: String
        let keys: [String: Bytes]
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            current = try container.decode(String.self, forKey: .current)
            keys = try container.decode([String: String].self, forKey: .keys).compactMapValues { sodium.utils.hex2bin($0) }
        }
        
        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case current
            case keys
        }
        
    }
    
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
        
        static func decrypt(keys: String, password: String) -> Keychain? {
            guard let keys = sodium.utils.hex2bin(keys) else {
                return nil
            }
            let salt = Bytes(keys[..<sodium.pwHash.SaltBytes])
            let payload = Bytes(keys[sodium.pwHash.SaltBytes...])
            
            guard let secretKey = sodium.pwHash.hash(outputLength: sodium.box.SeedBytes, passwd: password.bytes, salt: salt, opsLimit: sodium.pwHash.OpsLimitInteractive, memLimit: sodium.pwHash.MemLimitInteractive, alg: .Default),
                  let json = sodium.secretBox.open(nonceAndAuthenticatedCipherText: payload, secretKey: secretKey) else {
                return nil
            }
            return try? JSONDecoder().decode(Keychain.self, from: Data(json))
            // TODO: keychain might be base64 encoded
        }
        
        static func decrypt(payload: String, key: Bytes) -> String? {
            guard !payload.isEmpty else {
                return ""
            }
            guard let encryptedBytes = sodium.utils.hex2bin(payload),
                  let decryptedBytes = sodium.secretBox.open(nonceAndAuthenticatedCipherText: encryptedBytes, secretKey: key) else {
                return nil
            }
            return decryptedBytes.utf8String
            // TODO: payload might be base64 encoded
        }
        
    }
    
}
