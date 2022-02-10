import Foundation
import Combine


struct OTP: Equatable {
    
    let type: Type
    let algorithm: Crypto.OTP.Algorithm
    let secret: String
    let digits: Int
    let counter: Int
    let period: Int
    let issuer: String?
    let accountname: String?
    
    init?() {
        self.init(type: .totp, algorithm: nil, secret: "", digits: nil, counter: nil, period: nil)
    }
    
    init?(from url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == "otpauth",
              let typeString = components.host,
              let type = Type(rawValue: typeString),
              let secret = components.queryItems?.first(where: { $0.name == "secret" })?.value else {
            return nil
        }
        
        var algorithm: Crypto.OTP.Algorithm?
        if let algorithmString = components.queryItems?.first(where: { $0.name == "algorithm" })?.value {
            algorithm = Crypto.OTP.Algorithm(rawValue: algorithmString)
            guard algorithm != nil else {
                return nil
            }
        }
        var digits: Int?
        if let digitsString = components.queryItems?.first(where: { $0.name == "digits" })?.value {
            digits = Int(digitsString)
            guard digits != nil else {
                return nil
            }
        }
        
        var issuer = components.queryItems?.first { $0.name == "issuer" }?.value
        var accountname: String?
        let label = components.path.dropFirst().split(separator: ":")
        if 1...2 ~= label.count {
            if label.count == 2,
               let issuerSubstring = label.first {
                if issuer == nil {
                    issuer = String(issuerSubstring)
                }
                else {
                    guard issuer == String(issuerSubstring) else {
                        return nil
                    }
                }
            }
            accountname = label.last?.trimmingCharacters(in: [" "])
        }
        
        var counter: Int?
        var period: Int?
        switch type {
        case .hotp:
            if let counterString = components.queryItems?.first(where: { $0.name == "counter" })?.value {
                counter = Int(counterString)
                guard counter != nil else {
                    return nil
                }
            }
        case .totp:
            if let periodString = components.queryItems?.first(where: { $0.name == "period" })?.value {
                period = Int(periodString)
                guard period != nil else {
                    return nil
                }
            }
        }
        
        self.init(type: type, algorithm: algorithm, secret: secret, digits: digits, counter: counter, period: period, issuer: issuer, accountname: accountname)
    }
    
    private init?(type: Type, algorithm: Crypto.OTP.Algorithm?, secret: String, digits: Int?, counter: Int?, period: Int?, issuer: String? = nil, accountname: String? = nil) {
        let algorithm = algorithm ?? Defaults.algorithm
        let digits = digits ?? Defaults.digits
        guard Data(base32Encoded: secret) != nil,
              6...8 ~= digits else {
            return nil
        }
        self.type = type
        self.algorithm = algorithm
        self.secret = secret
        self.digits = digits
        
        switch type {
        case .hotp:
            guard let counter = counter,
                  counter >= 0 else {
                return nil
            }
            self.counter = counter
            self.period = 0
        case .totp:
            let period = period ?? Defaults.period
            guard period > 0 else {
                return nil
            }
            self.counter = 0
            self.period = period
        }
        
        self.issuer = issuer
        self.accountname = accountname
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(Type.self, forKey: .type)
        let algorithm = try container.decodeIfPresent(Crypto.OTP.Algorithm.self, forKey: .algorithm)
        let secret = try container.decode(String.self, forKey: .secret)
        let digits = try container.decodeIfPresent(Int.self, forKey: .digits)
        let counter = try container.decodeIfPresent(Int.self, forKey: .counter)
        let period = try container.decodeIfPresent(Int.self, forKey: .period)
        
        guard let otp = OTP(type: type, algorithm: algorithm, secret: secret, digits: digits, counter: counter, period: period) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "OTP decoding failed"))
        }
        self = otp
    }
    
    var current: String? {
        guard let secretData = Data(base32Encoded: secret) else {
            return nil
        }
        let counter: Int
        switch type {
        case .hotp:
            counter = self.counter
        case .totp:
            counter = Int(Date().timeIntervalSince1970) / period
        }
        return Crypto.OTP.value(algorithm: algorithm, secret: secretData, digits: digits, counter: counter)
    }
    
    func next() -> OTP {
        guard type == .hotp else {
            return self
        }
        return OTP(type: type, algorithm: algorithm, secret: secret, digits: digits, counter: counter + 1, period: nil) ?? self
    }
    
    static var clock: AnyPublisher<Date, Never> = {
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .flatMap {
                date -> AnyPublisher<Void, Never> in
                let delay = 1 - date.timeIntervalSince1970.truncatingRemainder(dividingBy: 1)
                return Just(())
                    .delay(for: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: delay), scheduler: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .map { _ in Date() }
            .eraseToAnyPublisher()
    }()
    
}


extension OTP: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case type
        case algorithm
        case secret
        case digits
        case counter
        case period
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        if algorithm != Defaults.algorithm {
            try container.encode(algorithm, forKey: .algorithm)
        }
        try container.encode(secret, forKey: .secret)
        if digits != Defaults.digits {
            try container.encode(digits, forKey: .digits)
        }
        switch type {
        case .hotp:
            try container.encode(counter, forKey: .counter)
        case .totp:
            if period != Defaults.period {
                try container.encode(period, forKey: .period)
            }
        }
    }
    
}


extension OTP {
    
    enum `Type`: String, Codable {
        case hotp
        case totp
    }
    
}


extension OTP {
    
    private enum Defaults {
        
        static let algorithm: Crypto.OTP.Algorithm = .sha1
        static let digits = 6
        static let period = 30
        
    }
    
}
